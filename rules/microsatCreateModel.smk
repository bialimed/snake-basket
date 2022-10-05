__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.1.0'


def microsatCreateModel(
        in_length_distributions,  # ["microsat/spl1_microsatLenDistrib.json", "microsat/spl2_microsatLenDistrib.json"]
        in_loci_status="raw/status.tsv",
        in_microsatellites="design/microsat.bed",
        out_info="microsat/microsatModel_info.tsv",
        out_model="microsat/microsatModel.json",
        out_stderr="logs/microsatCreateModel_stderr.txt",
        params_min_support=None,
        params_peak_height_cutoff=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Create training data for MSI classifiers."""
    rule microsatCreateModel:
        input:
            length_distributions = in_length_distributions,
            loci_status = in_loci_status,
            microsatellites = in_microsatellites
        output:
            info = out_info if params_keep_outputs else temp(out_info),
            model = out_model if params_keep_outputs else temp(out_model)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatCreateModel", "microsatCreateModel.py"),
            min_support = "" if params_min_support is None else "--min-support {}".format(params_min_support),
            peak_height_cutoff = "" if params_peak_height_cutoff is None else "--peak-height-cutoff {}".format(params_peak_height_cutoff),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.min_support}"
            " {params.peak_height_cutoff}"
            " --inputs-length-distributions {input.length_distributions}"
            " --input-loci-status {input.loci_status}"
            " --input-microsatellites {input.microsatellites}"
            " --output-info {output.info}"
            " --output-model {output.model}"
            " {params.stderr_redirection} {log}"
