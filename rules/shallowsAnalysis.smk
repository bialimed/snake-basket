__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.6.0'


def shallowsAnalysis(
        in_alignments="aln/markDup/{sample}.bam",
        in_reference_annotations="data/reference.gtf",
        in_targets=None,
        in_known_variants=None,  # For example COSMIC
        out_genes=None,
        out_shallows="stats/depth/{sample}_shallowAreas.gff3",
        out_stderr="logs/stats/depth/{sample}_shallowAreas_stderr.txt",
        params_depth_mode=None,
        params_expected_min_depth=None,
        params_known_count_field=None,
        params_known_hgvsc_field=None,
        params_known_hgvsp_field=None,
        params_known_min_count=None,
        params_known_symbol_field=None,
        params_min_base_qual=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Extract shallow areas from the alignment are annotate them with genomic features and known variants."""
    rule:
        name:
            "shallowsAnalysis" + snake_rule_suffix
        input:
            alignments = in_alignments,
            reference_annotations = in_reference_annotations,
            targets = [] if in_targets is None else in_targets,
            known_variants = [] if in_known_variants is None else in_known_variants
        output:
            areas = out_shallows if params_keep_outputs else temp(out_shallows),
            genes = [] if out_genes is None else (out_genes if params_keep_outputs else temp(out_genes)),
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("shallowsAnalysis", "shallowsAnalysis.py"),
            depth_mode = "" if params_depth_mode is None else "--depth-mode " + params_depth_mode,
            expected_min_depth = "" if params_expected_min_depth is None else "--min-depth " + str(params_expected_min_depth),
            known_count_field = "" if params_known_count_field is None else "--known-count-field " + params_known_count_field,
            known_hgvsc_field = "" if params_known_hgvsc_field is None else "--known-hgvsc-field " + params_known_hgvsc_field,
            known_hgvsp_field = "" if params_known_hgvsp_field is None else "--known-hgvsp-field " + params_known_hgvsp_field,
            known_min_count = "" if params_known_min_count is None else "--known-min-count " + str(params_known_min_count),
            known_symbol_field = "" if params_known_symbol_field is None else "--known-symbol-field " + params_known_symbol_field,
            known_variants = "" if in_known_variants is None else "--inputs-variants " + in_known_variants,
            min_base_qual = "" if params_min_base_qual is None else "--min-base-qual " + str(params_min_base_qual),
            out_genes = "" if out_genes is None else "--output-genes " + out_genes,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            targets = "" if in_targets is None else "--input-targets " + in_targets
        resources:
            extra = "",
            mem = "15G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.expected_min_depth}"
            " {params.depth_mode}"
            " {params.known_count_field}"
            " {params.known_hgvsc_field}"
            " {params.known_hgvsp_field}"
            " {params.known_min_count}"
            " {params.known_symbol_field}"
            " {params.known_variants}"
            " {params.min_base_qual}"
            " {params.out_genes}"
            " {params.targets}"
            " --input-aln {input.alignments}"
            " --input-annotations {input.reference_annotations}"
            " --output-shallow {output.areas}"
            " {params.stderr_redirection} {log}"
