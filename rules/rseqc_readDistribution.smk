__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'


def rseqc_readDistribution(
        in_annotations="reference/genome_genes.bed",
        in_alignments="aln/{sample}.bam",
        out_metrics="stats/reseqc/{sample}_readDistribution.tsv",
        out_stderr="logs/reseqc/{sample}_readDistribution_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Calculate how mapped reads were distributed over genome feature (like CDS exon, 5’UTR exon, 3’ UTR exon, Intron, Intergenic regions)."""
    rule:
        name:
            "rseqc_readDistribution" + snake_rule_suffix
        input:
            annotations = in_annotations,
            alignments = in_alignments
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("read_distribution", "read_distribution.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/rseqc.yml"
        shell:
            "{params.bin_path}"
            " --refgene {input.annotations}"
            " --input-file {input.alignments}"
            " > {output}"
            " {params.stderr_redirection} {log}"
