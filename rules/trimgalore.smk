__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'

import os


def trimgalore(
        in_R1="data/{sample}_R1.fastq.gz",
        in_R2=None,
        out_R1="trim/{sample}_R1.fastq.gz",
        out_R2="trim/{sample}_R2.fastq.gz",
        out_stderr="logs/{sample}_trimgalore_stderr.txt",
        params_extra="",
        params_quality_offset=None,  # 33 by default
        params_match_stringency=None,
        params_min_length=None,
        params_trim_qual_threshold=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Apply adapter and quality trimming to FastQ files, with extra functionality for RRBS data."""
    # Parameters
    out_dir = os.path.dirname(out_R1)
    basename, extension = os.path.splitext(os.path.basename(out_R1))
    # Rules
    if in_R2 is None:  # Single-end
        rule trimgalore:
            input:
                in_R1,
            output:
                out_R1 if params_keep_outputs else temp(out_R1)
            log:
                out_stderr
            params:
                basename = basename,
                bin_path = config.get("software_paths", {}).get("trim_galore", "trim_galore"),
                extra = params_extra,
                match_stringency = "" if params_match_stringency is None else "--stringency " + str(params_match_stringency),
                min_length = "" if params_min_length is None else "--length " + str(params_min_length),
                out_dir = out_dir,
                quality_encoding = "" if params_quality_offset is None else "--phred" + str(params_quality_offset),
                tmp_R1 = os.path.join(out_dir, basename + "_trimmed.fq.gz"),
                trim_qual_threshold = "" if params_trim_qual_threshold is None else "--quality " + str(trim_qual_threshold),
                stderr_redirection = "2>" if not params_stderr_append else "2>>"
            resources:
                extra = "",
                mem = "5G",
                partition = "normal"
            threads: 1
            conda:
                "envs/trimgalore.yml"
            shell:
                "{params.bin_path}"
                " {params.extra}"
                " --cores {threads}"
                " {params.quality_encoding}"  # --phred33 or --phred64
                " {params.trim_qual_threshold}"  # --quality 20
                " {params.match_stringency}"  # --stringency 1
                " {params.min_length}"  # --length 20
                " --basename {params.basename}"
                " --output_dir {params.out_dir}"
                " {input}"
                " {params.stderr_redirection} {log}"
                " && "
                " mv {params.tmp_R1} {output} 2>> {log}"
    else:  # Paired-end
        rule trimgalore:
            input:
                R1 = in_R1,
                R2 = in_R2
            output:
                R1 = out_R1 if params_keep_outputs else temp(out_R1),
                R2 = out_R2 if params_keep_outputs else temp(out_R2)
            log:
                out_stderr
            params:
                basename = basename,
                bin_path = config.get("software_paths", {}).get("trim_galore", "trim_galore"),
                extra = params_extra,
                match_stringency = "" if params_match_stringency is None else "--stringency " + str(params_match_stringency),
                min_length = "" if params_min_length is None else "--length " + str(params_min_length),
                out_dir = out_dir,
                quality_encoding = "" if params_quality_offset is None else "--phred" + str(params_quality_offset),
                tmp_R1 = os.path.join(out_dir, basename + "_val_1.fq.gz"),
                tmp_R2 = os.path.join(out_dir, basename + "_val_2.fq.gz"),
                trim_qual_threshold = "" if params_trim_qual_threshold is None else "--quality " + str(trim_qual_threshold),
                stderr_redirection = "2>" if not params_stderr_append else "2>>"
            resources:
                extra = "",
                mem = "5G",
                partition = "normal"
            threads: 1
            conda:
                "envs/trimgalore.yml"
            shell:
                "{params.bin_path}"
                " {params.extra}"
                " --cores {threads}"
                " {params.quality_encoding}"  # --phred33 or --phred64
                " {params.trim_qual_threshold}"  # --quality 20
                " {params.match_stringency}"  # --stringency 1
                " {params.min_length}"  # --length 20
                " --basename {params.basename}"
                " --output_dir {params.out_dir}"
                " --paired"
                " {input.R1}"
                " {input.R2}"
                " {params.stderr_redirection} {log}"
                " && "
                " mv {params.tmp_R1} {output.R1} 2>> {log}"
                " && "
                " mv {params.tmp_R2} {output.R2} 2>> {log}"
