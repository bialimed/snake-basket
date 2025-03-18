__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.4.0'


def gatk4_baseRecalibrator(
        in_alignments="aln/delDup/{sample}.bam",
        in_intervals="design/targets_intervals.picard",
        in_known_sites=["data/known_sites.vcf"],
        in_reference_seq="data/reference.fa",
        out_alignments="aln/gatk_recal/{sample}_BQSR.bam",
        out_stderr="logs/aln/gatk_recal/{sample}_baseRecalibrator_stderr.txt",
        params_extra="",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Apply machine learning to model sequencing machines errors empirically and adjust the quality scores accordingly. This allows us to get more accurate base qualities, which in turn improves the accuracy of our variant calls."""
    # Parameters
    in_known_sites_index = []
    for path in in_known_sites:
        if isinstance(path, snakemake.io.AnnotatedString) and "storage_object" in path.flags:
            in_known_sites_index.append(storage(path.flags["storage_object"].query + ".tbi"))
        else:
            in_known_sites_index.append(path + ".tbi")
    in_reference_seq_index = in_reference_seq.rsplit(".", 1)[0] + ".dict"
    if isinstance(in_reference_seq, snakemake.io.AnnotatedString) and "storage_object" in in_reference_seq.flags:
        in_reference_seq_index = storage(in_reference_seq.flags["storage_object"].query.rsplit(".", 1)[0] + ".dict")
    # Create recalibration model
    rule:
        name:
            "gatk4_baseRecalibrator" + snake_rule_suffix
        input:
            alignments = in_alignments,
            intervals = ([] if in_intervals is None else in_intervals),
            known = in_known_sites,
            known_index = in_known_sites_index,
            reference = in_reference_seq,
            reference_seq_index = in_reference_seq_index
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
            mem = "4G",
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
    rule:
        name:
            "gatk4_applyBQSR" + snake_rule_suffix
        input:
            alignments = in_alignments,
            intervals = ([] if in_intervals is None else in_intervals),
            recalibration_table = out_alignments + "_baseRecalibrator.tsv",
            reference = in_reference_seq,
            reference_seq_index = in_reference_seq_index
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
            mem = "4G",
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
