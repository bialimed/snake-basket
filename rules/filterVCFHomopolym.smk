__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def filterVCFHomopolym(
        in_reference="data/reference.fa",
        in_variants="variants/{variant_caller}/{sample}.vcf",
        out_variants="variants/{variant_caller}/{sample}_tagByHomop.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_filterByHomopolym_stderr.txt",
        params_homopolym_length=None,
        params_keep_outputs=False,
        params_tag_name=None,
        params_remove=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Filter the variants adjacents of homopolymers."""
    rule:
        name:
            "filterVCFHomopolym" + snake_rule_suffix
        input:
            reference = in_reference,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterVCFHomopolym", "filterVCFHomopolym.py"),
            homopolym_length = "" if params_homopolym_length is None else "--homopolym-length " + str(params_homopolym_length),
            mode = "remove" if params_remove else "tag",
            tag_name = "" if params_tag_name is None else "--tag-name " + params_tag_name,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --mode {params.mode}"
            " {params.homopolym_length}"
            " {params.tag_name}"
            " --input-reference {input.reference}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
