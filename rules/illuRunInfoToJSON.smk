__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def illuRunInfoToJSON(
        in_run_folder,
        out_summary="stats/run/runSummary.json",
        out_stderr="logs/stats/run/illuRunInfoToJSON_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Dump run information coming from several files in run folder."""
    in_run_info = os.path.join(in_run_folder, "RunInfo.xml")
    # Rule
    rule:
        name:
            "illuRunInfoToJSON" + snake_rule_suffix
        input:
            run_info = in_run_info,
            run_folder = in_run_folder
        output:
            out_summary if params_keep_outputs else temp(out_summary)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("illuRunInfoToJSON", "illuRunInfoToJSON.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --input-run-folder {input.run_folder}"
            " --output-info {output}"
            " {params.stderr_redirection} {log}"
