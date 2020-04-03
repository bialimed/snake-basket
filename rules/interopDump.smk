__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def interopDump(
        in_interop_folder,
        out_dump="stats/run/interopDump.txt",
        out_stderr="logs/stats/run/interopDump_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Dump Interop data into a text format."""
    # Parameters
    in_run_folder = os.path.dirname(in_interop_folder)
    in_run_info = os.path.join(in_run_folder, "RunInfo.xml")
    in_run_parameters = os.path.join(in_run_folder, "runParameters.xml")
    if os.path.exists(os.path.join(in_run_folder, "RunParameters.xml")):
        in_run_parameters = os.path.join(in_run_folder, "RunParameters.xml")
    # Rule
    rule interopDump:
        input:
            run_folder = in_run_folder,
            interop_folder = in_interop_folder,
            run_info = in_run_info,
            run_parameters = in_run_parameters
        output:
            out_dump if params_keep_outputs else temp(out_dump)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("interop_dumptext", "interop_dumptext"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/illuminainterop.yml"
        shell:
            "{params.bin_path}"
            " {input.run_folder}"
            " > {output}"
            " {params.stderr_redirection} {log}"
