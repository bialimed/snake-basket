__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def fixHGVS(
        in_assembly_accessions,
        in_variants="variants/{sample}_annot.vcf",
        out_variants="variants/{sample}_annot_fixHGVS.vcf",
        out_stderr="logs/variants/{sample}_annot_fixHGVS_stderr.txt",
        params_annotations_field=None,
        params_assembly_version=None,
        params_keep_outputs=False,
        params_mutalyzer_url=None,
        params_proxy_url=None,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Fix or add HGVSg, HGVSc and HGVSp on variants annotations. The HGVS used are based on mutalyzer."""
    rule:
        name:
            "fixHGVS" + snake_rule_suffix
        input:
            assembly_accessions = in_assembly_accessions,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = "--annotations-field " + params_annotations_field if params_annotations_field else "",
            assembly_accessions = "--input-assembly-accessions " + in_assembly_accessions if in_assembly_accessions else "",
            assembly_version = "--assembly-version " + params_assembly_version if params_assembly_version else "",
            bin_path = config.get("software_paths", {}).get("fixHGVSMutalyzer", "fixHGVSMutalyzer.py"),
            mutalyzer_url = "--mutalyzer-url " + params_mutalyzer_url if params_mutalyzer_url else "",
            proxy_url = "--proxy-url " + params_proxy_url if params_proxy_url else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.annotations_field}"
            " {params.assembly_version}"
            " {params.mutalyzer_url}"
            " {params.proxy_url}"
            " {params.assembly_accessions}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
