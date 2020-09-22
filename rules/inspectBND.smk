__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def inspectBND(
        in_alignments="aln/{sample}.bam",
        in_alignments_idx=None,
        in_annotations="reference/annot.gtf",
        in_domains=None,
        in_targets=None,
        in_variants="structural_variants/{sample}_annot.vcf",
        out_annotations="structural_variants/{sample}_annot_inspect.json",
        out_stderr="logs/structural_variants/{sample}_annot_inspect_stderr.txt",
        params_annotations_field=None,
        params_stranded=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Produce data to inspect fusions breakends."""
    if in_alignments_idx is None:
        in_alignments_idx = in_alignments[:-4] + ".bai"
    rule inspectBND:
        input:
            alignments = in_alignments,
            alignments_idx = in_alignments_idx,
            annotations = in_annotations,
            domains = [] if in_domains is None else in_domains,
            targets = [] if in_targets is None else in_targets,
            variants = in_variants
        output:
            out_annotations if params_keep_outputs else temp(out_annotations)
        log:
            out_stderr
        params:
            annotations_field = "" if params_annotations_field is None else "--annotation-field " + params_annotations_field,
            bin_path = config.get("software_pathes", {}).get("inspectBND", "inspectBND.py"),
            in_domains = "" if in_domains is None else "--input-domains " + in_domains,
            in_targets = "" if in_targets is None else "--input-targets " + in_targets,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stranded = "" if params_stranded is None else "--stranded " + params_stranded
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.annotations_field}"
            " {params.stranded}"
            " {params.in_domains}"
            " {params.in_targets}"
            " --input-alignments {input.alignments}"
            " --input-annotations {input.annotations}"
            " --input-variants {input.variants}"
            " --output-annotations {output}"
            " {params.stderr_redirection} {log}"
