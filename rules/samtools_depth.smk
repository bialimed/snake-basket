__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '2.0.0'


def samtools_depth(
        in_targets=None,
        in_alignments="aln/markDup/{sample}.bam",
        out_depths="stats/depth/{sample}_depths.tsv",
        out_stderr="logs/stats/samtoolsDepth/{sample}_stderr.txt",
        params_mode="covered",  # Must be "absolutely_all", "all_targeted" or "covered"
        params_extra="",
        params_max_depth=0,  # No max
        params_min_map_qual=None,
        params_min_read_qual=None,
        params_keep_outputs=False,
        params_stderr_append=False):
    """Depth by positions"""
    rule samtools_depth:
        input:
            alignments = in_alignments,
            targets = [] if in_targets is None else in_targets
        output:
            out_depths if params_keep_outputs else temp(out_depths)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("samtools", "samtools"),
            extra = params_extra,
            max_depth = params_max_depth,
            min_read_qual = "" if params_min_read_qual is None else "-q " + str(params_min_read_qual),
            min_map_qual = "" if params_min_map_qual is None else "-Q " + str(params_min_map_qual),
            mode = "-aa" if params_mode == "absolutely_all" else ("-a" if params_mode == "all_targeted" else ""),
            targets = "" if in_targets is None else "-b " + in_targets,
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        conda:
            "envs/samtools.yml"
        shell:
            "{params.bin_path} depth"
            " -m {params.max_depth}"
            " {params.mode}"
            " {params.min_read_qual}"
            " {params.min_map_qual}"
            " {params.extra}"
            " {params.targets}"
            " {input.alignments}"
            " > {output}"
            " {params.stderr_redirection} {log}"
