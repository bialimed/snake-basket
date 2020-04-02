__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def cutadapt_pe(
        in_R1_end_adapter,
        in_R2_end_adapter,
        in_R1_reads="data/{sample}_R1.fastq.gz",
        in_R2_reads="data/{sample}_R2.fastq.gz",
        out_R1_reads="cutadapt/{sample}_R1.fastq.gz",
        out_R2_reads="cutadapt/{sample}_R2.fastq.gz",
        out_metrics="stats/cutadapt/{sample}.txt",
        out_stderr="logs/stats/cutadapt/{sample}_stderr.txt",
        params_R1_adapter_type="a",  # Must be "a" for 3', "g" for 5' or "b" for 3' or 5'
        params_R2_adapter_type="A",  # Must be "A" for 3', "G" for 5' or "B" for 3' or 5'
        params_discard_untrimmed=False,
        params_error_rate=0.1,
        params_min_length=0,
        params_min_overlap=11,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Remove adapter sequences in paired-end data."""
    rule cutadapt_pe:
        input:
            R1_reads = in_R1_reads,
            R1_end_adapter = in_R1_end_adapter,
            R2_reads = in_R2_reads,
            R2_end_adapter = in_R2_end_adapter,
        output:
            R1_reads = out_R1_reads if params_keep_outputs else temp(out_R1_reads),
            R2_reads = out_R2_reads if params_keep_outputs else temp(out_R2_reads),
            metrics = out_metrics
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("cutadapt", "cutadapt"),
            discard_untrimmed = "--discard-untrimmed" if params_discard_untrimmed else "",
            error_rate = params_error_rate,
            min_length = params_min_length,
            min_overlap = params_min_overlap,
            R1_adapter_type = params_R1_adapter_type,
            R2_adapter_type = params_R2_adapter_type,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/cutadapt.yml"
        shell:
            "{params.bin_path}"
            " --minimum-length {params.min_length}"
            " --error-rate {params.error_rate}"
            " --overlap {params.min_overlap}"
            " {params.discard_untrimmed}"
            " -{params.R1_adapter_type} file:{input.R1_end_adapter}"
            " -{params.R2_adapter_type} file:{input.R2_end_adapter}"
            " --output {output.R1_reads}"
            " --paired-output {output.R2_reads}"
            " {input.R1_reads}"
            " {input.R2_reads}"
            " > {output.metrics}"
            " {params.stderr_redirection} {log}"
