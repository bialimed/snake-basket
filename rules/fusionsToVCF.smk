__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def fusionsToVCF(
        in_fusions="structural_variants/{caller}/{sample}_fusions.tsv",
        out_fusions="structural_variants/{caller}/{sample}_fusions.vcf",
        out_stderr="logs/{sample}_{caller}_toVCF_stderr.txt",
        params_annotation_field=None,
        params_sample_wildcard="{sample}",
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_wildcard_constraints=None):
    """Convert TSV output coming from several popular fusions callers to VCF."""
    snake_wildcard_constraints = {} if snake_wildcard_constraints is None else snake_wildcard_constraints
    rule fusionsToVCF:
        wildcard_constraints:
            **snake_wildcard_constraints
        input:
            in_fusions
        output:
            out_fusions if params_keep_outputs else temp(out_fusions)
        log:
            out_stderr
        params:
            annotation_field = "" if params_annotation_field is None else "--annotation-field " + params_annotation_field,
            bin_path = config.get("software_pathes", {}).get("fusionsToVCF", "fusionsToVCF.py"),
            sample_wildcard = params_sample_wildcard,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        # conda:
        #     "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.annotation_field}"
            " --sample-name {params.sample_wildcard}"
            " --input-fusions {input}"
            " --output-fusions {output}"
            " {params.stderr_redirection} {log}"
