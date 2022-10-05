__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.1.0'


def microsatStatusToAnnot(
        in_loci_status="raw/status.tsv",
        in_microsatellites="design/microsat.bed",
        out_loci_status="microsat/modelStatus.tsv",
        out_stderr="logs/microsatLenDistrib_stderr.txt",
        params_locus_id=True,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Convert MSI status file (splA<tab>status_locus_1<tab>status_locus_2) in MSI annotation file."""
    rule microsatStatusToAnnot:
        input:
            loci_status = in_loci_status,
            microsatellites = in_microsatellites
        output:
            out_loci_status if params_keep_outputs else temp(out_loci_status)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatStatusToAnnot", "microsatStatusToAnnot.py"),
            locus_id = "--locus-id" if params_locus_id else "",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.locus_id}"
            " --input-targets {input.microsatellites}"
            " --input-status {input.loci_status}"
            " --output-annotations {output}"
            " {params.stderr_redirection} {log}"
