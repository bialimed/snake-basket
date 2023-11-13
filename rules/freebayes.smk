__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def freebayes(
        in_alignments="aln/delDup/{sample}.bam",
        in_reference_seq="data/reference.fa",
        in_targets="data/targets.bed",
        out_variants="variants/freebayes/{sample}_call.vcf",
        out_stderr="logs/variants/freebayes/{sample}_call_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_min_base_qual=0,
        params_min_alt_count=4,
        params_min_alt_fraction=0.03,
        params_ploidy=2,
        params_stderr_append=False):
    """Bayesian haplotype-based genetic polymorphism discovery and genotyping."""
    rule freebayes:
        input:
            alignments = in_alignments,
            reference = in_reference_seq,
            targets = ([] if in_targets is None else in_targets)
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("freebayes", "freebayes"),
            extra = params_extra,
            min_alt_count = params_min_alt_count,
            min_alt_fraction = params_min_alt_fraction,
            min_base_qual = params_min_base_qual,
            ploidy = params_ploidy,
            targets = "" if in_targets is None else "--targets " + in_targets,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/freebayes.yml"
        shell:
            "{params.bin_path}"
            " --min-base-quality {params.min_base_qual}"
            " --min-alternate-count {params.min_alt_count}"
            " --min-alternate-fraction {params.min_alt_fraction}"
            " --ploidy {params.ploidy}"
            " {params.targets}"
            " {params.extra}"
            " --fasta-reference {input.reference}"
            " --bam {input.alignments}"
            " > {output}"
            " {params.stderr_redirection} {log}"
