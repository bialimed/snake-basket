__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2024 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def bedtools_intersect(
        in_features,
        in_targets,
        out_features,
        out_stderr="logs/bedtools_intersect_stderr.txt",
        params_keep_outputs=False,
        params_mode="intersect",  # "overlap" or "remove"
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Filter for overlaps between two sets of genomic features."""
    if params_mode not in {None, "intersect", "overlap", "remove"}:
        raise ValueError("Invalid mode {} for bedtools_intersect rule.".format(params_mode))
    rule:
        name:
            "bedtools_intersect" + snake_rule_suffix
        input:
            features = in_features,
            targets = in_targets
        output:
            out_features if params_keep_outputs else temp(out_features),
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("bedtools", "bedtools"),
            mode = "" if params_mode is None or params_mode == "intersect" else ("-wa" if "overlap" else "-v"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
        resources:
            extra = "",
            mem = "5G",
            partition = "normal"
        conda:
            "envs/bedtools.yml"
        shell:
            "{params.bin_path} intersect"
            " -header"
            " -a {input.features}"
            " -b {input.targets}"
            " > {output}"
            " {params.stderr_redirection} {log}"
