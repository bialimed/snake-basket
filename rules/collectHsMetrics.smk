__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def collectHsMetrics(
        in_reference_seq="data/reference.fa",
        in_alignments="aln/markDup/{sample}.bam",
        in_targets_intervals="design/targets_intervals.picard",
        in_baits_intervals=None,  # targets_intervals is use as default value
        out_metrics="stats/collectHs/{sample}.tsv",
        out_stderr="logs/aln/{sample}_collectHs_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_stderr_append=False,
        params_stringency="LENIENT"):
    """Collect hybrid-selection (HS) metrics for a SAM or BAM file. """
    if in_baits_intervals is None:
        in_baits_intervals = in_targets_intervals
    # Rule
    rule collectHsMetrics:
        input:
            alignments = in_alignments,
            baits_intervals = in_baits_intervals,
            reference_seq = in_reference_seq,
            targets_intervals = in_targets_intervals
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            extra = params_extra,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        resources:
            extra = "",
            java_mem = "5G",
            mem = "7G",
            partition = "normal"
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} CollectHsMetrics"
            " -Xmx{resources.java_mem}"
            " {params.extra}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " INPUT={input.alignments}"
            " REFERENCE_SEQUENCE={input.reference_seq}"
            " BAIT_INTERVALS={input.baits_intervals}"
            " TARGET_INTERVALS={input.targets_intervals}"
            " OUTPUT={output}"
            " {params.stderr_redirection} {log}"
