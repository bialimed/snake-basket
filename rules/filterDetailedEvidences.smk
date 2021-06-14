__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def filterDetailedEvidences(
        in_evidences="reference/annot.gtf",
        in_variants="variants/{sample}_annot.vcf",
        out_evidences="variants/{sample}_annot_evidencesList.json",
        out_stderr="logs/variants/{sample}_filterDetailedEvidences_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Filter detailed evidences produced by annotEvidences.py to correspond to the filtered VCF."""
    rule filterDetailedEvidences:
        input:
            evidences = in_evidences,
            variants = in_variants
        output:
            out_evidences if params_keep_outputs else temp(out_evidences)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("filterDetailedEvidences", "filterDetailedEvidences.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/genovance.yml"
        shell:
            "{params.bin_path}"
            " --input-evidences {input.evidences}"
            " --input-variants {input.variants}"
            " --output-evidences {output}"
            " {params.stderr_redirection} {log}"
