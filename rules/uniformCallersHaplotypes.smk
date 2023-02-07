__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def uniformCallersHaplotypes(
        in_variants,  # variants/*/{sample}_call_std.vcf
        in_haplotyped_variants,  # variants/*/{sample}_call_std_haplotyped.vcf
        out_variants,  # variants/*/{sample}_call_std_uniformHaplo.vcf
        params_calling_sources,
        out_stderr="logs/variants/{sample}_call_std_uniformHaplo_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Merge or split co-occuring variants to ensure cohesion between callers."""
    rule uniformCallersHaplotypes:
        input:
            haplotyped_variants = in_haplotyped_variants,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("uniformCallersHaplotypes", "uniformCallersHaplotypes.py"),
            calling_sources = " ".join(params_calling_sources),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "6G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --calling-sources {params.calling_sources}"
            " --inputs-haplotyped {input.haplotyped_variants}"
            " --inputs-variants {input.variants}"
            " --outputs-variants {output}"
            " {params.stderr_redirection} {log}"
