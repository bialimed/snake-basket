__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.2.0'


def gatk4_baseRecalibrator(
        in_alignments="aln/delDup/{sample}.bam",
        in_intervals="design/targets_intervals.picard",
        in_known_sites="data/known_sites.vcf",
        in_reference_seq="data/reference.fa",
        out_alignments="aln/gatk_recal/{sample}_BQSR.bam",
        out_stderr="logs/aln/gatk_recal/{sample}_baseRecalibrator_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Apply machine learning to model sequencing machines errors empirically and adjust the quality scores accordingly. This allows us to get more accurate base qualities, which in turn improves the accuracy of our variant calls."""
    # Create recalibration model
    rule gatk4_baseRecalibrator:
        input:
            alignments = in_alignments,
            intervals = ([] if in_intervals is None else in_intervals),
            known = in_known_sites,
            reference = in_reference_seq,
        output:
            temp(out_alignments + "_baseRecalibrator.tsv")
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gatk", "gatk"),
            extra = params_extra,
            intervals = "" if in_intervals is None else "--intervals " + in_intervals,
            known_sites = "--known-sites " + " --known-sites ".join(in_known_sites),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "15G",
            partition = "normal"
        conda:
            "envs/gatk4.yml"
        shell:
            "{params.bin_path} BaseRecalibrator"
            " {params.extra}"
            " --input {input.alignments}"
            " --reference {input.reference}"
            " {params.known_sites}"
            " {params.intervals}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
    # Apply base quality recalibration
    rule gatk4_applyBQSR:
        input:
            alignments = in_alignments,
            intervals = ([] if in_intervals is None else in_intervals),
            recalibration_table = out_alignments + "_baseRecalibrator.tsv",
            reference = in_reference_seq
        output:
            bam = (out_alignments if params_keep_outputs else temp(out_alignments)),
            bai = (out_alignments[:-4] + ".bai" if params_keep_outputs else temp(out_alignments[:-4] + ".bai"))
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gatk", "gatk"),
            extra = params_extra,
            intervals = "" if in_intervals is None else "--intervals " + in_intervals
        resources:
            extra = "",
            mem = "15G",
            partition = "normal"
        conda:
            "envs/gatk4.yml"
        shell:
            "{params.bin_path} ApplyBQSR"
            " --create-output-bam-index"
            " {params.extra}"
            " --input {input.alignments}"
            " --reference {input.reference}"
            " --bqsr-recal-file {input.recalibration_table}"
            " {params.intervals}"
            " --output {output.bam}"
            " 2>> {log}"
