__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2021 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def mergeBamAlignment(
        in_alignments="aln/{sample}.bam",
        in_reference_seq="data/reference.fa",
        in_unmapped_bam="reads/{sample}.ubam",
        out_alignments="aln/{sample}_merged.bam",
        out_stderr="logs/aln/{sample}_mergeBam_stderr.txt",
        params_aligner_proper_pair_flags=False,
        params_create_index=True,
        params_expected_orientations=["FR"],
        params_extra="",
        params_java_mem="5G",
        params_max_gaps=-1,
        params_sort_order="coordinate",
        params_stringency="LENIENT",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Merge BAM/SAM alignment info from a third-party aligner with the data in an unmapped BAM file, producing a third BAM file that has alignment data (from the aligner) and all the remaining data from the unmapped BAM. """
    rule mergeBamAlignment:
        input:
            alignments = in_alignments,
            reference_seq = in_reference_seq,
            unmapped_bam = in_unmapped_bam
        output:
            out_alignments if params_keep_outputs else temp(out_alignments)
        log:
            out_stderr
        params:
            aligner_proper_pair_flags = str(params_aligner_proper_pair_flags).lower(),
            bin_path = config.get("software_paths", {}).get("picard", "picard"),
            create_index = str(params_create_index).lower(),
            extra = params_extra,
            java_mem = params_java_mem,
            max_gaps = params_max_gaps,
            expected_orientations = params_expected_orientations,
            sort_order = params_sort_order,
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            stringency = params_stringency
        conda:
            "envs/picard.yml"
        shell:
            "{params.bin_path} MergeBamAlignment"
            " -Xmx{params.java_mem}"
            " {params.extra}"
            " ALIGNER_PROPER_PAIR_FLAGS={params.aligner_proper_pair_flags}"
            " MAX_GAPS={params.max_gaps}"
            " EXPECTED_ORIENTATIONS={params.expected_orientations}"
            " SORT_ORDER={params.sort_order}"
            " VALIDATION_STRINGENCY={params.stringency}"
            " CREATE_INDEX={params.create_index}"
            " REFERENCE_SEQUENCE {input.reference_seq}"
            " UNMAPPED_BAM {input.unmapped_bam}"
            " ALIGNED_BAM {input.alignments}"
            " OUTPUT={output}"
            " {params.stderr_redirection} {log}"
