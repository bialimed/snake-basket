__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '3.1.0'

include: "gatk4_learnReadOrientationModel.smk"


def gatk4_mutect2(
        in_reference_seq="data/reference.fa",
        in_tumoral_aln="aln/gatk_recal/{sample}_BQSR.bam",
        in_pon_variants=None,
        in_germline_variants=None,
        out_variants="variants/mutect2/{sample}_call.vcf",
        out_stderr="logs/variants/mutect2/{sample}_call_stderr.txt",
        params_keep_outputs=False,
        params_min_base_qual=15,
        params_min_alt_count=4,
        params_min_alt_fraction=0.03,
        params_stderr_append=False,
        params_tag_strand_bias=False,
        snake_rule_suffix=""):
    """Call somatic SNPs and indels via local re-assembly of haplotypes."""
    # Filter supplementals to prevent mutect2 error with version 4.1.4.[0-1] (see: https://github.com/broadinstitute/gatk/issues/6310)
    rule:
        name:
            "mutect2_filterSupplementals" + snake_rule_suffix
        input:
            tumoral_aln = in_tumoral_aln
        output:
            aln = temp(out_variants + "_filteredTmp.bam"),
            index = temp(out_variants + "_filteredTmp.bam.bai")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("samtools", "samtools"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path} view"
            " -h"
            " -b"
            " -F 2048"
            " {input.tumoral_aln}"
            " > {output.aln}"
            " {params.stderr_redirection} {log}"
            " &&"
            " {params.bin_path} index"
            " {output.aln}"
            " 2>> {log}"

    # Variant calling
    rule:
        name:
            "mutect2" + snake_rule_suffix
        input:
            reference_seq = in_reference_seq,
            tumoral_aln = out_variants + "_filteredTmp.bam",
            tumoral_bai = out_variants + "_filteredTmp.bam.bai",
            pon_variants = ([] if in_pon_variants is None else in_pon_variants),
            germline_variants = ([] if in_germline_variants is None else in_germline_variants)
        output:
            variants = temp(out_variants + "_initTmp.vcf"),
            f1r2 = ([] if not params_tag_strand_bias else temp(out_variants + "_f1r2.tar.gz"))
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gatk", "gatk"),
            f1r2 = "--f1r2-tar-gz " + out_variants + "_f1r2.tar.gz" if params_tag_strand_bias else "",
            germline_variants = "" if in_germline_variants is None else "--germline-resource " + in_germline_variants,
            min_base_qual = params_min_base_qual,
            pon_variants = "" if in_pon_variants is None else "--panel-of-normals " + in_pon_variants,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "15G",
            partition = "normal"
        threads: 2  # Should not be lower
        conda:
            "envs/gatk4.yml"
        shell:
            "{params.bin_path} Mutect2"
            " --native-pair-hmm-threads {threads}"
            " --tumor-sample {wildcards.sample}"
            " --min-base-quality-score {params.min_base_qual}"
            " {params.f1r2}"
            " --reference {input.reference_seq}"
            " {params.germline_variants}"
            " {params.pon_variants}"
            " --input {input.tumoral_aln}"
            " --output {output.variants}"
            " 2>> {log}"

    if params_tag_strand_bias:
        gatk4_learnReadOrientationModel(
            in_alternatives_table=out_variants + "_f1r2.tar.gz",
            out_model=out_variants + "_strandModel.tar.gz",
            snake_rule_suffix=snake_rule_suffix
        )

    rule:
        name:
            "filterMutectCalls" + snake_rule_suffix
        input:
            reference_seq = in_reference_seq,
            variants = out_variants + "_initTmp.vcf",
            strand_model = ([] if not params_tag_strand_bias else params_tag_strand_bias + "_strandModel.tar.gz")
        output:
            index = temp(out_variants + "_initTmp_filterTmp.vcf.idx"),
            stats = temp(out_variants + "_initTmp_filterTmp.vcf.filteringStats.tsv"),
            variants = temp(out_variants + "_initTmp_filterTmp.vcf")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gatk", "gatk"),
            strand_model = ("" if not params_tag_strand_bias else "--orientation-bias-artifact-priors " + params_tag_strand_bias + "_strandModel.tar.gz")
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/gatk4.yml"
        shell:
            "{params.bin_path} FilterMutectCalls"
            " {params.strand_model}"
            " --reference {input.reference_seq}"
            " --variant {input.variants}"
            " --output {output.variants}"
            " 2>> {log}"
    # --max-alt-allele-count 1 default

    # Split multi-alternative variants in sevrel records
    rule:
        name:
            "mutect2_splitVCFAlt" + snake_rule_suffix
        input:
            out_variants + "_initTmp_filterTmp.vcf"
        output:
            temp(out_variants + "_oneLine.vcf")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("splitVCFAlt", "splitVCFAlt.py")
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --input-variants {input}"
            " --output-variants {output}"
            " 2>> {log}"

    # Filter variants on AD and AF
    rule:
        name:
            "mutect2_filterByCount" + snake_rule_suffix
        input:
            out_variants + "_oneLine.vcf"
        output:
            variants = out_variants if params_keep_outputs else temp(out_variants),
            filters = temp(out_variants + "_filters.json")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterVCF", "filterVCF.py"),
            filters = '{"class":"FiltersCombiner","operator":"and","filters":[{"class":"Filter","getter":"m:getPopAltAD","aggregator":"ratio:1","operator":">=","values":' + str(params_min_alt_count) + '},{"class":"Filter","getter":"m:getPopAltAF","aggregator":"ratio:1","operator":">=","values":' + str(params_min_alt_fraction) + '}]}'
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "echo '{params.filters}' > {output.filters}"
            " && "
            "{params.bin_path}"
            " --input-filters {output.filters}"
            " --input-variants {input}"
            " --output-variants {output.variants}"
            " 2>> {log}"
