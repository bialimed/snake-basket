__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '3.3.0'


def evalPositiveCtrl(
        in_expected,
        in_observed="variants/{variant_caller}/{sample}_filtered.vcf",
        out_results="stats/posCtrl/{sample}_{variant_caller}.tsv",
        out_stderr="logs/variants/{variant_caller}/{sample}_evalCtrl_stderr.txt",
        params_error_threshold=None,
        params_keep_outputs=False,
        params_only_expected=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """'Compare variant calling result to expected variants."""
    rule:
        name:
            "evalPositiveCtrl" + snake_rule_suffix
        input:
            expected = in_expected,
            observed = in_observed
        output:
            out_results if params_keep_outputs else temp(out_results)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("evalVariantControl", "evalVariantControl.py"),
            error_threshold = "" if params_error_threshold is None else "--error-threshold " + str(params_error_threshold),
            only_expected = "--only-expected" if params_only_expected else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.error_threshold}"
            " {params.only_expected}"
            " --expected-file {input.expected}"
            " --detected-file {input.observed}"
            " --output-file {output}"
            " {params.stderr_redirection} {log}"
