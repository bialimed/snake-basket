__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def ampliVariantCalling(
        in_alignments="aln/{sample}_RG.bam",
        in_design_with_primers="design/targets.bed",
        in_design_wout_primers="design/targets_woutPrimers.bed",
        in_non_overlapping_design="design/non_overlapping.tsv",
        in_reference_seq="data/reference.fasta",
        out_variants="variants/{sample}.vcf",
        out_stderr="logs/variants/{sample}_call_stderr.txt",
        params_keep_outputs=False,
        params_library_name="{sample}",
        params_min_alt_count=None,
        params_min_alt_fraction=None,
        params_min_base_qual=None,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Variant calling on Illumina amplicon sequencing."""
    rule:
        name:
            "ampliVariantCalling" + snake_rule_suffix
        input:
            alignments = in_alignments,
            reference_seq = in_reference_seq,
            design_with_primers = in_design_with_primers,
            design_wout_primers = in_design_wout_primers,
            non_overlapping_design = in_non_overlapping_design,
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("ampliVariantCalling", "ampliVariantCalling.py"),
            library_name = "" if params_library_name is None else "--library-name '" + params_library_name + "'",
            min_alt_count = "" if params_min_alt_count is None else "--min-alt-count " + str(params_min_alt_count),
            min_alt_fraction = "" if params_min_alt_fraction is None else "--min-alt-freq " + str(params_min_alt_fraction),
            min_base_qual = "" if params_min_base_qual is None else "--min-base-qual " + str(params_min_base_qual),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "8G",
            partition = "normal"
        conda:
            "envs/vardict_amplicon.yml"
        shell:
            "{params.bin_path}"
            " {params.library_name}"
            " {params.min_alt_count}"
            " {params.min_alt_fraction}"
            " {params.min_base_qual}"
            " --input-aln {input.alignments}"
            " --input-genome {input.reference_seq}"
            " --input-design-with-primers {input.design_with_primers}"
            " --input-design-wout-primers {input.design_wout_primers}"
            " --input-non-overlapping-design {input.non_overlapping_design}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
