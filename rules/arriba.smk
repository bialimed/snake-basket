__author__ = 'Veronique Ivashchenko and Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def arriba(
        in_annotations="reference/genome.gtf",
        in_blacklist=None,
        in_reference_seq="reference/genome.fasta",
        in_R1="cutadapt/{sample}_R1.fastq.gz",
        in_R2="cutadapt/{sample}_R2.fastq.gz",
        out_discarded="structural_variants/Arriba/{sample}_fusions_discarded.tsv",
        out_fusions="structural_variants/Arriba/{sample}_fusions.tsv",
        out_stderr="logs/structural_variants/{sample}_arriba_stderr.txt",
        params_add_fusion_transcript=True,
        params_add_peptide_sequence=True,
        params_disabled_filters=None,
        params_extra="",
        params_max_reads=1000,  # Subsample fusions with more than the given number of supporting reads.
        params_min_anchor_length=None,  # This parameter sets the threshold in bp for what the filter considers short.
        params_min_supporting_reads=None,  # The filter min_support discards all fusions with fewer than this many supporting reads (split reads and discordant mates combined).
        params_nb_threads=1,
        params_sort_memory=5,  # In GB
        params_strandedness="auto",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Call fusions with Arriba."""
    # Parameters.
    in_genome_dir = os.path.dirname(in_reference_seq)

    # Run STAR alignment.
    star_alignments = os.path.join(os.path.dirname(out_fusions), "{sample}Aligned.sortedByCoord.out.bam")
    star_prefix = os.path.join(os.path.dirname(out_fusions), "{sample}")
    rule arriba_star:
        input:
            annotations = in_annotations,
            genome_dir = in_genome_dir,
            R1 = in_R1,
            R2 = [] if in_R2 is None else in_R2
        output:
            alignments = temp(star_alignments),
            tmp_dir = temp(directory(star_prefix + "_STARtmp")),
            tmp_progress = temp(star_prefix + "Log.progress.out"),
            tmp_tab = temp(star_prefix + "SJ.out.tab")
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("STAR", "STAR"),
            prefix = os.path.join(os.path.dirname(out_fusions), "{sample}"),
            sort_buffer_size = params_sort_memory * 1000000000,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/star.yml"
        threads: params_nb_threads
        shell:
            "{params.bin_path}"
            " --runThreadN {threads}"
            " --genomeDir {input.genome_dir}"
            " --genomeLoad NoSharedMemory"
            " --outSAMunmapped Within"
            " --outBAMcompression 0"
            " --outFilterMultimapNmax 1"
            " --outFilterMismatchNmax 3"
            " --chimSegmentMin 10"
            " --chimOutType WithinBAM SoftClip"
            " --chimJunctionOverhangMin 10"
            " --chimScoreMin 1"
            " --chimScoreDropMax 30"
            " --chimScoreJunctionNonGTAG 0"
            " --chimScoreSeparation 1"
            " --alignSJstitchMismatchNmax 5 -1 5 5"
            " --chimSegmentReadGapMax 3"
            " --readFilesCommand zcat"
            " --outSAMattrRGline ID:1 SM:{wildcards.sample}"
            " --limitBAMsortRAM {params.sort_buffer_size}"
            " --outSAMtype BAM SortedByCoordinate"
            " --readFilesIn {input.R1} {input.R2}"
            " --outFileNamePrefix {params.prefix}"
            " {params.stderr_redirection} {log}"

    # Run arriba
    rule arriba_run:
        input:
            alignments = star_alignments,
            annotations = in_annotations,
            blacklist = in_blacklist,
            reference_seq = in_reference_seq
        output:
            discarded = [] if out_discarded is None else (out_discarded if params_keep_outputs else temp(out_discarded)),
            fusions = out_fusions if params_keep_outputs else temp(out_fusions)
        log:
            out_stderr
        params:
            add_fusion_transcript = "-T" if params_add_fusion_transcript else "",
            add_peptide_sequence = "-P" if params_add_peptide_sequence else "",
            bin_path = config.get("software_pathes", {}).get("arriba", "arriba"),
            blacklist = "" if in_blacklist is None else "-b " + in_blacklist,
            discarded = "" if out_discarded is None else "-O " + out_discarded,
            disabled_filters = "" if params_disabled_filters is None or len(params_disabled_filters) == 0 else "-f " + ",".join(params_disabled_filters),
            extra = params_extra,
            min_supporting_reads = "" if params_min_supporting_reads is None else "-S " + str(params_min_supporting_reads),
            min_anchor_length = "" if params_min_anchor_length is None else "-A " + str(params_min_anchor_length),
            max_reads = "" if params_max_reads is None else "-U " + str(params_max_reads),
            strandedness = "" if params_strandedness is None else "-s " + params_strandedness
        # conda:
        #     "envs/arriba.yml"
        shell:
            "{params.bin_path}"
            " {params.add_fusion_transcript}"
            " {params.add_peptide_sequence}"
            " {params.blacklist}"
            " {params.discarded}"
            " {params.disabled_filters}"
            " {params.extra}"
            " {params.min_supporting_reads}"
            " {params.min_anchor_length}"
            " {params.max_reads}"
            " {params.strandedness}"
            " -x {input.alignments}"
            " -a {input.reference_seq}"
            " -g {input.annotations}"
            " -o {output.fusions}"
            " 2>> {log}"
