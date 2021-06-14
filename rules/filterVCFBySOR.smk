__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def filterVCFBySOR(
        in_variants="variants/{variant_caller}/{sample}.vcf",
        out_variants="variants/{variant_caller}/{sample}_tagSOR.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_tagSOR_stderr.txt",
        params_keep_outputs=False,
        params_mode="tag",
        params_stderr_append=False,
        params_bias_tag="strandRatioBias",
        params_SOR_tag="SOR",
        params_indel_max_SOR=None,
        params_substit_max_SOR=None,
        params_ref_fwd_tag=None,
        params_ref_rev_tag=None,
        params_alt_fwd_tag=None,
        params_alt_rev_tag=None):
    """Add snakemake rule to filter VCF by strand odd ratio."""
    rule filterVCFBySOR:
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            stderr = out_stderr
        params:
            alt_fwd_tag = "--alt-fwd-tag " + params_alt_fwd_tag if params_alt_fwd_tag is not None else "",
            alt_rev_tag = "--alt-rev-tag " + params_alt_rev_tag if params_alt_rev_tag is not None else "",
            bias_tag = "--bias-tag " + params_bias_tag if params_bias_tag is not None else "",
            bin_path = config.get("software_paths", {}).get("filterVCFBySOR", "filterVCFBySOR.py"),
            indel_max_SOR = "--indel-max-SOR " + params_indel_max_SOR if params_indel_max_SOR is not None else "",
            mode = params_mode,
            ref_fwd_tag = "--ref-fwd-tag " + params_ref_fwd_tag if params_ref_fwd_tag is not None else "",
            ref_rev_tag = "--ref-rev-tag " + params_ref_rev_tag if params_ref_rev_tag is not None else "",
            SOR_tag = "--SOR-tag " + params_SOR_tag if params_SOR_tag is not None else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            substit_max_SOR = "--substit-max-SOR " + params_substit_max_SOR if params_substit_max_SOR is not None else ""
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.bias_tag}"
            " {params.SOR_tag}"
            " {params.indel_max_SOR}"
            " {params.substit_max_SOR}"
            " {params.ref_fwd_tag}"
            " {params.ref_rev_tag}"
            " {params.alt_fwd_tag}"
            " {params.alt_rev_tag}"
            " --mode {params.mode}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log.stderr}"
