__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.3.0'


def microsatLenDistrib(
        in_alignments="aln/{sample}.bam",
        in_microsatellites="design/microsat.bed",
        out_results="microsat/{sample}_microsatLenDistrib.json",
        out_stderr="logs/{sample}_microsatLenDistrib_stderr.txt",
        params_keep_duplicates=False,
        params_method_name=None,
        params_padding=None,
        params_reads_stitched=False,
        params_sample_name="{sample}",
        params_stitch_count=False,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Retrieves the reads length distribution for loci."""
    rule microsatLenDistrib:
        input:
            alignments = in_alignments,
            microsatellites = in_microsatellites
        output:
            out_results if params_keep_outputs else temp(out_results)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("microsatLenDistrib", "microsatLenDistrib.py")),
            keep_duplicates = "--keep-duplicates" if params_keep_duplicates is True else "",
            method_name = "" if params_method_name is None else "--method-name {}".format(params_method_name),
            padding = "" if params_padding is None else "--padding {}".format(params_padding),
            reads_stitched = "--reads-stitched" if params_reads_stitched is True else "",
            sample_name = "" if params_sample_name is None else "--sample-name {}".format(params_sample_name),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stitch_count = "--stitch-count" if params_stitch_count else ""
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.keep_duplicates}"
            " {params.method_name}"
            " {params.padding}"
            " {params.reads_stitched}"
            " {params.sample_name}"
            " {params.stitch_count}"
            " --input-alignments {input.alignments}"
            " --input-microsatellites {input.microsatellites}"
            " --output-results {output}"
            " {params.stderr_redirection} {log}"
