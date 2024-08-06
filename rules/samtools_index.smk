__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.4.1'


def samtools_index(
        in_alignments="aln/{sample}.bam",
        out_alignments_idx=None,
        out_stderr="logs/{sample}_alnIndex_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Index a coordinate-sorted BAM or CRAM file for fast random access."""
    # Parameters
    out_alignments_idx = in_alignments[:-4] + ".bai" if out_alignments_idx is None else out_alignments_idx
    # Rule
    rule:
        name:
            "samtools_index" + snake_rule_suffix
        input:
            in_alignments,
        output:
            out_alignments_idx if params_keep_outputs else temp(out_alignments_idx)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("samtools", "samtools"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path} index"
            " {input}"
            " {output}"
            " {params.stderr_redirection} {log}"
