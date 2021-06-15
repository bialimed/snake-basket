__author__ = 'Gael Jalowicki and Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def star(
        in_reference_seq="reference/genome.fasta",
        in_R1="cutadapt/{sample}_R1.fastq.gz",
        in_R2="cutadapt/{sample}_R2.fastq.gz",
        out_alignments="aln/{sample}.bam",
        out_metrics="aln/{sample}Log.final.out",
        out_stderr="logs/aln/{sample}_star_stderr.txt",
        params_extra="",
        params_nb_threads=1,
        params_sort_memory=5,  # In GB
        params_keep_outputs=False,
        params_stderr_append=False):
    """Spliced Transcripts Alignment to a Reference."""
    work_directory = os.path.join(os.path.dirname(out_alignments), "tmp_{sample}")
    out_spl_prefix = os.path.join(work_directory, "{sample}")
    # Process
    rule star:
        input:
            genome_dir = os.path.dirname(in_reference_seq),
            R1 = in_R1,
            R2 = [] if in_R2 is None else in_R2
        output:
            alignments = out_alignments if params_keep_outputs else temp(out_alignments),
            metrics = out_metrics,
            tmp_directory = temp(directory(work_directory))
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("STAR", "STAR"),
            prefix = out_spl_prefix,
            sort_buffer_size = params_sort_memory * 1000000000,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            tmp_aln = out_spl_prefix + "Aligned.sortedByCoord.out.bam",
            tmp_metrics = out_spl_prefix + "Log.final.out",
        conda:
            "envs/star.yml"
        threads: params_nb_threads
        shell:
            "mkdir -p {output.tmp_directory}"
            " {params.stderr_redirection} {log}"
            " && "
            "{params.bin_path}"
            " --runThreadN {threads}"
            " --genomeDir {input.genome_dir}"
            " --genomeLoad NoSharedMemory"
            " --outSAMunmapped Within"
            " --readFilesCommand zcat"
            " --outSAMattrRGline ID:1 SM:{wildcards.sample}"
            " --limitBAMsortRAM {params.sort_buffer_size}"
            " --outSAMtype BAM SortedByCoordinate"
            " --readFilesIn {input.R1} {input.R2}"
            " --outFileNamePrefix {params.prefix}"
            " 2>> {log}"
            " && "
            "mv {params.tmp_aln} {output.alignments}"
            " 2>> {log}"
            " && "
            "mv {params.tmp_metrics} {output.metrics}"
            " 2>> {log}"
