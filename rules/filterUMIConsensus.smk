__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def filterUMIConsensus(
        in_aln="aln/umi/consensus/{sample}.bam",
        in_reference_seq="data/reference.fa",
        out_aln="aln/umi/filter/{sample}.bam",
        out_stderr="logs/aln/{sample}_gpByUMI_consensus_filter_stderr.txt",
        params_max_base_error_rate=0.1,
        params_max_no_call_fraction=0.2,
        params_max_read_error_rate=0.025,
        params_min_base_quality=10,
        params_min_mean_base_quality=5,
        params_min_reads=1,
        params_require_single_strand_agreement=False,
        params_reverse_per_tags=False,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Filters consensus reads generated by CallMolecularConsensusReads or CallDuplexConsensusReads."""
    rule filterUMIConsensus:
        input:
            aln = in_aln,
            reference = in_reference_seq
        output:
            out_aln if params_keep_outputs else temp(out_aln)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("fgbio", "fgbio"),
            max_base_error_rate = params_max_base_error_rate,
            max_no_call_fraction = params_max_no_call_fraction,
            max_read_error_rate = params_max_read_error_rate,
            min_base_quality = params_min_base_quality,
            min_mean_base_quality = params_min_mean_base_quality,
            min_reads = params_min_reads,
            require_single_strand_agreement = ("true" if params_require_single_strand_agreement else "false"),
            reverse_per_tags = ("true" if params_reverse_per_tags else "false"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} FilterConsensusReads"
            " --min-reads={params.min_reads}"
            " --min-base-quality={params.min_base_quality}"
            " --min-mean-base-quality={params.min_mean_base_quality}"
            " --max-read-error-rate={params.max_read_error_rate}"
            " --max-base-error-rate={params.max_base_error_rate}"
            " --reverse-per-base-tags={params.reverse_per_tags}"
            " --max-no-call-fraction={params.max_no_call_fraction}"
            " --require-single-strand-agreement={params.require_single_strand_agreement}"
            " --ref={input.reference}"
            " --input={input.aln}"
            " --output={output}"
            " {params.stderr_redirection} {log}"
