__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def addAmpliRG(
        in_alignments="aln/{sample}.bam",
        in_panel="design/targets.bed",
        out_alignments="aln/{sample}_RG.bam",
        out_summary="stats/aln/{sample}.json",
        out_stderr="logs/aln/{sample}_RG_stderr.txt",
        params_anchor_offset=None,
        params_check_strand=None,
        params_keep_outputs=False,
        params_min_zoi_cov=None,
        params_RG_tag=None,
        params_single_mode=False,
        params_stderr_append=False,
        params_summary_format="json"):
    """Add RG corresponding to the amplicons panel. For one reads pair the amplicon is determined from the position of the first match position of the two reads (primers start positions)."""
    rule addAmpliRG:
        input:
            alignments = in_alignments,
            alignments_index = in_alignments + ".bai",
            panel = in_panel
        output:
            alignments = out_alignments if params_keep_outputs else temp(out_alignments),
            summary = out_summary if params_keep_outputs else temp(out_summary)
        log:
            out_stderr
        params:
            anchor_offset = "" if params_anchor_offset is None else "--anchor-offset " + str(params_anchor_offset),
            bin_path = config.get("software_paths", {}).get("addAmpliRG", "addAmpliRG.py"),
            check_strand = "--check-strand" if params_check_strand else "",
            min_zoi_cov = "" if params_min_zoi_cov is None else "--min-zoi-cov " + str(params_min_zoi_cov),
            RG_tag = "" if params_RG_tag is None else "--RG-tag '" + params_RG_tag + "'",
            single_mode = "--single-mode" if params_single_mode else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            summary_format = params_summary_format
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.check_strand}"
            " {params.anchor_offset}"
            " {params.min_zoi_cov}"
            " {params.RG_tag}"
            " {params.single_mode}"
            " --summary-format {params.summary_format}"
            " --input-aln {input.alignments}"
            " --input-panel {input.panel}"
            " --output-aln {output.alignments}"
            " --output-summary {output.summary}"
            " {params.stderr_redirection} {log}"
