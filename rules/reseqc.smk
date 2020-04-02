__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'

read_distribution.py
junction_saturation.py
geneBody_coverage.py
def reseqc(
        in_variants="variants/{sample}.vcf",
        in_names=None,
        out_variants="variants/{sample}_renamed.vcf",
        out_stderr="logs/{sample}_renameChr_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Convert chromosome specification in STAR_Fusion VCF file into standard chromosome specification."""
    rule renameChromVCF:
        input:
            names = [] if in_names is None else in_names,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = getSoft(config, "renameChromVCF.py", "fusion_callers"),
            names = "" if in_names is None else "--input-names " + in_names,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        # conda:
        #     "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.names}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
