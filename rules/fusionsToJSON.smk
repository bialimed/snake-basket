__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def fusionsToJSON(
        in_variants="structural_variants/{sample}_filtered.vcf",
        out_variants="structural_variants/{sample}_fusions.json",
        out_stderr="logs/structural_variants/{sample}_2json_stderr.txt",
        params_annot_field=None,
        params_assembly_id=None,
        params_merged_sources=False,
        params_calling_source="Unknown",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Convert fusions VCF to JSON format."""
    rule fusionsToJSON:
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annot_field = "--annotation-field " + params_annot_field if params_annot_field is not None else "",
            assembly_id = "--assembly-id " + params_assembly_id if params_assembly_id is not None else "",
            bin_path = config.get("software_pathes", {}).get("fusionsToJSON", "fusionsToJSON.py"),
            calling_source = "--calling-source " + params_calling_source if params_calling_source and not params_merged_sources else "",
            merged_sources = "--merged-sources" if params_merged_sources else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.assembly_id}"
            " {params.calling_source}"
            " {params.merged_sources}"
            " {params.annot_field}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
