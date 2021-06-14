__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'

include: "freebayes.smk"


def somaticFreebayes(
        in_alignments="aln/delDup/{sample}.bam",
        in_reference_seq="data/reference.fa",
        in_targets="data/targets.bed",
        out_variants="variants/freebayes/{sample}_call.vcf",
        out_stderr="logs/variants/freebayes/{sample}_call_stderr.txt",
        params_extra="",
        params_min_base_qual=0,
        params_min_alt_count=4,
        params_min_alt_fraction=0.03,
        params_ploidy=2,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Bayesian haplotype-based genetic polymorphism discovery and genotyping."""
    # FreeBayes
    freebayes(
        in_alignments=in_alignments,
        in_reference_seq=in_reference_seq,
        in_targets=in_targets,
        out_variants=out_variants + "_callGermline.tmp",
        out_stderr=out_stderr,
        params_extra=params_extra,
        params_min_base_qual=params_min_base_qual,
        params_min_alt_count=params_min_alt_count,
        params_min_alt_fraction=params_min_alt_fraction,
        params_ploidy=params_ploidy,
        params_stderr_append=True
    )
    # Clean germline fields
    rule freebayesToSomatic:
        input:
            out_variants + "_callGermline.tmp"
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("freebayesToSomatic", "freebayesToSomatic.py")
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " --input-variants {input}"
            " --output-variants {output}"
            " 2>> {log}"
