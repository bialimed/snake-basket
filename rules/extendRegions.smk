__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def extendRegions(
        in_regions="data/targets.bed",
        out_regions="design/targets_extended.bed",
        out_stderr="logs/design/extendRegions_stderr.txt",
        params_padding_size=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Add padding to each regions and merge the overlapping and optionally the contiguous regions."""
    rule extendRegions:
        input:
            in_regions
        output:
            out_regions if params_keep_outputs else temp(out_regions)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("extendRegions", "extendRegions.py"),
            padding_size = " --padding-size " + str(params_padding_size) if params_padding_size is not None else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            "{params.padding_size}"
            " --input-regions {input}"
            " --output-regions {output}"
            " {params.stderr_redirection} {log}"