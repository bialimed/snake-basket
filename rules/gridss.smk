__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2025 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def gridss(
        in_alignments="aln/delDup/{sample}.bam",
        in_reference_seq="reference/genome.fasta",
        out_variants="sv/{sample}_lumpyexpress_call.vcf",
        out_stderr="logs/{sample}_lumpyexpress_stderr.txt",
        params_max_coverage=None,
        params_gridss_container=None,
        params_keep_outputs=True,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Structural variant discovery."""
    rule:
        name:
            "gridss" + snake_rule_suffix
        input:
            alignments = in_alignments,
            reference_seq = in_reference_seq,
            targets = ([] if in_targets is None else in_targets)
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gridss", "gridss"),
            max_coverage = "--maxcoverage {}".format() if params_max_coverage else ""
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            java_mem = "30G",
            mem = "32G",
            partition = "normal"
        threads: 1
        container:
            params_gridss_container
        shell:
            "{params.bin_path}"
            " --jvmheap {resources.java_mem}"
            " --threads {threads}"
            " {params.max_coverage}"
            " --assembly {input.alignments}"
            " --reference {input.reference_seq}"
            " --workingdir {output}_tmpDir"
            " --output {output}"
            " > {log}"
            " {params.stderr_redirection} {log.stderr}"
