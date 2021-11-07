__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def callMolecularConsensus(
        in_aln="aln/umi/group/{sample}.bam",
        out_aln="aln/umi/consensus/{sample}.bam",
        out_stderr="logs/aln/{sample}_gpByUMI_consensus_stderr.txt",
        params_error_rate_post_umi=40,
        params_error_rate_pre_umi=45,
        params_min_input_base_quality=10,
        params_min_reads=1,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Calls consensus sequences from reads with the same unique molecular tag."""
    rule callMolecularConsensus:
        input:
            in_aln
        output:
            out_aln if params_keep_outputs else temp(out_aln))
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("fgbio", "fgbio"),
            error_rate_post_umi = params_error_rate_post_umi,
            error_rate_pre_umi = params_error_rate_pre_umi,
            min_input_base_quality = params_min_input_base_quality,
            min_reads = params_min_reads,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} CallMolecularConsensusReads"
            " --error-rate-pre-umi={params.error_rate_pre_umi}"
            " --error-rate-post-umi={params.error_rate_post_umi}"
            " --min-input-base-quality={params.min_input_base_quality}"
            " --min-reads={params.min_reads}"
            " --input={input}"
            " --output={output}"
            " {params.stderr_redirection} {log}"
