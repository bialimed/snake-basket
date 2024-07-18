__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def starFusion(
        in_genome_dir="reference/STAR_Fusion_CTAT",
        in_R1="cutadapt/{sample}_R1.fastq.gz",
        in_R2=None,
        out_abridged="structural_variants/STAR_Fusion/{sample}_abridged.tsv",
        out_fusions="structural_variants/STAR_Fusion/{sample}_fusions.tsv",
        out_stderr="logs/structural_variants/{sample}_starFusion_stderr.txt",
        params_tmp_dir="structural_variants/STAR_Fusion/{sample}",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Call fusions with STAR-Fusion."""
    rule:
        name:
            "starFusion" + snake_rule_suffix
        input:
            genome_dir = in_genome_dir,
            R1 = in_R1,
            R2 = [] if in_R2 is None else in_R2
        output:
            abridged = out_abridged if params_keep_outputs else temp(out_abridged),
            fusions = out_fusions if params_keep_outputs else temp(out_fusions),
            tmp_dir = temp(directory(params_tmp_dir))
        log:
            out_stderr
        params:
            arg_read2 = "" if in_R2 is None else "--right_fq",
            bin_path = config.get("software_paths", {}).get("STAR-Fusion", "STAR-Fusion"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "40G",
            partition = "normal"
        threads: 1
        conda:
            "envs/starFusion.yml"
        shell:
            "{params.bin_path}"
            " --CPU {threads}"
            " --genome_lib_dir {input.genome_dir}"
            " --left_fq {input.R1}"
            " {params.arg_read2} {input.R2}"
            " --output_dir {output.tmp_dir}"
            " {params.stderr_redirection} {log}"
            " && "
            "mv {output.tmp_dir}/star-fusion.fusion_predictions.tsv {output.fusions} 2>> {log}"
            " && "
            "mv {output.tmp_dir}/star-fusion.fusion_predictions.abridged.tsv {output.abridged} 2>> {log}"
