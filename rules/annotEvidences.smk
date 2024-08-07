__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'


def annotEvidences(
        in_disease_ontology="reference/disease_ontology.owl",
        in_evidences="reference/cln_evidences.tsv",
        in_sequences="data/reference.fa",
        in_variants="variants/{sample}_annot.vcf",
        out_evidences="variants/{sample}_annot_evidencesList.json",
        out_variants="variants/{sample}_annot_evidences.vcf",
        out_stderr="logs/variants/{sample}_annotEvidences_stderr.txt",
        params_annotations_field=None,
        params_assembly_version=None,
        params_disease_id_by_spl=None,
        params_disease_term_by_spl=None,
        params_evidences_source=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Add clinical evidence level to known variants."""
    # Manage sample disease
    if params_disease_id_by_spl is None:
        params_disease_id_by_spl = {}
    if params_disease_term_by_spl is None:
        params_disease_term_by_spl = {}

    def annotEvidencesGetParamDiseaseId(wildcards):
        param = ""
        spl_name = wildcards.sample
        if spl_name in params_disease_id_by_spl:
            param = "--disease-id '{}'".format(params_disease_id_by_spl[spl_name])
        return param

    def annotEvidencesGetParamDiseaseTerm(wildcards):
        param = ""
        spl_name = wildcards.sample
        if spl_name in params_disease_term_by_spl:
            param = "--disease-term '{}'".format(params_disease_term_by_spl[spl_name])
        return param

    # Rule
    rule:
        name:
            "annotEvidences" + snake_rule_suffix
        input:
            disease_ontology = in_disease_ontology,
            evidences = in_evidences,
            sequences = in_sequences,
            variants = in_variants
        output:
            evidences = None if out_evidences is None else (out_evidences if params_keep_outputs else temp(out_evidences)),
            variants = out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = "" if params_annotations_field is None else "--annotation-field " + params_annotations_field,
            assembly_version = "" if params_assembly_version is None else "--assembly-version " + params_assembly_version,
            bin_path = config.get("software_paths", {}).get("annotEvidences", "annotEvidences.py"),
            disease_id = annotEvidencesGetParamDiseaseId,
            disease_term = annotEvidencesGetParamDiseaseTerm,
            evidences_source = '--evidences-source "{}"'.format(params_evidences_source) if params_evidences_source else "",
            output_evidences = "--output-evidences {}".format(out_evidences) if out_evidences else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "4G",
            partition = "normal"
        conda:
            "envs/genovance.yml"
        shell:
            "{params.bin_path}"
            "  {params.annotations_field}"
            "  {params.assembly_version}"
            "  {params.disease_id}"
            "  {params.disease_term}"
            "  {params.evidences_source}"
            " --input-disease-ontology {input.disease_ontology}"
            " --input-evidences {input.evidences}"
            " --input-sequences {input.sequences}"
            " --input-variants {input.variants}"
            " --output-variants {output.variants}"
            " {params.output_evidences}"
            " {params.stderr_redirection} {log}"
