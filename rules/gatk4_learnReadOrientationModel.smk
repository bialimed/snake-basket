__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '1.2.0'


def gatk4_learnReadOrientationModel(
        in_alternatives_table="variants/mutect2/{sample}_f1r2.tar.gz",
        out_model="variants/mutect2/{sample}_strandModel.tar.gz",
        out_stderr="logs/variants/mutect2/{sample}_strandModel_stderr.txt",
        params_keep_outputs=False,
        params_stderr_append=False):
    """Create orientation model from foward and reverse information of reads on variants."""
    rule gatk4_learnReadOrientationModel:
        input:
            variants = in_alternatives_table
        output:
            out_model if params_keep_outputs else temp(out_model)
        log:
            out_stderr
        params:
            bin_path = config.get("software_paths", {}).get("gatk", "gatk"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "8G",
            partition = "normal"
        conda:
            "envs/gatk4.yml"
        shell:
            "{params.bin_path} LearnReadOrientationModel"
            " --alt-table {input}"
            " --output {output}"
            " {params.stderr_redirection} {log}"
