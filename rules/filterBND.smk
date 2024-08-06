__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.5.0'


def filterBND(
        in_annotations="reference/annot.gtf",
        in_normal=None,
        in_variants="structural_variants/{sample}_annot.vcf",
        out_variants="structural_variants/{sample}_annot_tag.vcf",
        out_stderr="logs/structural_variants/{sample}_filterBND_stderr.txt",
        params_annotations_field=None,  # tag or filter
        params_keep_outputs=False,
        params_min_support=None,
        params_mode=None,
        params_normal_key=None,  # id or symbol
        params_normal_sources=None,
        params_rt_max_dist=None,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Filter fusions that are readthrough, within a gene, known in normal samples or occuring on HLA or IG."""
    rule:
        name:
            "filterBND" + snake_rule_suffix
        input:
            annotations = in_annotations,
            normal = [] if in_normal is None else in_normal,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = "" if params_annotations_field is None else "--annotation-field " + params_annotations_field,
            bin_path = config.get("software_paths", {}).get("filterBND", "filterBND.py"),
            input_normal = "" if in_normal is None else "--inputs-normal " + " ".join(in_normal),
            min_support = "" if params_min_support is None else "--min-support " + str(params_min_support),
            mode = "" if params_mode is None else "--mode " + params_mode,
            normal_key = "" if params_normal_key is None else "--normal-key '" + params_normal_key + "'",
            normal_sources = "" if params_normal_sources is None else "--normal-sources '" + params_normal_sources + "'",
            rt_max_dist = "" if params_rt_max_dist is None else "--rt-max-dist " + str(params_rt_max_dist),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "6G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.mode}"
            " {params.annotations_field}"
            " {params.normal_key}"
            " {params.normal_sources}"
            " {params.min_support}"
            " {params.rt_max_dist}"
            " --input-annotations {input.annotations}"
            " {params.input_normal}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
