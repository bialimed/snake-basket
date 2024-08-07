__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.3.0'


def markDuplicates(
        in_alignments="aln/{sample}.bam",
        out_alignments="aln/markDup/{sample}.bam",
        out_metrics="stats/markDup/{sample}.tsv",
        out_stderr="logs/aln/{sample}_markDup_stderr.txt",
        params_remove=False,
        params_create_index=True,
        params_extra="",
        params_keep_outputs=False,
        params_stderr_append=False,
        params_stringency="LENIENT",
        snake_rule_suffix=""):
    """"Mark or remove pairs of reads originating from a single fragment of DNA."""
    rule:
        name:
            "markDuplicates" + snake_rule_suffix
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
            delete_dup = str(params_remove).lower(),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        resources:
            extra = "",
            java_mem = "5G",
            mem = "8G",
            partition = "normal"
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} MarkDuplicates"
            " -Xmx{resources.java_mem}"
            " {params.extra}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " REMOVE_SEQUENCING_DUPLICATES={params.delete_dup}"
            " REMOVE_DUPLICATES={params.delete_dup}"
            " CREATE_INDEX={params.create_index}"
            " INPUT={input}"
            " OUTPUT={output.alignments}"
            " METRICS_FILE={output.metrics}"
            " {params.stderr_redirection} {log}"
