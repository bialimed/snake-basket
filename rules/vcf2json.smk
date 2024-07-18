__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def vcf2json(
        in_variants="variants/{variant_caller}/{sample}_filtered.vcf",
        out_variants="variants/{variant_caller}/{sample}_variants.json",
        out_stderr="logs/variants/{variant_caller}/{sample}_2json_stderr.txt",
        params_annot_field=None,
        params_assembly_id=None,
        params_pathogenicity_fields=None,
        params_populations_prefixes=None,
        params_merged_sources=False,
        params_calling_source="{variant_caller}",  # Use "" instead to inactivate
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Convert VCF annotated to JSON format."""
    rule:
        name:
            "vcf2json" + snake_rule_suffix
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annot_field = "--annotation-field " + params_annot_field if params_annot_field is not None else "",
            assembly_id = "--assembly-id " + params_assembly_id if params_assembly_id is not None else "",
            bin_path = config.get("software_paths", {}).get("VCFToJSON", "VCFToJSON.py"),
            calling_source = "--calling-source " + params_calling_source if params_calling_source else "",
            merged_sources = "--merged-sources" if params_merged_sources else "",
            pathogenicity_fields = "--pathogenicity-fields " + " ".join(params_pathogenicity_fields) if params_pathogenicity_fields is not None else "",
            populations_prefixes = "--populations-prefixes " + " ".join(params_populations_prefixes) if params_populations_prefixes is not None else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.assembly_id}"
            " {params.pathogenicity_fields}"
            " {params.populations_prefixes}"
            " {params.calling_source}"
            " {params.merged_sources}"
            " {params.annot_field}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
