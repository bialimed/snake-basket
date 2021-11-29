__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def groupReadsByUMI(
        in_alignments="aln/{sample}.bam",
        out_alignments="aln/umi/group/{sample}.bam",
        out_metrics="stats/gpByUMI/{sample}.tsv",
        out_stderr="logs/aln/{sample}_gpByUMI_stderr.txt",
        params_allow_inter_contig=False,
        params_max_edits=1,
        params_min_mapq=30,
        params_strategy="adjacency",
        params_umi_tag="RX",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Groups reads together that appear to have come from the same original molecule."""
    rule groupReadsByUMI:
        input:
            in_alignments
        output:
            alignments = out_alignments if params_keep_outputs else temp(out_alignments),
            metrics = out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            allow_inter_contig = "--allow-inter-contig" if params_allow_inter_contig else "",
            bin_path = config.get("software_paths", {}).get("fgbio", "fgbio"),
            max_edits = params_max_edits,
            min_mapq = params_min_mapq,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            strategy = params_strategy,
            umi_tag = params_umi_tag
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} GroupReadsByUmi"
            " {params.allow_inter_contig}"
            " --raw-tag={params.umi_tag}"
            " --strategy={params.strategy}"
            " --edits={params.max_edits}"
            " --min-map-q={params.min_mapq}"
            " --input={input}"
            " --output={output.alignments}"
            " --family-size-histogram={output.metrics}"
            " {params.stderr_redirection} {log}"
