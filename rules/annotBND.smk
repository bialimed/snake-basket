__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def annotBND(
        in_annotations="reference/annot.gtf",
        in_variants="structural_variants/{sample}.vcf",
        out_variants="structural_variants/{sample}_annot.vcf",
        out_stderr="logs/structural_variants/{sample}_annotBND_stderr.txt",
        params_annotations_field=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Annotate BND in a VCF with content of a GTF."""
    rule annotBND:
        input:
            annotations = in_annotations,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = "" if params_annotations_field is None else "--annotation-field " + params_annotations_field,
            bin_path = config.get("software_pathes", {}).get("annotBND", "annotBND.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        # conda:
        #     "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            "  {params.annotations_field}"
            " --input-annotations {input.annotations}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
