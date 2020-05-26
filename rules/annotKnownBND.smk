__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def annotKnownBND(
        in_known_partners="reference/known_fusions_genes.tsv",
        in_variants="structural_variants/{sample}_annot.vcf",
        out_variants="structural_variants/{sample}_annot_known.vcf",
        out_stderr="logs/structural_variants/{sample}_annotknownBND_stderr.txt",
        params_annotations_field=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Annotate fusions known in fusions database with databases names and entries ID known.""""
    rule annotKnownBND:
        input:
            known_partners = in_known_partners,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = "" if params_annotations_field is None else "--annotation-field " + params_annotations_field,
            bin_path = config.get("software_pathes", {}).get("annotKnownBND", "annotKnownBND.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            "  {params.annotations_field}"
            " --input-known-partners {input.known_partners}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
