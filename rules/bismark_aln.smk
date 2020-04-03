__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def bismark_aln(
        in_reference_dir="reference",
        in_R1="trim/{sample}_R1.fastq.gz",
        in_R2=None,
        out_alignments="bismarkAln/{sample}.bam",
        out_stderr="logs/{sample}_bismarkAln_stderr.txt",
        params_aligner="bowtie2",  # bowtie2 or hisat2
        params_extra="",
        params_is_directional=True,
        # params_nb_threads=1,
        # params_nucleotide_coverage=False,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Alignment to bisulfite genome."""
    # Parameters
    if params_aligner not in ["bowtie2", "hisat2"]:
        raise Exception("The algner must be bowtie2 or hisat2.")
    out_dir = os.path.dirname(out_alignments)
    basename, extension = os.path.splitext(os.path.basename(out_alignments))
    out_report = os.path.join(out_dir, basename + ("_SE_report.txt" if in_R2 is None else "_PE_report.txt"))
    out_tmp_aln = out_alignments if params_keep_outputs else temp(out_alignments)
    if in_R2 is not None:  # Paired-end need rename {basename}_pe to {basename}
        out_tmp_aln = temp(out_alignments.replace(basename, basename + "_pe"))
    # Rules
    rule bismark_aln:
        input:
            reference_dir = in_reference_dir,
            R1 = in_R1,
            R2 = [] if in_R2 is None else in_R2
        output:
            alignments = out_tmp_aln,
            report = out_report
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("bismark", "bismark"),
            aligner = "--" + params_aligner,
            basename = basename,
            directional = "" if params_is_directional else "--non_directional",
            extra = params_extra,
            key_r1 = "-1" if in_R2 else "",
            key_r2 = "-2" if in_R2 else "",
            # nucleotide_coverage = "--nucleotide_coverage" if params_nucleotide_coverage else "",
            out_dir = out_dir,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
        # threads: params_nb_threads
        conda:
            "envs/bismark.yml"
        shell:
            "{params.bin_path}"
            " {params.extra}"
            # " --parallel {threads}"  # basename cannot be used in conjonction with parallel
            " {params.aligner}"
            " {params.directional}"
            # " {params.nucleotide_coverage}"
            " --basename {params.basename}"
            " --genome {input.reference_dir}"
            " {params.key_r1} {input.R1}"
            " {params.key_r2} {input.R2}"
            " --output_dir {params.out_dir}"
            " --temp_dir {params.out_dir}"
            " {params.stderr_redirection} {log}"
    if in_R2 is not None:  # Paired-end need rename {basename}_pe to {basename}
        localrules: bismark_aln_rename_pe
        rule bismark_aln_rename_pe:
            input:
                out_tmp_aln
            output:
                out_alignments if params_keep_outputs else temp(out_alignments)
            log:
                out_stderr
            params:
                stderr_redirection = "2>" if not params_stderr_append else "2>>"
            shell:
                "mv"
                " {input}"
                " {output}"
                " 2>> {log}"
