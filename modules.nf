/*
 * Define the processes used in this workflow
 */
BOWTIE2_PREFIX = params.BOWTIE2_PREFIX


process Trim {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    // should build our own docker image for this 
    container "quay.io/biocontainers/bbmap:38.76--h516909a_0"

    // Define the input files
    input:
      file r1
      file ADAPTERS

    // Define the output files
    output:
      file "*trimmed.fastq.gz"


    // Code to be executed inside the task
    script:
      """
#!/bin/bash
set -e
# For logging and debugging, list all of the files in the working directory
ls -lahtr
# Get the sample name from the file name
sample_name=\$(echo ${r1} | sed 's/.R1_001.fastq.gz//')
echo "Processing \$sample_name"
# Rename the input file to make sure we don't use it as the output
mv ${r1} INPUT.${r1}
echo "Trimming ${r1}"
bbduk.sh \
    in=INPUT.${r1} \
    out="\$sample_name.trimmed.fastq.gz" \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    minlength=60 \
    tbo \
    qtrim=r \
    trimq=10 \
    adapters="${ADAPTERS}"
"""
}



process Align {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    //container "quay.io/biocontainers/bbmap:38.76--h516909a_0"
    container "rmonti/bbtools:latest"
    // Define the input files
    input:
      file r1
      //file "*"
      file REF_FASTA
      

    // Define the output files
    output:
      file "*.bam"


    // Code to be executed inside the task
    script:
      """
#!/bin/bash
set -e
# For logging and debugging, list all of the files in the working directory
ls -lahtr
# Get the sample name from the input FASTQ name

# sample_name=`basename -s .trimmed.fastq.gz ${r1}`
sample_name=\$(echo ${r1} | sed 's/.trimmed.fastq.gz//')

echo "Starting the alignment of ${r1}"
#bowtie2 \
#    --no-unal \
#    --threads ${task.cpus} \
#    -x ${BOWTIE2_PREFIX} \
#    -U ${r1} | \
#    samtools view -Sb - > \$sample_name.bam
#    #tee -a \${sample_name}.log
out_cmd="out=""\$sample_name.bam"

bbmap.sh in=${r1} \
ref=${REF_FASTA} \
perfectmode=t \
outm=\$sample_name.bam


      """
}