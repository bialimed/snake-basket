__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def insertSize(
        in_alignments="aln/markDup/{sample}.bam",
        out_metrics="stats/insertSize/{sample}.tsv",
        out_report="stats/insertSize/{sample}.pdf",
        out_stdout="logs/aln/{sample}_isize_stdout.txt",
        out_stderr="logs/aln/{sample}_isize_stderr.txt",
        params_extra="",
        params_java_mem="5G",
        params_stringency="LENIENT",
        params_hist_width=1000,
        params_min_pct=0.05,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Insert size distribution and read orientation of paired-end libraries.."""
    rule insertSize:
        input:
            in_alignments
        output:
            metrics = out_metrics if params_keep_outputs else temp(out_metrics),
            report = out_report if params_keep_outputs else temp(out_report)
        log:
            stdout = out_stdout,
            stderr = out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            extra = params_extra,
            hist_width = params_hist_width,
            java_mem = params_java_mem,
            min_pct = params_min_pct,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} CollectInsertSizeMetrics"
            " -Xmx{params.java_mem}"
            " {params.extra}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " HISTOGRAM_WIDTH={params.hist_width}"
            " MINIMUM_PCT={params.min_pct}"
            " INPUT={input}"
            " OUTPUT={output.metrics}"
            " HISTOGRAM_FILE={output.report}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
