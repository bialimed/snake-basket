__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def manta(
        in_annotations="reference/genome.gtf",
        in_reference_seq="reference/genome.fasta",
        in_R1="cutadapt/{sample}_R1.fastq.gz",
        in_R2="cutadapt/{sample}_R2.fastq.gz",
        out_small_indel="structural_variants/manta/{sample}_smallInDel.vcf.gz",
        out_stderr="logs/structural_variants/{sample}_manta_stderr.txt",
        out_sv="structural_variants/manta/{sample}_sv.vcf.gz",
        out_sv_candidate="structural_variants/manta/{sample}_SVCandidates.vcf.gz",
        params_calling_memory=20,  # In GB
        params_is_somatic=True,
        params_is_stranded=True,
        params_java_memory=5,  # In GB
        params_min_candidate_spanning=2,  # Manta is configured with a discovery sensitivity appropriate for general WGS applications. In targeted or other specialized contexts the candidate sensitivity can be increased. A recommended general high sensitivity mode can be obtained by changing the two values 'minEdgeObservations' and 'minCandidateSpanningCount' in the manta configuration file (see 'Advanced configuration options' above) to 2 observations per candidate (the default is 3)
        params_min_edge_obs=2,  # Manta is configured with a discovery sensitivity appropriate for general WGS applications. In targeted or other specialized contexts the candidate sensitivity can be increased. A recommended general high sensitivity mode can be obtained by changing the two values 'minEdgeObservations' and 'minCandidateSpanningCount' in the manta configuration file (see 'Advanced configuration options' above) to 2 observations per candidate (the default is 3)
        params_nb_threads=1,
        params_sort_memory=5,  # In GB
        params_type="rna",  # rna or targeted or genome
        params_keep_outputs=False,
        params_stderr_append=False):
    """Call structural variants (SVs) and indels from paired-end sequencing reads."""
    # Parameters
    opt_by_type = {"rna": "--rna", "targeted": "--exome", "genome": ""}
    if params_type not in opt_by_type:
        raise Exception('The parameter "type" must be in: {}'.format(sorted(list(opt_by_type.keys()))))
    in_genome_dir = os.path.dirname(in_reference_seq)
    manta_dir = os.path.join(os.path.dirname(out_sv), "{sample}_manta")

    # Run STAR alignment
    star_alignments = os.path.join(os.path.dirname(out_sv), "{sample}Aligned.sortedByCoord.out.bam")
    star_prefix = os.path.join(os.path.dirname(out_sv), "{sample}")
    rule manta_star:
        input:
            annotations = in_annotations,
            genome_dir = in_genome_dir,
            R1 = in_R1,
            R2 = [] if in_R2 is None else in_R2
        output:
            alignments = temp(star_alignments),
            tmp_dir = temp(directory(star_prefix + "_STARtmp")),
            tmp_genome = temp(directory(star_prefix + "_STARgenome")),
            tmp_log = temp(star_prefix + "Log.out"),
            tmp_pass1 = temp(directory(star_prefix + "_STARpass1")),
            tmp_progress = temp(star_prefix + "Log.progress.out"),
            tmp_tab = temp(star_prefix + "SJ.out.tab")
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("STAR", "STAR"),
            prefix = star_prefix,
            sort_buffer_size = params_sort_memory * 1000000000,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/star.yml"
        threads: params_nb_threads
        shell:
            "{params.bin_path}"
            " --runThreadN {threads}"
            " --outSAMmapqUnique 50"
            " --outSJfilterCountUniqueMin -1 2 2 2"
            " --outSJfilterCountTotalMin -1 2 2 2"
            " --outFilterType BySJout"
            " --outFilterIntronMotifs RemoveNoncanonical"
            " --chimSegmentMin 15"
            " --chimJunctionOverhangMin 15"
            " --chimScoreDropMax 20"
            " --chimScoreSeparation 10"
            " --chimOutType WithinBAM"
            " --chimSegmentReadGapMax 5"
            " --twopassMode Basic"
            " --outSAMattributes NH NM MD"
            " --outSAMattrRGline ID:1 SM:{wildcards.sample}"
            " --limitBAMsortRAM {params.sort_buffer_size}"
            " --readFilesCommand zcat"
            " --outSAMtype BAM SortedByCoordinate"
            " --readFilesIn {input.R1} {input.R2}"
            " --genomeDir {input.genome_dir}"
            " --sjdbGTFfile {input.annotations}"
            " --outFileNamePrefix {params.prefix}"
            " {params.stderr_redirection} {log}"

    # Mark duplications
    markdup_alignments = star_alignments[:-4] + "_markdup.bam"
    markdup_alignments_index = markdup_alignments[:-4] + ".bai"
    rule manta_markDup:
        input:
            star_alignments
        output:
            alignments = temp(markdup_alignments),
            metrics = temp(markdup_alignments + ".tsv"),
            index = temp(markdup_alignments_index)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("picard", "picard"),
            java_memory = params_java_memory
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} MarkDuplicates"
            " -Xmx{params.java_memory}G"
            " VALIDATION_STRINGENCY=LENIENT"
            " REMOVE_SEQUENCING_DUPLICATES=false"
            " REMOVE_DUPLICATES=false"
            " CREATE_INDEX=true"
            " INPUT={input}"
            " OUTPUT={output.alignments}"
            " METRICS_FILE={output.metrics}"
            " 2>> {log}"

    # Configurate manta
    manta_launcher = os.path.join(manta_dir, "runWorkflow.py")
    rule manta_config:
        input:
            alignments = markdup_alignments,
            alignments_idx = markdup_alignments_index,
            reference_seq = in_reference_seq
        output:
            temp(manta_launcher)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("configManta", "configManta.py"),
            bin_folder = os.path.dirname(getSoft(config, "configManta.py", "fusion_callers")),
            bam = "tumorBam" if params_is_somatic and params_type != "rna" else "bam",  # When RNA mode is turned on, exactly one sample must be specified as normal input only (using either the --bam or --normalBam option)
            config_tpl = os.path.join(os.path.dirname(workflow.snakefile), "envs/manta_config.ini"),
            manta_dir = manta_dir,
            min_candidate_spanning = params_min_candidate_spanning,
            min_edge_obs = params_min_edge_obs,
            strand = "" if params_type != "rna" else ("" if params_is_stranded else "--unstrandedRNA"),
            type = opt_by_type[params_type]
        conda:
            "envs/manta.yml"
        shell:
            "cp {params.config_tpl} {params.manta_dir}/configManta.py.ini 2>> {log}"
            " && "
            "sed -i -E 's/^minEdgeObservations = [[:digit:]]+/minEdgeObservations = {params.min_edge_obs}/g' {params.manta_dir}/configManta.py.ini 2>> {log}"
            " && "
            "sed -i -E 's/^minCandidateSpanningCount = [[:digit:]]+/minCandidateSpanningCount = {params.min_candidate_spanning}/g' {params.manta_dir}/configManta.py.ini 2>> {log}"
            " && "
            "{params.bin_path}"
            " {params.type}"
            " {params.strand}"
            " --config {params.manta_dir}/configManta.py.ini"
            " --referenceFasta {input.reference_seq}"
            " --{params.bam} {input.alignments}"
            " --runDir {params.manta_dir}"
            " 2>> {log}"

    # Run manta
    rule manta_run:
        input:
            alignments = markdup_alignments,
            alignments_idx = markdup_alignments_index,
            reference_seq = in_reference_seq,
            launcher = manta_launcher
        output:
            small_indel = out_small_indel if params_keep_outputs else temp(out_small_indel),
            sv_candidate = out_sv_candidate if params_keep_outputs else temp(out_sv_candidate),
            sv = out_sv if params_keep_outputs else temp(out_sv)
        log:
            out_stderr
        params:
            fix_bin = os.path.abspath(os.path.join(os.path.dirname(workflow.snakefile), "scripts", "fixMantaHeader.py")),
            manta_dir = manta_dir,
            memory = params_calling_memory,
            sv_filename = "rnaSV.vcf.gz" if params_type == "rna" else ("tumorSV.vcf.gz" if params_is_somatic else "somaticSV.vcf.gz")
        conda:
            "envs/manta.yml"
        threads: params_nb_threads
        shell:
            "{input.launcher}"
            " --mode local"
            " --memGb {params.memory}"
            " --jobs {threads}"
            " 2>> {log}"
            " && "
            "{params.fix_bin}"
            " --input-variants {params.manta_dir}/results/variants/candidateSmallIndels.vcf.gz"
            " --output-variants {output.small_indel}"
            " 2>> {log}"
            " && "
            "{params.fix_bin}"
            " --input-variants {params.manta_dir}/results/variants/candidateSV.vcf.gz"
            " --output-variants {output.sv_candidate}"
            " 2>> {log}"
            " && "
            "{params.fix_bin}"
            " --input-variants {params.manta_dir}/results/variants/{params.sv_filename}"
            " --output-variants {output.sv}"
            " 2>> {log}"
