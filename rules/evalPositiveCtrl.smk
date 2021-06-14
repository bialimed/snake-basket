__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def evalPositiveCtrl(
        in_expected,
        in_observed="variants/{variant_caller}/{sample}_filtered.vcf",
        out_results="stats/posCtrl/{sample}_{variant_caller}.tsv",
        out_stdout="logs/variants/{variant_caller}/{sample}_evalCtrl_stdout.txt",
        out_stderr="logs/variants/{variant_caller}/{sample}_evalCtrl_stderr.txt",
        params_error_threshold=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """'Compare variant calling result to expected variants. This comparison is only processed on expected variants."""
    rule evalPositiveCtrl:
        input:
            expected = in_expected,
            observed = in_observed
        output:
            out_results if params_keep_outputs else temp(out_results)
        log:
            stderr = out_stderr,
            stdout = out_stdout
        params:
            bin_path = config.get("software_paths", {}).get("evalVariantControl", "evalVariantControl.py"),
            error_threshold = "" if params_error_threshold is None else "--error-threshold " + str(params_error_threshold),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.error_threshold}"
            " --expected-file {input.expected}"
            " --detected-file {input.observed}"
            " --output-file {output}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
