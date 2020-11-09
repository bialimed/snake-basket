__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def concatenateTextFiles(
        in_files,
        out_file,
        out_stderr="logs/{sample}_concatenate_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Concatenates text files."""
    rule concatenateTextFiles:
        input:
            in_files
        output:
            out_file
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("concatenateTextFiles", "concatenateTextFiles.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --inputs {input}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
