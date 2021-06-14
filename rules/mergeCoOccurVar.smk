__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def mergeCoOccurVar(
        in_alignments="aln/delDup/{sample}.bam",
        in_sequences="data/reference.fa",
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        out_variants="variants/{variant_caller}/{sample}_mergedCoOccur.vcf",
        out_stderr="logs/variants/{variant_caller}/{sample}_mergeCoOccurVariants_stderr.txt",
        params_AF_diff_rate=None,
        params_intersection_count=None,
        params_intersection_rate=None,
        params_max_distance=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Group variants occuring in same reads."""
    rule mergeCoOccurVar:
        input:
            alignments = in_alignments,
            sequences = in_sequences,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            AF_diff_rate = "" if params_AF_diff_rate is None else "--AF-diff-rate " + str(params_AF_diff_rate),
            bin_path = config.get("software_paths", {}).get("mergeCoOccurVar", "mergeCoOccurVar.py"),
            intersection_count = "" if params_intersection_count is None else "--intersection-count " + str(params_intersection_count),
            intersection_rate = "" if params_intersection_rate is None else "--intersection-rate " + str(params_intersection_rate),
            max_distance = "" if params_max_distance is None else "--max-distance " + str(params_max_distance),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.intersection_rate}"
            " {params.intersection_count}"
            " {params.AF_diff_rate}"
            " {params.max_distance}"
            " --input-aln {input.alignments}"
            " --input-sequences {input.sequences}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
