__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.5.0'


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
        params_spliced_aln=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Group variants occuring in same reads."""
    # Parameters
    in_alignments_index = in_alignments[:-4] + ".bai"
    if isinstance(in_alignments, snakemake.io.AnnotatedString) and "storage_object" in in_alignments.flags:
        in_alignments_index = storage(in_alignments.flags["storage_object"].query[:-4] + ".bai")
    in_sequences_index = in_sequences + ".fai"
    if isinstance(in_sequences, snakemake.io.AnnotatedString) and "storage_object" in in_sequences.flags:
        in_sequences_index = storage(in_sequences.flags["storage_object"].query + ".fai")
    # Rule
    rule:
        name:
            "mergeCoOccurVar" + snake_rule_suffix
        input:
            alignments = in_alignments,
            alignments_index = in_alignments_index,
            sequences = in_sequences,
            sequences_index = in_sequences_index,
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
            spliced_aln = "" if params_spliced_aln is None else "--spliced-aln",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.intersection_rate}"
            " {params.intersection_count}"
            " {params.AF_diff_rate}"
            " {params.max_distance}"
            " {params.spliced_aln}"
            " --input-aln {input.alignments}"
            " --input-sequences {input.sequences}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
