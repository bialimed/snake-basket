__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def bismark_extractor(
        in_alignments="bismarkAln/{sample}.bam",
        out_dir="methylation/{sample}",
        out_stderr="logs/{sample}_bismarkExtract_stderr.txt",
        params_buffer_size="2G",
        params_compressed=True,
        params_is_paired_end=True,
        params_nb_threads=1,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Extract cytosines methylation from alignments produced by bismark."""
    in_basename = os.path.splitext(os.path.basename(in_alignments))[0]
    file_pattern = os.path.join(
        out_dir,
        "##BME_PREFIX##_{}.txt{}".format(in_basename, ".gz" if params_compressed else ""),
    )
    out_begraph = os.path.join(out_dir, in_basename + ".bedGraph.gz")
    out_report = os.path.join(out_dir, in_basename + "_splitting_report.txt")
    out_coverage = os.path.join(out_dir, in_basename + ".bismark.cov.gz")
    # Rule
    rule bismark_extractor:
        input:
            in_alignments
        output:
            bedgraph = out_begraph if params_keep_outputs else temp(out_begraph),
            coverage = out_coverage if params_keep_outputs else temp(out_coverage),
            report = out_report if params_keep_outputs else temp(out_report),
            # cpg_ctot = file_pattern.replace("##BME_PREFIX##", "CpG_CTOT"),
            # cpg_ob = file_pattern.replace("##BME_PREFIX##", "CpG_OB"),
            # cpg_ctob = file_pattern.replace("##BME_PREFIX##", "CpG_CTOB"),
            # cpg_ot = file_pattern.replace("##BME_PREFIX##", "CpG_OT"),
            # chg_ctot = file_pattern.replace("##BME_PREFIX##", "CHG_CTOT"),
            # chg_ob = file_pattern.replace("##BME_PREFIX##", "CHG_OB"),
            # chg_ctob = file_pattern.replace("##BME_PREFIX##", "CHG_CTOB"),
            # chg_ot = file_pattern.replace("##BME_PREFIX##", "CHG_OT"),
            # chh_ctot = file_pattern.replace("##BME_PREFIX##", "CHH_CTOT"),
            # chh_ob = file_pattern.replace("##BME_PREFIX##", "CHH_OB"),
            # chh_ctob = file_pattern.replace("##BME_PREFIX##", "CHH_CTOB"),
            # chh_ot = file_pattern.replace("##BME_PREFIX##", "CHH_OT")
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("bismark_methylation_extractor", "bismark_methylation_extractor"),
            buffer_size = params_buffer_size,
            compression = "--gzip" if params_compressed else "",
            out_dir = out_dir,
            paired_end = "--paired-end" if params_is_paired_end else "--single-end",
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        threads: params_nb_threads
        conda:
            "envs/bismark.yml"
        shell:
            "{params.bin_path}"
            " {params.compression}"
            " --parallel {threads}"
            " --buffer_size {params.buffer_size}"
            " --bedGraph"
            " {params.paired_end}"
            " {input}"
            " --output {params.out_dir}"
            " {params.stderr_redirection} {log}"
        # --include_overlap by default only use R1
