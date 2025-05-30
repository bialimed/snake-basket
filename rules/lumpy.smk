__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2025 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def lumpyexpress(
        in_alignments="aln/delDup/{sample}.bam",
        in_targets=None,
        out_variants="sv/{sample}_lumpyexpress_call.vcf",
        out_stderr="logs/{sample}_lumpyexpress_stderr.txt",
        params_keep_outputs=True,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Structural variant discovery."""
    rule:
        name:
            "lumpyexpress" + snake_rule_suffix
        input:
            alignments = in_alignments,
            targets = ([] if in_targets is None else in_targets)
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("lumpyexpress", "lumpyexpress"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            targets = "-x " + in_targets if in_targets else ""
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        threads: 1
        conda:
            "envs/lumpy.yml"
        shell:
            "{params.bin_path}"
            " {params.targets}"
            " -B {input.alignments}"
            " -o {output}"
            " > {log}"
            " {params.stderr_redirection} {log.stderr}"
