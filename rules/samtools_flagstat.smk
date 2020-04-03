__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def samtools_flagstat(
        in_alignments="aln/markDup/{sample}.bam",
        out_metrics="stats/samtoolsFlagstat/{sample}.tsv",
        out_stderr="logs/stats/samtoolsFlagstat/{sample}_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Count the number of alignments for each FLAG type."""
    rule samtools_flagstat:
        input:
            in_alignments
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("samtools", "samtools"),
            extra = params_extra,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path} flagstat"
            " {params.extra}"
            " {input}"
            " > {output}"
            " {params.stderr_redirection} {log}"
