__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'

import os

include: "callMolecularConsensus.smk"
include: "fastqToBam.smk"
include: "filterUMIConsensus.smk"
include: "groupReadsByUMI.smk"
include: "mergeBamAlignment.smk"
include: "samToFastq.smk"
include: "setUMITagFromID.smk"


def delDuplicatesByUMI(
        in_alignments="aln/{sample}.bam",
        in_R1=None,  # If reads are provided the alignments file is merged to complete complete info from reads ID (UMI barcode) and from mergeBamAlignment calculation (MQ, ...)
        in_R2=None,
        in_reference_seq="data/reference.fa",
        out_alignments="aln/delDup/{sample}.bam",
        out_metrics="stats/gpByUMI/{sample}.tsv",
        out_stderr="logs/aln/{sample}_delDuplicatesByUMI_stderr.txt",
        params_aln_extra=r"-R '@RG\tID:1\tLB:{sample}\tSM:{sample}\tPL:ILLUMINA'",
        params_aln_fct=bwa_mem,
        params_consensus_error_rate_post_umi=30,
        params_consensus_error_rate_pre_umi=45,
        params_consensus_min_input_base_quality=10,
        params_consensus_min_reads=1,
        params_duplex_consensus=False,
        params_filter_max_base_error_rate=0.1,
        params_filter_max_no_call_fraction=0.2,
        params_filter_max_read_error_rate=0.025,
        params_filter_min_base_quality=10,
        params_filter_min_mean_base_quality=5,
        params_filter_require_single_strand_agreement=False,
        params_filter_reverse_per_tags=True,
        params_group_max_edits=1,
        params_group_min_mapq=25,
        params_group_strategy="adjacency",
        params_tmp_folder="umi",
        params_umi_separator=":",
        params_umi_tag="RX",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix="_delDupUMI"):
    """Use UMI to remove pairs of reads coming from same original molecule and generate consensus."""
    if params_duplex_consensus and params_group_strategy != "paired":
        raise Exception("Duplex consensus required paired group strategy.")
    out_filename = os.path.basename(out_alignments)
    in_group_aln = in_alignments
    if in_R1:
        in_group_aln = os.path.join(params_tmp_folder, "tagUMI/tmp_" + out_filename)
        fastqToBam(
            in_reads=[in_R1, in_R2],
            out_alignments=os.path.join(params_tmp_folder, "uBAM/tmp_" + out_filename),
            params_sort=True,
            snake_rule_suffix=snake_rule_suffix
        )
        setUMITagFromID(
            in_alignments=os.path.join(params_tmp_folder, "uBAM/tmp_" + out_filename),
            out_alignments=os.path.join(params_tmp_folder, "setTag/tmp_" + out_filename),
            out_stderr=out_stderr,
            params_stderr_append=True,
            params_umi_separator=params_umi_separator,
            params_umi_tag=params_umi_tag,
            snake_rule_suffix=snake_rule_suffix
        )
        mergeBamAlignment(
            in_alignments=in_alignments,
            in_reference_seq=in_reference_seq,
            in_unmapped_bam=os.path.join(params_tmp_folder, "setTag/tmp_" + out_filename),
            out_alignments=in_group_aln,
            out_stderr=out_stderr,
            params_stderr_append=True,
            params_aligner_proper_pair_flags=True,
            params_create_index=True,
            params_expected_orientations=["FR"],
            params_sort_order="coordinate",
            snake_rule_suffix=snake_rule_suffix
        )

    groupReadsByUMI(
        in_alignments=in_group_aln,
        out_alignments=os.path.join(params_tmp_folder, "group/tmp_" + out_filename),
        out_metrics=out_metrics,
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_max_edits=params_group_max_edits,
        params_min_mapq=params_group_min_mapq,
        params_strategy=params_group_strategy,
        params_umi_tag=params_umi_tag,
        snake_rule_suffix=snake_rule_suffix)

    callMolecularConsensus(
        in_alignments=os.path.join(params_tmp_folder, "group/tmp_" + out_filename),
        out_alignments=os.path.join(params_tmp_folder, "consensus/tmp_" + out_filename),
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_duplex_consensus=params_duplex_consensus,
        params_error_rate_post_umi=params_consensus_error_rate_post_umi,
        params_error_rate_pre_umi=params_consensus_error_rate_pre_umi,
        params_min_input_base_quality=params_consensus_min_input_base_quality,
        params_min_reads=params_consensus_min_reads,
        snake_rule_suffix=snake_rule_suffix)

    filterUMIConsensus(
        in_alignments=os.path.join(params_tmp_folder, "consensus/tmp_" + out_filename),
        in_reference_seq=in_reference_seq,
        out_alignments=os.path.join(params_tmp_folder, "filter/tmp_" + out_filename),
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_max_base_error_rate=params_filter_max_base_error_rate,
        params_max_no_call_fraction=params_filter_max_no_call_fraction,
        params_max_read_error_rate=params_filter_max_read_error_rate,
        params_min_base_quality=params_filter_min_base_quality,
        params_min_mean_base_quality=params_filter_min_mean_base_quality,
        params_min_reads=params_consensus_min_reads,
        params_require_single_strand_agreement=params_filter_require_single_strand_agreement,
        params_reverse_per_tags=params_filter_reverse_per_tags,
        snake_rule_suffix=snake_rule_suffix)

    samToFastq(
        in_alignments=os.path.join(params_tmp_folder, "filter/tmp_" + out_filename),
        out_R1=os.path.join(params_tmp_folder, "raw/tmp_" + out_filename + "_R1.fastq.gz"),
        out_R2=os.path.join(params_tmp_folder, "raw/tmp_" + out_filename + "_R2.fastq.gz"),
        out_stderr=out_stderr,
        params_stderr_append=True,
        snake_rule_suffix=snake_rule_suffix)

    params_aln_fct(
        in_reads=[
            os.path.join(params_tmp_folder, "raw/tmp_" + out_filename + "_R1.fastq.gz"),
            os.path.join(params_tmp_folder, "raw/tmp_" + out_filename + "_R2.fastq.gz")
        ],
        in_reference_seq=in_reference_seq,
        out_alignments=out_alignments,
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_extra=params_aln_extra,
        params_keep_outputs=params_keep_outputs,
        snake_rule_suffix=snake_rule_suffix)
