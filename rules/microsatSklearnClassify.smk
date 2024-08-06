__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'


def microsatSklearnClassify(
        in_evaluated="microsat/{sample}_microsatLenDistrib.json",
        in_model="microsat/microsatModel.json",
        out_report="microsat/{sample}_stabilityStatus.json",
        out_stderr="logs/{sample}_microsatStabilityClassify_stderr.txt",
        params_classifier=None,
        params_classifier_params=None,  # Must be str
        params_data_method=None,
        params_instability_ratio=None,
        params_locus_weight_is_score=False,
        params_min_depth=None,
        params_min_voting_loci=None,
        params_random_seed=None,
        params_status_method=None,
        params_undetermined_weight=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Predict stability classes and scores for loci and samples using an sklearn classifer."""
    # Parameters
    if params_classifier_params is not None:
        if not isinstance(params_classifier_params, str):
            raise Exception('The argument "params_classifier_params" in rule microsatSklearnClassify must be a string not {}: {}.'.format(type(params_classifier_params), params_classifier_params))
    # Rule
    rule:
        name:
            "microsatSklearnClassify" + snake_rule_suffix
        input:
            evaluated = in_evaluated,
            model = in_model
        output:
            out_report if params_keep_outputs else temp(out_report)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatSklearnClassify", "microsatSklearnClassify.py"),
            classifier = "" if params_classifier is None else "--classifier {}".format(params_classifier),
            classifier_params = "" if params_classifier_params is None else "--classifier-params '{}'".format(params_classifier_params),
            data_method = "" if params_data_method is None else "--data-method {}".format(params_data_method),
            instability_ratio = "" if params_instability_ratio is None else "--instability-ratio {}".format(params_instability_ratio),
            locus_weight_is_score = "--locus-weight-is-score" if params_locus_weight_is_score else "",
            min_depth = "" if params_min_depth is None else "--min-depth {}".format(params_min_depth),
            min_voting_loci = "" if params_min_voting_loci is None else "--min-voting-loci {}".format(params_min_voting_loci),
            random_seed = "" if params_random_seed is None else "--random-seed {}".format(params_random_seed),
            status_method = "" if params_status_method is None else "--status-method {}".format(params_status_method),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            undetermined_weight = "" if params_undetermined_weight is None else "--undetermined-weight {}".format(params_undetermined_weight),
        resources:
            extra = "",
            mem = "10G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.classifier}"
            " {params.classifier_params}"
            " {params.data_method}"
            " {params.instability_ratio}"
            " {params.locus_weight_is_score}"
            " {params.min_depth}"
            " {params.min_voting_loci}"
            " {params.random_seed}"
            " {params.status_method}"
            " {params.undetermined_weight}"
            " --input-evaluated {input.evaluated}"
            " --input-model {input.model}"
            " --output-report {output}"
            " {params.stderr_redirection} {log}"
