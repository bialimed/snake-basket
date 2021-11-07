__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def delDuplicatesByUMI(
        in_aln="aln/{sample}.bam",
        in_reference_seq="data/reference.fa",
        out_aln="aln/delDuplicates/{sample}.bam",
        out_stderr="logs/aln/{sample}_delDuplicatesByUMI_stderr.txt",
        params_aln_extra=r"-R '@RG\tID:1\tLB:{sample}\tSM:{sample}\tPL:ILLUMINA'",
        params_aln_fct=bwa_mem,
        params_consensus_error_rate_post_umi=30,
        params_consensus_error_rate_pre_umi=45,
        params_consensus_min_input_base_quality=10,
        params_consensus_min_reads=1,
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
        params_sam2fastq_mem="5G",
        params_threads=1,
        params_umi_separator=None,  # If separator is set the UMI is extract from the read ID otherwise the aln file must contains the UMI tag (see params_umi_tag).
        params_umi_tag="RX",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Use UMI to remove pairs of reads coming from same original molecule and generate consensus."""
    in_group_aln = in_aln
    if params_umi_separator:
        in_group_aln = out_aln + "_UMITmpTagUMI.bam"
        setUMIRGFromID(
            in_aln=in_aln,
            out_aln=in_group_aln,
            out_stderr=out_stderr,
            params_stderr_append=True,
            params_umi_separator=params_umi_separator,
            params_umi_tag=params_umi_tag)

    groupReadsByUmi(
        in_aln=in_group_aln,
        out_aln=out_aln + "_UMITmpGroup.bam",
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_max_edits=params_group_max_edits,
        params_min_mapq=params_group_min_mapq,
        params_strategy=params_group_strategy,
        params_umi_tag=params_umi_tag)

    callMolecularConsensus(
        in_aln=out_aln + "_UMITmpGroup.bam",
        out_aln=out_aln + "_UMITmpConsensus.bam",
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_error_rate_post_umi=params_consensus_error_rate_post_umi,
        params_error_rate_pre_umi=params_consensus_error_rate_pre_umi,
        params_min_input_base_quality=params_consensus_min_input_base_quality,
        params_min_reads=params_consensus_min_reads)

    filterUMIConsensus(
        in_aln=out_aln + "_UMITmpConsensus.bam",
        in_reference_seq=in_reference_seq,
        out_aln=out_aln + "_UMITmpFilter.bam",
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_max_base_error_rate=params_filter_max_base_error_rate,
        params_max_no_call_fraction=params_filter_max_no_call_fraction,
        params_max_read_error_rate=params_filter_max_read_error_rate,
        params_min_base_quality=params_filter_min_base_quality,
        params_min_mean_base_quality=params_filter_min_mean_base_quality,
        params_min_reads=params_consensus_min_reads,
        params_require_single_strand_agreement=params_filter_require_single_strand_agreement,
        params_reverse_per_tags=params_filter_reverse_per_tags)

    samToFastq(
        in_alignments=out_aln + "_UMITmpFilter.bam",
        out_R1=out_aln + "_R1.fastq.gz",
        out_R2=out_aln + "_R2.fastq.gz",
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_memory=params_sam2fastq_mem)

    params_aln_fct(
        in_reads=[
            out_aln + "_R1.fastq.gz",
            out_aln + "_R2.fastq.gz",
        ],
        in_reference_seq=in_reference_seq,
        out_alignments=out_aln,
        out_stderr=out_stderr,
        params_stderr_append=True,
        params_extra=params_aln_extra,
        params_threads=params_threads,
        params_keep_outputs=params_keep_outputs)
