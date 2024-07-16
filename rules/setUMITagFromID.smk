__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.2.0'


def setUMITagFromID(
        in_alignments="aln/{sample}.bam",
        out_alignments="aln/{sample}_tag.bam",
        out_stderr="logs/reads/{sample}_setUMIRGFromID_stderr.txt",
        params_umi_separator=None,
        params_umi_tag=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """For each read get the UMI sequence from the ID and place it in tag."""
    rule:
        name:
            "setUMITagFromID" + snake_rule_suffix
        input:
            in_alignments
        output:
            out_alignments if params_keep_outputs else temp(out_alignments)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("setUMITagFromID", "setUMITagFromID.py"),
            umi_separator = " --umi-separator {}".format(params_umi_separator) if params_umi_separator else "",
            umi_tag = " --umi-tag {}".format(params_umi_tag) if params_umi_tag else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            "{params.umi_separator}"
            "{params.umi_tag}"
            " --input-aln {input}"
            " --output-aln {output}"
            " {params.stderr_redirection} {log}"
