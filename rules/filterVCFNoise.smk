__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def filterVCFNoise(
        in_known_artifacts,
        in_variants="variants/{variant_caller}/{sample}_annot.vcf",
        out_variants="variants/{variant_caller}/{sample}_annot_tagOnArtifacts.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterNoise_stderr.txt",
        params_keep_outputs=False,
        params_remove=False,
        params_tag_name="popConst",
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Filter artifact variants."""
    rule:
        name:
            "filterVCFNoise" + snake_rule_suffix
        input:
            variants = in_variants,
            known_artifacts = in_known_artifacts
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterVCFNoise", "filterVCFNoise.py"),
            mode = "--remove" if params_remove else "--tag",
            tag_name = params_tag_name,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --tag-name {params.tag_name}"
            " --input-variants {input.variants}"
            " --input-noises {input.known_artifacts}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
