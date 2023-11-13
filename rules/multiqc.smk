__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def multiqc(
        in_files,
        out_dir="stats/multiqc",
        out_stderr="logs/stats/multiqc_stderr.txt",
        out_stdout="logs/stats/multiqc_stdout.txt",
        params_extra=""):
    """Aggregate results from bioinformatics analyses across many samples into a single report."""
    # Parameters
    in_files_list = os.path.join(out_dir, "multiqc_inputs.txt")
    # Creates list of files
    os.makedirs(out_dir, exist_ok=True)
    with open(in_files_list, "w") as handle:
        for curr_file in in_files:
            handle.write(curr_file + "\n")
    # Rule
    rule multiqc:
        input:
            in_files
        output:
            data = directory(os.path.join(out_dir, "multiqc_data")),
            html = os.path.join(out_dir, "multiqc_report.html")
        log:
            stderr = out_stderr,
            stdout = out_stdout
        params:
            bin_path = config.get("software_paths", {}).get("multiqc", "multiqc"),
            dir = out_dir,
            extra = params_extra,
            file_list = in_files_list
        resources:
            extra = "",
            mem = "8G",
            partition = "normal"
        conda:
            "envs/multiqc.yml"
        shell:
            "{params.bin_path}"
            " --force"
            " --outdir {params.dir}"
            " --file-list {params.file_list}"
            " > {log.stdout}"
            " 2> {log.stderr}"
