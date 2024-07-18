__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.4.0'


def vardict(
        in_alignments="aln/delDup/{sample}.bam",
        in_reference_seq="data/reference.fa",
        in_targets=None,  # config.get("targets")
        out_variants="variants/vardict/{sample}_call.vcf",
        out_stderr="logs/variants/vardict/{sample}_call_stderr.txt",
        params_extra="",
        params_keep_multiple_alt=True,
        params_min_alt_count=4,
        params_min_alt_fraction=0.33,
        params_min_base_qual=15,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """VarDict is an ultra sensitive variant caller for both single and paired sample variant calling from BAM files."""
    # Vardict
    rule:
        name:
            "vardict_call" + snake_rule_suffix
        input:
            alignments = in_alignments,
            reference = in_reference_seq,
            targets = ([] if in_targets is None else in_targets)
        output:
            temp(out_variants + "_tmpCall.tsv")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("vardict", "vardict-java"),
            min_alt_count = params_min_alt_count,
            min_alt_fraction = params_min_alt_fraction,
            min_base_qual = params_min_base_qual,
            targets = "" if in_targets is None else "--targets " + in_targets,
            extra = params_extra,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
            # -m If set, reads with mismatches more than INT will be filtered and ignored.  Gaps are not counted as mismatches. Valid only for bowtie2/TopHat or BWA aln followed by sampe.  BWA mem is calculated as NM - Indels. Default: 8
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/vardict.yml"
        shell:
            "{params.bin_path}"
            " -c 1 -S 2 -E 3 -g 4"
            " -r {params.min_alt_count}"
            " -f {params.min_alt_fraction}"
            " -q {params.min_base_qual}"
            " {params.extra}"
            " -G {input.reference}"
            " -b {input.alignments}"
            " {input.targets}"
            " > {output}"
            " {params.stderr_redirection} {log}"
    # Test strand bias
    rule:
        name:
            "vardict_strandbias" + snake_rule_suffix
        input:
            out_variants + "_tmpCall.tsv"
        output:
            temp(out_variants + "_tmpStrandBias.tsv")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("vardict_teststrandbias", "teststrandbias.R")
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/vardict.yml"
        shell:
            "cat {input} |"
            " {params.bin_path}"
            " > {output}"
            " 2>> {log}"
    # Variants to VCF
    rule:
        name:
            "vardict_var2vcf" + snake_rule_suffix
        input:
            out_variants + "_tmpStrandBias.tsv"
        output:
            temp(out_variants + "_tmpVar2vcf.vcf")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("vardict_var2vcf", "var2vcf_valid.pl"),
            keep_multiple_alt = "-A" if params_keep_multiple_alt else "",
            min_alt_fraction = params_min_alt_fraction,
            min_base_qual = params_min_base_qual,
            targets = "" if config.get("targets") is None else "--targets " + config["targets"],
            extra = params_extra
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/vardict.yml"
        shell:
            "cat {input} |"
            " {params.bin_path}"
            " -N '{wildcards.sample}'"
            " -E"
            " {params.keep_multiple_alt}"
            " -q {params.min_base_qual}"
            " -f {params.min_alt_fraction}"
            " > {output}"
            " 2>> {log}"
    # Fix VCF caller error in header
    rule:
        name:
            "vardict_fix" + snake_rule_suffix
        input:
            out_variants + "_tmpVar2vcf.vcf"
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("fixVCallerVCF", "fixVCallerVCF.py")
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --variant-caller vardict"
            " --input-variants {input}"
            " --output-variants {output}"
            " 2>> {log}"
