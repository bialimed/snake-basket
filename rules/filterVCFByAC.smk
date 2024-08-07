__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def filterVCFByAC(
        in_variants="variants/{variant_caller}/{sample}_annot.vcf",
        out_variants="variants/{variant_caller}/{sample}_annot_tagByAC.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterByAC_stderr.txt",
        params_keep_outputs=False,
        params_min_alt_fraction=0.02,
        params_min_alt_count=4,
        params_min_calling_depth=20,
        params_remove=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Filter variants on their AD, AF and DP."""
    rule:
        name:
            "filterVCFByAC" + snake_rule_suffix
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterVCFByAC", "filterVCFByAC.py"),
            mode = "remove" if params_remove else "tag",
            min_AD = "" if params_min_alt_count is None else " --min-AD " + str(params_min_alt_count),
            min_AF = "" if params_min_alt_fraction is None else " --min-AF " + str(params_min_alt_fraction),
            min_DP = "" if params_min_calling_depth is None else " --min-DP " + str(params_min_calling_depth),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "2G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --mode {params.mode}"
            " {params.min_AD}"
            " {params.min_AF}"
            " {params.min_DP}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
