__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def extractIlluminaBarcodes(
        in_basecalls_dir,
        params_read_structure,
        in_barcodes_file="barcodes.tsv",
        out_dir="demultiplex/extractIlluminaBarcode/L{lane}",
        out_metrics="demultiplex/extractIlluminaBarcode/metrics_L{lane}.tsv",
        out_stderr="logs/demultiplex/extractIlluminaBarcode_L{lane}_stderr.txt",
        params_extra="",
        params_lane="{lane}",
        params_memory="10G",
        params_keep_outputs=False,
        params_threads=1):
    """Determines the barcode for each read in an Illumina lane."""
    rule extractIlluminaBarcodes:
        input:
            barcodes = in_barcodes_file,
            basecalls = in_basecalls_dir
        output:
            metrics = (out_metrics if params_keep_outputs else temp(out_metrics)),
            directory = temp(directory(out_dir))
        log:
            stderr = out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("picard", "picard"),
            extra = params_extra,
            lane = params_lane,
            memory = params_memory,
            read_structure = params_read_structure
        threads: params_threads
        conda:
            "envs/picard.yml"
        shell:
            "mkdir -p {output.directory}"
            " 2> {log.stderr}"
            " && "
            "{params.bin_path} ExtractIlluminaBarcodes"
            " -Xmx{params.memory}"
            " {params.extra}"
            " NUM_PROCESSORS={threads}"
            " LANE={params.lane}"
            " READ_STRUCTURE={params.read_structure}"
            " BARCODE_FILE={input.barcodes}"
            " BASECALLS_DIR={input.basecalls}"
            " OUTPUT_DIR={output.directory}"
            " METRICS_FILE={output.metrics}"
            " 2> {log.stderr}"
