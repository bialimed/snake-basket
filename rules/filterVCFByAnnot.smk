__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def filterVCFByAnnot(
        in_selected_rna=None,
        in_variants="variants/{variant_caller}/{sample}_annot.vcf",
        out_variants="variants/{variant_caller}/{sample}_annot_tagByAnnot.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterByAnnot_stderr.txt",
        params_annotation_field=None,
        params_kept_consequences=None,
        params_polym_populations=None,
        params_polym_threshold=None,
        params_rna_with_version=False,
        params_remove=False,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Filter variants and their annotations on annotations."""
    rule filterVCFByAnnot:
        input:
            selected_rna = ([] if in_selected_rna is None else in_selected_rna),
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotation_field = "" if params_annotation_field is None else "--annotation-field " + params_annotation_field,
            bin_path = config.get("software_paths", {}).get("filterVCFByAnnot", "filterVCFByAnnot.py"),
            kept_consequences = "" if params_kept_consequences is None else "--kept-consequences " + " ".join(params_kept_consequences),
            mode = "remove" if params_remove else "tag",
            polym_populations = "" if params_polym_populations is None else "--polym-populations " + " ".join(params_polym_populations),
            polym_threshold = "" if params_polym_threshold is None else "--polym-threshold " + str(params_polym_threshold),
            rna_without_version = "" if params_rna_with_version is None or params_rna_with_version else "--rna-without-version",
            selected_rna = "" if in_selected_rna is None else "--input-selected-RNA " + in_selected_rna,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --mode {params.mode}"
            " {params.annotation_field}"
            " {params.kept_consequences}"
            " {params.polym_populations}"
            " {params.polym_threshold}"
            " {params.rna_without_version}"
            " {params.selected_rna}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
