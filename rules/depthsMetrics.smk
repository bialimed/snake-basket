__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


include: "samtools_depth.smk"


def depthsMetrics(
        in_targets=None,
        in_alignments="aln/markDup/{sample}.bam",
        out_metrics="stats/depth/{sample}_depthsMetrics.tsv",
        out_stderr="logs/stats/depth/{sample}_depthsMetrics_stderr.txt",
        params_min_map_qual=None,
        params_min_read_qual=None,
        params_expected_min_depth=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Depths metrics (distribution, count by depth and targets under threshold) from the samtools depth output."""
    params_format = out_metrics.split(".")[-1]
    if params_format not in ["tsv", "json"]:
        raise Exception('The file extension for out_metrics in depthsMetrics must end with "json" or "tsv".')
    # Get depths by position
    samtools_depth(
        in_targets=in_targets,
        in_alignments=in_alignments,
        out_depths=(out_metrics + "_samtoolsDepth"),
        params_mode="all_targeted",
        params_max_depth=0,
        params_min_map_qual=params_min_map_qual,
        params_min_read_qual=params_min_read_qual,
    )
    # Metrics
    rule depthsMetrics:
        input:
            out_metrics + "_samtoolsDepth"
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("depthsMetrics", "depthsMetrics.py"),
            expected_min_depth = "" if params_expected_min_depth is None else "--min-depth " + str(params_expected_min_depth),
            format = params_format,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --samples '{wildcards.sample}'"
            " {params.expected_min_depth}"
            " --input-depths {input}"
            " --output-{params.format} {output}"
            " {params.stderr_redirection} {log}"
