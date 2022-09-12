__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2022 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def microsatMsisensorproProClassify(
        in_evaluated="microsat/{sample}_microsatLenDistrib.json",
        in_model="microsat/microsatModel.json",
        out_report="microsat/msisensorpro/{sample}_stabilityStatus.json",
        out_stderr="logs/{sample}_microsatMsisensorproProClassify_stderr.txt",
        params_data_method=None,
        params_instability_ratio=None,
        params_locus_weight_is_score=None,
        params_min_depth=None,
        params_min_voting_loci=None,
        params_model_method_name=None,
        params_sample_name="{sample}",
        params_status_method=None,
        params_undetermined_weight=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Predict stability classes and scores for loci and samples using MSIsensor-pro pro v1.2.0 like algorithm."""
    rule microsatMSIsensorproProClassify:
        input:
            evaluated = in_evaluated,
            model = in_model
        output:
            out_report if params_keep_outputs else temp(out_report)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatMSIsensorproProClassify", "microsatMSIsensorproProClassify.py")),
            data_method = "" if params_data_method is None else "--data-method {}".format(params_data_method),
            instability_ratio = "" if params_instability_ratio else "--instability-ratio {}".format(params_instability_ratio),
            locus_weight_is_score = "" if params_locus_weight_is_score is None else "--locus-weight-is-score",
            min_depth = "" if params_min_depth is None else "--min-depth {}".format(params_min_depth),
            min_voting_loci = "" if params_min_voting_loci is None else "--min-voting-loci {}".format(params_min_voting_loci),
            status_method = "" if params_status_method is None else "--status-method {}".format(params_status_method),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            undetermined_weight = "" if params_undetermined_weight is None else "--undetermined-weight {}".format(params_undetermined_weight)
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.data_method}"
            " {params.instability_ratio}"
            " {params.locus_weight_is_score}"
            " {params.min_depth}"
            " {params.min_voting_loci}"
            " {params.status_method}"
            " {params.undetermined_weight}"
            " --input-evaluated {input.evaluated}"
            " --input-model {input.model}"
            " --output-report {output}"
            " {params.stderr_redirection} {log}"
