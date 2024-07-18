__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.7.0'


def vep_cache(
        params_reference_species,
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        in_cache=None,
        in_cosmic=None,
        out_variants="variants/{variant_caller}/{sample}_annot.vcf",
        out_stdout="logs/variants/{variant_caller}/{sample}_annot_stdout.txt",
        out_stderr="logs/variants/{variant_caller}/{sample}_annot_stderr.txt",
        params_annotations_field="ANN",
        params_annotations_source="merged",  # Choices: ["ensembl", "refseq", "merged"]
        params_extra="--flag_pick_allele",
        params_reference_assembly=None,
        params_keep_outputs=False,
        params_stderr_append=False,
        snake_rule_suffix=""):
    """Determine the effect of variants (SNPs, insertions, deletions, CNVs or structural variants) on genes, transcripts, and protein sequence, as well as regulatory regions. It required VEP >= 94."""
    # Parameters
    params_annotations_source_opt = "--merged --xref_refseq --tsl --appris"  # --tsl: Transcript support level ; --appris: Add transcript isoform annotation ; --xref_refseq: RefSeq mRNA identifier
    if params_annotations_source == "ensembl":
        params_annotations_source_opt = "--xref_refseq --tsl --appris"
    elif params_annotations_source == "refseq":
        params_annotations_source_opt = "--refseq"
    # VEP
    rule:
        name:
            "vep_cache" + snake_rule_suffix
        input:
            in_variants
        output:
            temp(out_variants + "_unfixed.tmp")
        log:
            stdout = out_stdout,
            stderr = out_stderr
        params:
            annotations_field = params_annotations_field,
            annotations_source_opt = params_annotations_source_opt,
            assembly = "" if params_reference_assembly is None else "--assembly " + params_reference_assembly,
            extra = params_extra,
            species = params_reference_species,
            vep_cache = "" if in_cache is None else "--dir_cache " + in_cache,
            vep_path = config.get("software_paths", {}).get("vep", "vep"),
            vep_wrapper_path = config.get("software_paths", {}).get("VEPWrapper", "VEPWrapper.py"),
            stderr_redirection = "2>" if not params_stderr_append else "2>>"
        resources:
            extra = "",
            mem = "10G",
            partition = "normal"
        conda:
            "envs/vep_anacore-utils.yml"
        shell:
            "{params.vep_wrapper_path}"
            " {params.vep_path}"
            " --cache"
            " {params.vep_cache}"
            " --offline"
            ' --species "{params.species}"'
            " {params.assembly}"
            " {params.extra}"
            " --numbers"  # Exon and Intron numbering
            " --regulatory"  # Add overlapped regulatory regions
            " --biotype"
            " --hgvs"
            " --symbol"  # HGNC
            " --uniprot"  # UniProt accessions
            " --pubmed"  # Pubmed IDs for publications
            " {params.annotations_source_opt}"
            " --mane"
            " --gene_phenotype"
            " --sift b"
            " --polyphen b"
            " --af"
            " --af_1kg"
            " --af_gnomadg"
            " --no_stats"
            " --vcf"
            " --vcf_info_field {params.annotations_field}"
            " --input_file {input}"
            " --output_file {output}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
    # Reverse normalisation produced by VEP in allele annotation field
    rule:
        name:
            "fixVEPAnnot" + snake_rule_suffix
        input:
            cosmic = [] if in_cosmic is None else in_cosmic,
            variants = out_variants + "_unfixed.tmp"
        output:
            out_variants if params_keep_outputs else temp(out_variants)
        log:
            out_stderr
        params:
            annotations_field = params_annotations_field,
            bin_path = config.get("software_paths", {}).get("fixVEPAnnot", "fixVEPAnnot.py"),
            cosmic_db = "" if in_cosmic is None else "--input-cosmic {}".format(in_cosmic)
        resources:
            extra = "",
            mem = "3G",
            partition = "normal"
        conda:
            "envs/anacore-utils.yml"
        shell:
            "{params.bin_path}"
            " {params.cosmic_db}"
            " --annotations-field {params.annotations_field}"
            " --input-variants {input.variants}"
            " --output-variants {output}"
            " 2>> {log}"
