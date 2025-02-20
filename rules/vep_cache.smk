__author__ = 'Frederic Escudie'
__copyright__ = 'Copyright (C) 2019 CHU Toulouse'
__license__ = 'GNU General Public License'
__version__ = '2.9.0'


def vep_cache(
        params_reference_species,
        in_variants="variants/{variant_caller}/{sample}_call.vcf",
        in_cache=None,
        in_cosmic=None,
        in_customs=None,
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
    in_cosmic_index = []
    if in_cosmic:
        if isinstance(in_cosmic, snakemake.io.AnnotatedString) and "storage_object" in in_cosmic.flags:
            in_cosmic_index.append(storage(in_cosmic.flags["storage_object"].query + ".tbi"))
        else:
            in_cosmic_index.append(in_cosmic + ".tbi")
    in_customs_index = []
    if in_customs:
        for path in in_customs:
            if isinstance(path, snakemake.io.AnnotatedString) and "storage_object" in path.flags:
                in_customs_index.append(storage(path.flags["storage_object"].query + ".tbi"))
            else:
                in_customs_index.append(path + ".tbi")
    # VEP
    rule:
        name:
            "vep_cache" + snake_rule_suffix
        input:
            cache = in_cache,
            customs = in_customs if in_customs else [],
            customs_index = in_customs_index,
            variants = in_variants
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
            " --input_file {input.variants}"
            " --output_file {output}"
            " > {log.stdout}"
            " {params.stderr_redirection} {log.stderr}"
    # Reverse normalisation produced by VEP in allele annotation field
    rule:
        name:
            "fixVEPAnnot" + snake_rule_suffix
        input:
            cosmic = [] if in_cosmic is None else in_cosmic,
            cosmic_index = in_cosmic_index,
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


def vepCustomArgs(custom_db, release_earlier_109=True):
    """
    Return VEP arguments for custom databases and annotation selected fields.

    :param custom_db: Info for custom databases. Each databse is dict like {"name": str, "path": str, "fields": list, "format": str, "type": str} (format and type are optional).
    :type custom_db: list
    :param release_earlier_109: VEP release used is earlier than 109. This parameters change custom format.
    :type release_earlier_109: bool
    :return: VEP arguments for custom databases and annotation selected fields.
    :rtype: (str, list)
    """
    vep_extra = ""
    fields = ["CLIN_SIG"]
    syntax = " --custom {},{},{},{},0,{}"  # Format: --custom Filename,Short_name,File_type,Annotation_type,Force_report_coordinates,VCF_fields
    fields_linker = ","
    if release_earlier_109:
        syntax = " --custom file={},short_name={},format={},type={},0,fields={},num_records={}"  # file=Filename,short_name=Short_name,format=File_type,type=Annotation_type,fields=VCF_fields
        fields_linker = "%"
    for curr_db in custom_db:
        vep_extra += syntax.format(
            curr_db["path"],
            curr_db["name"],
            curr_db.get("format", "vcf"),
            curr_db.get("type", "exact"),
            fields_linker.join(curr_db["fields"]),
            curr_db.get("num_records", "all")
        )
        if curr_db["name"].lower() == "clinvar":
            fields.remove("CLIN_SIG")
        for field in curr_db["fields"]:
            fields.append(curr_db["name"] + "_" + field)
    return vep_extra, fields
