__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def fastqToBam(
        in_reads=["raw/{sample}_R1.fastq.gz", "raw/{sample}_R2.fastq.gz"],
        out_alignments="reads/{sample}.ubam",
        out_stderr="logs/reads/{sample}_fastqToBam_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_library="{sample}",
        params_read_group_id="1",
        params_read_structures=None,
        params_sample="{sample}",
        params_sort=False,
        params_stderr_append=False,
        params_umi_tag="RX"):
    """Generates an unmapped BAM (or SAM or CRAM) file from fastq files."""
    rule fastqToBam:
        input:
            in_reads
        output:
            out_alignments if params_keep_outputs else temp(out_alignments)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("fgbio", "fgbio"),
            extra = params_extra,
            library = params_library,
            read_group_id = params_read_group_id,
            read_structures = "--read-structures {}".format(params_read_structures) if params_read_structures else "",
            sample = params_sample,
            sort = "--sort" if params_sort else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            umi_tag = "--umi-tag {}".format(params_umi_tag)
        resources:
            extra = "",
            mem = "6G",
            partition = "normal"
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} FastqToBam"
            " {params.extra}"
            " --library {params.library}"
            " --read-group-id {params.read_group_id}"
            " {params.read_structures}"
            " --sample {params.sample}"
            " {params.sort}"
            " {params.umi_tag}"
            " --input {input}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
