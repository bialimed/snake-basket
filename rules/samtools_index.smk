__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def samtools_index(
        in_alignments="aln/{sample}.bam",
        out_stderr="logs/{sample}_alnIndex_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Index a coordinate-sorted BAM or CRAM file for fast random access."""
    out_index = in_alignments + ".bai"
    rule samtools_index:
        input:
            in_alignments,
        output:
            out_index if params_keep_outputs else temp(out_index)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("samtools", "samtools"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path} index"
            " {input}"
            " > {output}"
            " {params.stderr_redirection} {log}"
