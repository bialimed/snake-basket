__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.4.0'


def depthsPanel(
        in_alignments="aln/markDup/{sample}.bam",
        in_targets="data/user_panel.tsv",
        out_metrics="stats/depth/{sample}_depthsPanel.json",
        out_stderr="logs/stats/depth/{sample}_depthsPanel_stderr.txt",
        params_depth_mode=None,
        params_expected_min_depth=None,
        params_keep_outputs=False,
        params_min_base_qual=None,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Write depths distribution and number of nt below depth thresholds for each target."""
    # Parameters
    in_alignments_index = in_alignments[:-4] + ".bai"
    if isinstance(in_alignments, snakemake.io.AnnotatedString) and "storage_object" in in_alignments.flags:
        in_alignments_index = storage(in_alignments.flags["storage_object"].query[:-4] + ".bai")
    # Rule
    rule:
        name:
            "depthsPanel" + snake_rule_suffix
        input:
            alignments = in_alignments,
            alignments_index = in_alignments_index,
            targets = in_targets
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("depthsPanel", "depthsPanel.py"),
            depth_mode = "" if params_depth_mode is None else "--depth-mode " + params_depth_mode,
            expected_min_depth = "" if params_expected_min_depth is None else "--min-depths " + " ".join(map(str, params_expected_min_depth)),
            min_base_qual = "" if params_min_base_qual is None else "--min-base-qual " + str(params_min_base_qual),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.expected_min_depth}"
            " {params.depth_mode}"
            " {params.min_base_qual}"
            " --input-aln {input.alignments}"
            " --input-targets {input.targets}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
