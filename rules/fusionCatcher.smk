__author__ = 'Veronique Ivashchenko and Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def fusionCatcher(
        in_R1="data/{sample}_R1.fastq.gz",
        in_R2="data/{sample}_R2.fastq.gz",
        in_fusion_resources="reference/fusionCatcher/94",
        out_summary="structural_variants/FusionCatcher/{sample}_summary.tsv",
        out_fusions="structural_variants/FusionCatcher/{sample}_fusions.tsv",
        out_stdout="logs/structural_variants/{sample}_fusionCatcher_stdout.txt",
        out_stderr="logs/structural_variants/{sample}_fusionCatcher_stderr.txt",
        params_nb_threads=1,
        params_sort_memory=5,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Call fusions with FusionCatcher."""
    # Parameters
    work_folder = os.path.join(os.path.dirname(out_fusions), "{sample}_work")

    # Run fusionCatcher
    rule fusionCatcher:
        input:
            fusion_resources = in_fusion_resources,
            R1 = in_R1,
            R2 = in_R2
        output:
            folder = temp(directory(work_folder)),
            fusions = out_fusions if params_keep_outputs else temp(out_fusions),
            summary = out_summary if params_keep_outputs else temp(out_summary)
        log:
            stderr = out_stderr,
            stdout = out_stdout
        params:
            bin_path = config.get("software_pathes", {}).get("fusioncather", "fusioncather.py"),
            single_end = "--single-end" if in_R2 is None else "",
            sort_memory = params_sort_memory,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/fusionCatcher.yml"
        threads: params_nb_threads
        shell:
            "mkdir -p {output.folder}/raw {params.stderr_redirection} {log.stderr}"
            " && "
            "cp {input.R1} {input.R2} {output.folder}/raw 2>> {log.stderr}"
            " && "
            "{params.bin_path}"
            " --no-update-check"
            " --threads {threads}"
            " --sort-buffer-size {params.sort_memory}"
            " {params.single_end}"
            " --data {input.fusion_resources}"
            " --input {output.folder}/raw"
            " --output {output.folder}"
            " 2>> {log.stderr}"
            " && "
            " mv {output.folder}/fusioncatcher.log {log.stdout} 2>> {log.stderr}"
            " && "
            " mv {output.folder}/summary_candidate_fusions.txt {output.summary} 2>> {log.stderr}"
            " && "
            " mv {output.folder}/final-list_candidate-fusion-genes.txt {output.fusions} 2>> {log.stderr}"
