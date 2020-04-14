__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def shallowsAnalysis(
        in_alignments="aln/markDup/{sample}.bam",
        in_reference_annotations="data/reference.gtf",
        in_targets=None,
        in_known_variants=None,  # For example COSMIC
        out_shallows="stats/depth/{sample}_shallowAreas.gff3",
        out_stderr="logs/stats/depth/{sample}_shallowAreas_stderr.txt",
        params_expected_min_depth=None,
        params_depth_mode=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Extract shallow areas from the alignment are annotate them with genomic features and known variants."""
    rule shallowsAnalysis:
        input:
            alignments = in_alignments,
            reference_annotations = in_reference_annotations,
            targets = [] if in_targets is None else in_targets,
            known_variants = [] if in_known_variants is None else in_known_variants
        output:
            out_shallows if params_keep_outputs else temp(out_shallows)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("shallowsAnalysis", "shallowsAnalysis.py"),
            depth_mode = "" if params_depth_mode is None else "--depth-mode " + params_depth_mode,
            expected_min_depth = "" if params_expected_min_depth is None else "--min-depth " + str(params_expected_min_depth),
            known_variants = "" if in_known_variants is None else "--inputs-variants " + in_known_variants,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            targets = "" if in_targets is None else "--input-targets " + in_targets
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.expected_min_depth}"
            " {params.depth_mode}"
            " {params.targets}"
            " {params.known_variants}"
            " --input-aln {input.alignments}"
            " --input-annotations {input.reference_annotations}"
            " --output-shallow {output}"
            " {params.stderr_redirection} {log}"