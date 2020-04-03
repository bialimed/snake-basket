__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def bwa_mem(
        in_reads=None,  # ["data/{sample}_R1.fastq.gz", "data/{sample}_R2.fastq.gz"]
        in_reference_seq="data/reference.fa",
        out_alignments="aln/{sample}.bam",
        out_stderr="logs/aln/{sample}_bwaMem_stderr.txt",
        params_extra=r"-R '@RG\tID:1\tLB:{sample}\tSM:{sample}\tPL:ILLUMINA'",
        params_threads=1,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Map low-divergent sequences against a large reference genome."""
    if in_reads is None:
        in_reads = ["data/{sample}_R1.fastq.gz", "data/{sample}_R2.fastq.gz"]
    # Rule
    rule bwa_mem:
        input:
            reads = in_reads,
            reference = in_reference_seq
        output:
            bam = out_alignments if params_keep_outputs else temp(out_alignments),
            sam = temp(out_alignments + ".sam")
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("bwa", "bwa"),
            extra = params_extra,
            samtools_path = config.get("software_pathes", {}).get("samtools", "samtools"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        threads: params_threads
        conda:
            "envs/bwa.yml"
        shell:
            "{params.bwa_path} mem"
            " -t {threads}"
            " {params.extra}"
            " {input.reference}"
            " {input.reads}"
            " > {output.sam}"
            " {params.stderr_redirection} {log}"
            " && "
            "{params.samtools_path} sort"
            " -O BAM"
            " -o {output.bam}"
            " {output.sam}"
            " 2>> {log}"
