__author__ = 'Veronique Ivashchenko and Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def mergeVCFFusionsCallers(
        in_variants,
        out_variants="structural_variants/{sample}.vcf",
        out_stderr="logs/{sample}_mergeVCF_stderr.txt",
        params_annotation_field=None,
        params_calling_sources=None,
        params_shared_filters=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Merge VCF coming from different fusions caller on same sample(s). It is strongly recommended to apply this script before annotation and filtering/tagging."""
    if params_calling_sources is None:
        raise Exception("At least one value must be provided for params_calling_sources.")
    rule mergeVCFFusionsCallers:
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotation_field = "" if params_annotation_field is None else "--annotation-field " + params_annotation_field,
            bin_path = config.get("software_pathes", {}).get("mergeVCFFusionsCallers", "mergeVCFFusionsCallers.py"),
            calling_sources = "--calling-sources " + " ".join(params_calling_sources),
            shared_filters = "" if params_shared_filters is None else "--shared-filters " + " ".join(params_shared_filters),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        # conda:
        #     "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.annotation_field}"
            " {params.calling_sources}"
            " {params.shared_filters}"
            " --inputs-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
