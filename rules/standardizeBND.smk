__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2020 IUCT-O'
__license__ = 'GNU General Public License'
__version__ = '1.0.0'


def standardizeBND(
        in_reference_seq="reference/genome.fasta",
        in_variants="structural_variants/{caller}/{sample}_unstd.vcf",
        out_variants="structural_variants/{caller}/{sample}.vcf",
        out_stderr="logs/structural_variants/{sample}_{caller}_standardize_stderr.txt",
        params_sequence_padding=None,
        params_trace_unstandard=False,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_wildcard_constraints=None):
    """Replace N in alt and ref by the convenient nucleotid and move each breakend in pair at the left most position and add uncertainty iin CIPOS tag."""
    snake_wildcard_constraints = {} if snake_wildcard_constraints is None else snake_wildcard_constraints
    rule standardizeBND:
        wildcard_constraints:
            **snake_wildcard_constraints
        input:
            genome = in_reference_seq,
            variants = in_variants
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            bin_path = config.get("software_pathes", {}).get("standardizeBND", "standardizeBND.py"),
            sequence_padding = "" if params_sequence_padding is None else "--sequence-padding " + str(params_sequence_padding),
            stderr_redirection = "2>" if not params_stderr_append else "2>>",
            trace_unstandard = "--trace-unstandard" if params_trace_unstandard else "",
        # conda:
        #     "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.sequence_padding}"
            " {params.trace_unstandard}"
            " --input-genome {input.genome}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " {params.stderr_redirection} {log}"
