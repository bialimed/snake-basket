__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def callMolecularConsensus(
        in_alignments="aln/umi/group/{sample}.bam",
        out_alignments="aln/umi/consensus/{sample}.bam",
        out_stderr="logs/aln/{sample}_gpByUMI_consensus_stderr.txt",
        params_error_rate_post_umi=40,
        params_error_rate_pre_umi=45,
        params_keep_outputs=False,
        params_min_input_base_quality=10,
        params_min_reads=1,
        params_stderr_append=False):
    """Calls consensus sequences from reads with the same unique molecular tag."""
    rule callMolecularConsensus:
        input:
            in_alignments
        output:
            out_alignments if params_keep_outputs else temp(out_alignments)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("fgbio", "fgbio"),
            error_rate_post_umi = params_error_rate_post_umi,
            error_rate_pre_umi = params_error_rate_pre_umi,
            min_input_base_quality = params_min_input_base_quality,
            min_reads = params_min_reads,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            java_mem = "4G",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/fgbio.yml"
        shell:
            "{params.bin_path} CallMolecularConsensusReads"
            " -Xmx{resources.java_mem}"
            " --error-rate-pre-umi={params.error_rate_pre_umi}"
            " --error-rate-post-umi={params.error_rate_post_umi}"
            " --min-input-base-quality={params.min_input_base_quality}"
            " --min-reads={params.min_reads}"
            " --input={input}"
            " --output={output}"
            " {params.stderr_redirection} {log}"
