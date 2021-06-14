__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def delDuplicates(
        in_alignments="aln/{sample}.bam",
        out_alignments="aln/delDup/{sample}.bam",
        out_metrics="stats/delDup/{sample}.tsv",
        out_stderr="logs/aln/{sample}_delDup_stderr.txt",
        params_create_index=True,
        params_extra="",
        params_java_mem="5G",
        params_stringency="LENIENT",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Remove pairs of reads originating from a single fragment of DNA."""
    rule delDuplicates:
        input:
            in_alignments
        output:
            alignments = out_alignments if params_keep_outputs else temp(out_alignments),
            metrics = out_metrics,
            index = out_alignments[:-4] + ".bai" if params_create_index else None  # Not tmp because following rules does not indicate the bai in their inputs
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            create_index = str(params_create_index).lower(),
            extra = params_extra,
            java_mem = params_java_mem,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} MarkDuplicates"
            " -Xmx{params.java_mem}"
            " {params.extra}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " REMOVE_SEQUENCING_DUPLICATES=true"
            " REMOVE_DUPLICATES=true"
            " CREATE_INDEX={params.create_index}"
            " INPUT={input}"
            " OUTPUT={output.alignments}"
            " METRICS_FILE={output.metrics}"
            " {params.stderr_redirection} {log}"
