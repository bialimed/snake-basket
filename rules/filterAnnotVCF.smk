__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def filterAnnotVCF(
        in_filters_annotations=None,
        in_filters_variants=None,
        in_variants="variants/{variant_caller}/{sample}_annot_tagByAnnot.vcf",
        out_variants="variants/{variant_caller}/{sample}_filtered.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterAnnot_stderr.txt",
        params_annotation_field=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Filter VCF variants and annotations on criteria described in JSON files."""
    rule filterAnnotVCF:
        input:
            filters_annotations = ([] if in_filters_annotations is None else in_filters_annotations),
            filters_variants = ([] if in_filters_variants is None else in_filters_variants),
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterAnnotVCF", "filterAnnotVCF.py"),
            annotation_field = "" if params_annotation_field is None else "--annotation-field " + params_annotation_field,
            filters_annotations = "" if in_filters_annotations is None else "--input-filters-annotations " + in_filters_annotations,
            filters_variants = "" if in_filters_variants is None else "--input-filters-variants " + in_filters_variants,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.annotation_field}"
            " {params.filters_annotations}"
            " {params.filters_variants}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
