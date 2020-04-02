__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def fastqc(
        in_fastq="data/{sample}{suffix}.fastq.gz",
        out_dir="stats/fastqc",
        out_stderr="logs/fastqc/{sample}{suffix}_fastqc_stderr.txt",
        out_stdout="logs/fastqc/{sample}{suffix}_fastqc_stdout.txt",
        in_adapters=None,
        in_contaminants=None,
        params_extra="",
        params_is_grouped=True,
        params_nb_threads=1,
        params_keep_outputs=True,
        params_stderr_append=False):
    """Reads quality controls."""
    out_html = os.path.join(
        out_dir,
        os.path.basename(in_fastq).replace(".fastq.gz", "_fastqc.html").replace(".fastq", "_fastqc.html")
    )
    out_zip = os.path.join(
        out_dir,
        os.path.basename(in_fastq).replace(".fastq.gz", "_fastqc.zip").replace(".fastq", "_fastqc.zip")
    )
    # Rule
    rule fastqc:
        input:
            adapters = [] if in_adapters is None else in_adapters,
            contaminants = [] if in_contaminants is None else in_contaminants,
            fastq = in_fastq
        output:
            html = out_html if params_keep_outputs else temp(out_html),
            zip = out_zip if params_keep_outputs else temp(out_zip)
        wildcard_constraints:
            suffix = '[\._-][Rr]?[12]'
        log:
            stderr = out_stderr,
            stdout = out_stdout
        params:
            adapters = "" if in_adapters is None else "--adapters " + in_adapters,
            bin_path = config.get("software_pathes", {}).get("fastqc", "fastqc"),
            contaminants = "" if in_contaminants is None else "--contaminants " + in_contaminants,
            dir = out_dir,
            extra = params_extra,
            nogroup = "" if params_is_grouped else "--nogroup",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        threads: params_nb_threads
        conda:
            "envs/fastqc.yml"
        shell:
            "{params.bin_path}"
            " --quiet"
            " --threads {threads}"
            " {params.extra}"
            " {params.adapters}"
            " {params.contaminants}"
            " {params.nogroup}"
            " --outdir {params.dir}"
            " --dir {params.dir}"
            " {input.fastq}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
