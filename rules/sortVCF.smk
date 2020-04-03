__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def sortVCF(
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        out_variants="variants/{variant_caller}/{sample}_sorted.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_sort_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Sorts VCF by coordinates."""
    rule sortVCF:
        input:
            in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("sortVCF", "sortVCF.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --input-variants {input}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
