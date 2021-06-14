__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def mergeVCFCallers(
        params_calling_sources,
        in_variants,
        out_variants="variants/{sample}_allCallers.vcf",
        out_stderr="logs/variants/{sample}_allCallers_stderr.txt",
        params_annotation_field=None,
        params_shared_filters=["OOT", "homoP", "popAF", "CSQ", "ANN.COLLOC", "ANN.RNA", "ANN.popAF", "ANN.CSQ"],
        params_keep_outputs=False,
        params_stderr_append=False):
    """Merge VCF coming from different calling on same sample(s). It is strongly recommended to apply this script after standardization and before annotation and filtering/tagging."""
    rule mergeVCFCallers:
        input:
            in_variants,
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("mergeVCFCallers", "mergeVCFCallers.py"),
            annotation_field = "" if params_annotation_field is None else "--annotations-field " + params_annotation_field,
            calling_sources = " ".join(params_calling_sources),
            shared_filters = "--shared-filters " + " ".join(params_shared_filters) if params_shared_filters else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.shared_filters}"
            " {params.annotation_field}"
            " --calling-sources {params.calling_sources}"
            " --inputs-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
