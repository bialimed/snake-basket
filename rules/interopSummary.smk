__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


include: "interopDump.smk"


def interopSummary(
        in_interop_folder,
        out_summary="stats/run/interopSummary.json",
        out_stderr="logs/stats/run/interopSummary_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Summarizes an Illumina's run metrics from an InterOp file."""
    # Dump interop
    interopDump(
        in_interop_folder=in_interop_folder,
        out_dump=out_summary + "_tmpDump.txt",
        out_stderr=out_stderr,
        params_stderr_append=True
    )
    # Interop dump to JSON summary
    rule interopSummary:
        input:
            out_summary + "_tmpDump.txt"
        output:
            out_summary if params_keep_outputs else temp(out_summary)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("interopSummary", "interopSummary.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --interop-file {input}"
            " --output-file {output}"
            " {params.stderr_redirection} {log}"
