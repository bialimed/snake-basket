__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def splitVCFAlt(
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        out_variants="variants/{variant_caller}/{sample}_call_splitAlt.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_splitAlt_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Split multiple alternatives variants in one line by alternative."""
    rule splitVCFAlt:
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("splitVCFAlt", "splitVCFAlt.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
