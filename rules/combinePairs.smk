__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def combinePairs(
        in_R1="data/{sample}_R1.fastq.gz",
        in_R2="data/{sample}_R2.fastq.gz",
        out_combined="combinePairs/{sample}.fastq.gz",
        out_report="stats/combinePairs/{sample}_report.json",
        out_stderr="logs/{sample}_combinePairs_stderr.txt",
        params_max_contradict_ratio=None,
        params_max_frag_length=None,
        params_min_frag_length=None,
        params_min_overlap=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Combine R1 and R2 by their overlapping segment."""
    rule combinePairs:
        input:
            R1 = in_R1,
            R2 = in_R2,
        output:
            combined = out_combined if params_keep_outputs else temp(out_combined),
            report = out_report
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("combinePairs", "combinePairs.py"),
            max_contradict_ratio = "" if params_max_contradict_ratio is None else "--max-contradict-ratio " + str(params_max_contradict_ratio),
            max_frag_length = "" if params_max_frag_length is None else "--max-frag-length " + str(params_max_frag_length),
            min_frag_length = "" if params_min_frag_length is None else "--min-frag-length " + str(params_min_frag_length),
            min_overlap = "" if params_min_overlap is None else "--min-overlap " + str(params_min_overlap),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.min_frag_length}"
            " {params.max_frag_length}"
            " {params.min_overlap}"
            " {params.max_contradict_ratio}"
            " --input-R1 {input.R1}"
            " --input-R2 {input.R2}"
            " --output-combined {output.combined}"
            " --output-report {output.report}"
            " {params.stderr_redirection} {log}"
