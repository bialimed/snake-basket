__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def rseqc_inferExperiment(
        in_annotations="reference/genome_genes.bed",
        in_alignments="aln/{sample}.bam",
        out_metrics="stats/reseqc/{sample}_inferExperiment.tsv",
        out_stderr="logs/reseqc/{sample}_inferExperiment_stderr.txt",
        params_map_quality=None,
        params_sample_size=1000000,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Use to guess how RNA-seq sequencing were configured, particulary how reads were stranded for strand-specific RNA-seq data, through comparing the “strandness of reads” with the “standness of transcripts”."""
    rule rseqc_inferExperiment:
        input:
            annotations = in_annotations,
            alignments = in_alignments
        output:
            out_metrics if params_keep_outputs else temp(out_metrics)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("infer_experiment", "infer_experiment.py"),
            map_quality = "" if params_map_quality is None else "--mapq " + str(params_map_quality),
            sample_size = "" if params_sample_size is None else "--sample-size " + str(params_sample_size),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/rseqc.yml"
        shell:
            "{params.bin_path}"
            " {params.sample_size}"
            " {params.map_quality}"
            " --refgene {input.annotations}"
            " --input-file {input.alignments}"
            " > {output}"
            " {params.stderr_redirection} {log}"
