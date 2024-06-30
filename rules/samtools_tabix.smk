__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2024 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def samtools_tabix(
        in_tab=None,
        out_tab=None,
        out_stderr="logs/{sample}_tabix_stderr.txt",
        params_begin_col=None,
        params_end_col=None,
        params_sequence_col=None,
        params_skip_lines_nb=None,
        params_zero_based=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Index TAB-delimited genome position files."""
    # Compress
    rule:
        name:
            "bgzip" + snake_rule_suffix
        input:
            in_tab
        output:
            out_tab if params_keep_outputs else temp(out_tab)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("bgzip", "bgzip"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path}"
            " --stdout"
            " {input}"
            " > {output}"
            " {params.stderr_redirection} {log}"
    # Index
    out_idx = out_tab + ".tbi"
    rule:
        name:
            "tabix" + snake_rule_suffix
        input:
            out_tab,
        output:
            out_idx if params_keep_outputs else temp(out_idx)
        log:
            out_stderr
        params:
            begin_col = "--begin {}".format(params_begin_col) if params_begin_col else "",
            bin_path = config.get("software_paths", {}).get("tabix", "tabix"),
            end_col = "--end {}".format(params_end_col) if params_end_col else "",
            sequence_col = "--sequence {}".format(params_sequence_col) if params_sequence_col else "",
            skip_lines_nb = "--skip-lines {}".format(params_skip_lines_nb) if params_skip_lines_nb else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            zero_based = "--zero-based" if params_zero_based else ""
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path}"
            " {params.begin_col}"
            " {params.end_col}"
            " {params.sequence_col}"
            " {params.skip_lines_nb}"
            " {params.zero_based}"
            " {input}"
            " 2>> {log}"
