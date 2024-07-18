__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '3.2.0'

include: "sortVCF.smk"


def standardizeVCF(
        in_variants="variants/{variant_caller}/{sample}_filtered.vcf",
        in_reference_seq="data/reference.fa",
        out_variants="variants/{variant_caller}/{sample}_filtered_std.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_std_stderr.txt",
        params_annotations_field=None,
        params_trace_unstandard=False,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Split alternatives alleles in multi-lines and removes unecessary reference and alternative nucleotids, move indel to most upstream position and update alt allele in annotations."""
    # Standardize VCF
    rule:
        name:
            "standardizeVCF" + snake_rule_suffix
        input:
            reference_seq = in_reference_seq,
            variants = in_variants
        output:
            temp(out_variants + ".std_tmp")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("standardizeVCF", "standardizeVCF.py"),
            annotations_field = "--annotations-field " + params_annotations_field if params_annotations_field else "",
            trace_unstandard = "--trace-unstandard" if params_trace_unstandard else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.trace_unstandard}"
            " {params.annotations_field}"
            " --input-reference {input.reference_seq}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
    # Sort VCF
    sortVCF(
        in_variants=out_variants + ".std_tmp",
        out_variants=out_variants,
        out_stderr=out_stderr,
        params_keep_outputs=params_keep_outputs,
        params_stderr_append=True,
        snake_rule_suffix=snake_rule_suffix
    )
