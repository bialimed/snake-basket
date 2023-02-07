__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.2.0'


def samTagUMIToFastq(
        in_alignments="aln/{sample}.bam",
        out_R1="reads/{sample}_R1.fastq.gz",
        out_R2="reads/{sample}_R2.fastq.gz",  # Optional
        out_stderr="logs/reads/{sample}_samToFastq_stderr.txt",
        params_barcode_tag=None,
        params_barcode_by_spl=None,
        params_keep_qc_failed=False,
        params_qual_offset=None,
        params_umi_qual_tag=None,
        params_umi_tag=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Convert BAM with UMI in specific tag to fastq with UMI in reads ID (see Illumina's reads ID format)."""
    rule samTagUMIToFastq:
        input:
            in_alignments
        output:
            R1 = (out_R1 if params_keep_outputs else temp(out_R1)),
            R2 = (out_R2 if params_keep_outputs else temp(out_R2)) if out_R2 else [],
        log:
            out_stderr
        params:
            barcode_tag = " --barcode-tag {}".format(params_barcode_tag) if params_barcode_tag else "",
            bin_path = config.get("software_paths", {}).get("samTagUMIToFastq", "samTagUMIToFastq.py"),
            keep_qc_failed = " --keep-qc-failed" if params_keep_qc_failed else "",
            qual_offset = " --qual-offset {}".format(params_qual_offset) if params_qual_offset else "",
            reads_barcode = (lambda wildcards: "" if wildcards.sample not in params_barcode_by_spl else " --reads-barcode '{}'".format(params_barcode_by_spl[wildcards.sample])) if params_barcode_by_spl else "",
            umi_qual_tag = " --umi-qual-tag {}".format(params_umi_qual_tag) if params_umi_qual_tag else "",
            umi_tag = " --umi-tag {}".format(params_umi_tag) if params_umi_tag else "",
            output_r2 = " --output-reads-2 {}".format(out_R2) if out_R2 else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.barcode_tag}"
            " {params.keep_qc_failed}"
            " {params.qual_offset}"
            " {params.reads_barcode}"
            " {params.umi_qual_tag}"
            " {params.umi_tag}"
            " --input-aln {input}"
            " --output-reads {output.R1}"
            " {params.output_r2}"
            " {params.stderr_redirection} {log}"
