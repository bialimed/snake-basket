__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'


def concatenateTextFiles(
        in_files,
        out_file,
        out_stderr="logs/{sample}_concatenate_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Concatenates text files."""
    rule:
        name:
            "concatenateTextFiles" + snake_rule_suffix
        input:
            in_files
        output:
            out_file
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("concatenateTextFiles", "concatenateTextFiles.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "2G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --inputs {input}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
