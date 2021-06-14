# AnaCore-Snakemake

![license](https://img.shields.io/badge/license-GPLv3-blue)

## Description
This project provides multiples customizable rules for the workflow manager
[Snakemake](https://snakemake.readthedocs.io/en/stable/#). These rules have
built as python function and can be imported (with snakemake include) and
parametrized (with argument of the function).

## Usage
In this paragraph we will add a rule **markDuplicates** in your workflow.

1. Import the rule

  * Copy the rule in your workflow `rules` folder

         workflow_folder/
            rules/
                markDuplicates.smk          
            Snakemake

  * Add the rule in the list of imports `rules/all.smk`

    Add all.smk in rules (once by workflow)

         workflow_folder/
            rules/
                all.smk
                markDuplicates.smk
            Snakemake

    Add the rule in all.smk (it contains all the rules to import)

         ...
         include: "markDuplicates.smk"
         ...

  * Import all the wrapper functions in your `Snakefile`

         ...
         include: "rules/all.smk"
         ...

  The function `markDuplicates()` is now accessibe in your workflow.

2. Call rule in your workflow

  Add the function call and parameters in your code:

        ...
        markDuplicates(
            params_stringency="STRICT"
            params_keep_outputs=True
        )
        ...

  The all the accessible parameters and their default values are presented in
  function declaration of the rule in `markDuplicates.smk`. The main categories
  of these parameters are *input_*, *output_*, *param_* and *snake_* (for
  parameters related to the Snakemake element like wildcards restrictions). Keep
  in mind that input and ouput must be consistent in terms of wildcards like with
  a standard rule.

3. Set execution environment for the rule

  You can provide software of the rule by one of this three ways:

  * The software folder is in `$PATH`.

  * The path of the software is in workflow configuration file:

          ...
          software_paths:
              picard: /home/user/bin/picard
          ...

    *The name of the parameter is in bin_path argument of the `params` section
    of the rule in the `markDuplicates.smk`.*

  * You use conda environment with Snakemake (see option `--use-conda`) and
  the environment of your rule is in `envs` folder:

          workflow_folder/
              envs/
                  picard.yml
              rules/
                  all.smk
                  markDuplicates.smk
              Snakemake

     *The name of the environment file can be found in `conda` section of the
     rule in the `markDuplicates.smk`.*

4. *Configure the computing requirements [optional]*

  This step is necessary only if you use a submission scheduler (e.g. slurm).
  See rules declaration in the `markDuplicates.smk` (only once for this example:
  markDuplicates) and add resources in the file provided to Snakemake with option
  `--cluster-config`:

       ...
       markDuplicates: {
           queue: "normal",
           mem: "8G",
           vmem: "10G",
           threads: 1
       },
       ...

## Copyright
2019 Laboratoire d'Anatomo-Cytopathologie de l'Institut Universitaire du Cancer
Toulouse - Oncopole

## Contact
escudie.frederic@iuct-oncopole.fr
