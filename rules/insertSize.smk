__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def insertSize(
        in_alignments="aln/markDup/{sample}.bam",
        out_metrics="stats/insertSize/{sample}.tsv",
        out_report="stats/insertSize/{sample}.pdf",
        out_stderr="logs/aln/{sample}_isize_stderr.txt",
        params_extra="",
        params_hist_width=1000,
        params_keep_outputs=False,
        params_min_pct=0.05,
        params_stderr_append=False,
        params_stringency="LENIENT",
        snake_rule_suffix=""):
    """Insert size distribution and read orientation of paired-end libraries."""
    rule:
        name:
            "insertSize" + snake_rule_suffix
        input:
            in_alignments
        output:
            metrics = out_metrics if params_keep_outputs else temp(out_metrics),
            report = out_report if params_keep_outputs else temp(out_report)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            extra = params_extra,
            hist_width = params_hist_width,
            min_pct = params_min_pct,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        resources:
            extra = "",
            java_mem = "4G",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} CollectInsertSizeMetrics"
            " -Xmx{resources.java_mem}"
            " {params.extra}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " HISTOGRAM_WIDTH={params.hist_width}"
            " MINIMUM_PCT={params.min_pct}"
            " INPUT={input}"
            " OUTPUT={output.metrics}"
            " HISTOGRAM_FILE={output.report}"
            " {params.stderr_redirection} {log}"
