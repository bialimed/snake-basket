__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def samToFastq(
        in_alignments="aln/{sample}.bam",
        out_R1="reads/{sample}_R1.fastq.gz",
        out_R2="reads/{sample}_R2.fastq.gz",  # Optional
        out_stderr="logs/reads/{sample}_samToFastq_stderr.txt",
        params_extra="",
        params_include_non_pf=False,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Converts a SAM or BAM file to FASTQ."""
    rule:
        name:
            "samToFastq" + snake_rule_suffix
        input:
            in_alignments
        output:
            R1 = (out_R1 if params_keep_outputs else temp(out_R1)),
            R2 = (out_R2 if params_keep_outputs else temp(out_R2)) if out_R2 else [],
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            extra = params_extra,
            include_non_pf = ("true" if params_include_non_pf else "false"),
            output_r2 = "SECOND_END_FASTQ={}".format(out_R2) if out_R2 else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            java_mem = "150G",
            mem = "151G",
            partition = "normal"
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} SamToFastq"
            " -Xmx{resources.java_mem}"
            " {params.extra}"
            " INCLUDE_NON_PF_READS={params.include_non_pf}"
            " INPUT={input}"
            " FASTQ={output.R1}"
            " {params.output_r2}"
            " {params.stderr_redirection} {log}"
