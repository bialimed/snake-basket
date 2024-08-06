__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def bedToInterval(
        in_reference_dict=None,
        in_target_bed="data/targets.bed",
        out_intervals="design/targets_intervals.picard",
        out_stderr="logs/design/targets_stderr.txt",
        out_stdout="logs/design/targets_stdout.txt",
        params_keep_outputs=False,
        params_stderr_append=False,
        params_unique=False,
        snake_rule_suffix=""):
    """Converts a BED file to a Picard Interval List."""
    # Parameters
    if in_reference_dict is None:
        in_reference_dict = getDictPath("data/reference.fa")
    # Rule
    rule:
        name:
            "bedToInterval" + snake_rule_suffix
        input:
            reference_dict = in_reference_dict,
            target_bed = in_target_bed
        output:
            out_intervals if params_keep_outputs else temp(out_intervals)
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            unique = str(params_unique).lower()
        log:
            stderr = out_stderr,
            stdout = out_stdout
        resources:
            extra = "",
            java_mem = "3G",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} BedToIntervalList"
            " -Xmx{resources.java_mem}"
            " UNIQUE={params.unique}"
            " INPUT={input.target_bed}"
            " SEQUENCE_DICTIONARY={input.reference_dict}"
            " OUTPUT={output}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
