__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2022 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def microsatMergeResults(
        in_reports,
        out_report="microsat/{sample}_statusClassify.json",
        out_stderr="logs/{sample}_microsatMergeResults_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Merge multiple MSI ReportIO from the same samples and loci."""
    rule microsatMergeResults:
        input:
            in_reports
        output:
            out_report if params_keep_outputs else temp(out_report)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatMergeResults", "microsatMergeResults.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --inputs-reports {input}"
            " --output-report {output}"
            " {params.stderr_redirection} {log}"
