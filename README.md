# code-challenge-wdl-vep-annotation
A 48 hour challenge to implement vep annotation using WDL

## Testing WDL
I have not used WDL before so am trying to get something resembling the Nextflow pipeline

## Pre-requisites
1. Ensure you have a local installation of Cromwell
2. Ensure you have a local instllation of Docker

## Building the Docker Image
From the directory that contains the `Dockerfile`, run `docker build -t vep:v0.1 .`

If you choose a to name your image differently, then change the runtime lines `docker: "test:v0.1"` in `vep.wdl` to your image name

## Running the Pipeline
Assuming your working directory is this repository and you have a Java binary in your path the command to run this pipeline is `java -jar /path/to/cromwell-X.jar run vep.wdl --inputs vep_inputs.json --options vep_options.json`

## Things I would have liked to add
1. I am pretty sure you can set the Docker container in the options file and that would be more efficient as every task uses same container.
2. The final task (`recombineVCF`) relies on also inputting the first VCF file from the array separately to `grep` the additional header lines, I am sure you can reference the first element in the array in the command section using wdl nomenclature but I could not find it in time.
