__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def fastqToBam(
        in_reads=["raw/{sample}_R1.fastq.gz", "raw/{sample}_R2.fastq.gz"],
        out_alignments="reads/{sample}.ubam",
        out_stderr="logs/reads/{sample}_fastqToBam_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_read_structures=None,
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
            read_structures = "--read-structures {}".format(read_structures) if read_structures else "",
            sort = "--sort" if params_sort,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            umi_tag = "--umi-tag {}".format(params_umi_tag)
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} FastqToBam"
            " {params.extra}"
            " {params.read_structures}"
            " {params.sort}"
            " {params.umi_tag}"
            " --input {input}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
