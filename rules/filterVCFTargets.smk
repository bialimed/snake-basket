__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def filterVCFTargets(
        in_reference_seq="data/reference.fa",
        in_targets="data/targets.bed",
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        out_variants="variants/{variant_caller}/{sample}_onTargets.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterTargets_stderr.txt",
        params_remove=False,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Filter variants by location. Each variant not located on one of the selected regions is removed."""
    rule filterVCFTargets:
        input:
            reference_seq = in_reference_seq,
            targets = in_targets,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterVCFTargets", "filterVCFTargets.py"),
            mode = "remove" if params_remove else "tag",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --mode {params.mode}"
            " --input-reference {input.reference_seq}"
            " --input-targets {input.targets}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
