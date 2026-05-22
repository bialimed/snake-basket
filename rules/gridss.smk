__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2025 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def gridss(
        in_alignments="aln/delDup/{sample}.bam",
        in_reference_seq="reference/genome.fasta",
        out_assembly="structural_variants/{sample}_gridss_assembly.bam",
        out_variants="structural_variants/{sample}_gridss_call.vcf",
        out_stderr="logs/{sample}_gridss_stderr.txt",
        params_max_coverage=None,
        params_gridss_container=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Structural variant discovery."""
    rule:
        name:
            "gridss" + snake_rule_suffix
        input:
            alignments = in_alignments,
            reference_seq = in_reference_seq
        output:
            assembly = out_assembly if params_keep_outputs else temp(out_assembly),
            variants = out_variants if params_keep_outputs else temp(out_variants),
            variants_idx = out_variants + ".idx" if params_keep_outputs else temp(out_variants + ".idx"),
            work_dir = temp(directory(out_variants + "_tmpDir"))
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gridss", "gridss"),
            max_coverage = "--maxcoverage " + str(params_max_coverage) if params_max_coverage else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            java_mem = "30G",
            mem = "32G",
            partition = "normal"
        threads: 1
        singularity:
            params_gridss_container
        shell:
            "{params.bin_path}"
            " --jvmheap {resources.java_mem}"
            " --threads {threads}"
            " {params.max_coverage}"
            " --reference {input.reference_seq}"
            " --workingdir {output.work_dir}"
            " --assembly {output.assembly}"
            " --output {output.variants}"
            " {input.alignments}"
            " {params.stderr_redirection} {log}"
