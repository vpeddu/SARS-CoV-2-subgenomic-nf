/*
 * Define the processes used in this workflow
 */
BOWTIE2_PREFIX = params.BOWTIE2_PREFIX


process Trim_SE {

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
    tbo \
    qtrim=r \
    trimq=10 \
    minlength=70 \
    adapters="${ADAPTERS}"
"""
}



process Align_SE {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    container "quay.io/biocontainers/bbmap:38.76--h516909a_0"
   // container "quay.io/vpeddu/lava_image:latest"
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





process Trim_PE {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    // should build our own docker image for this 
    container "quay.io/biocontainers/bbmap:38.76--h516909a_0"

    // Define the input files
    input:
      tuple val(prefix), file(r1), file(r2)
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
mv ${r2} INPUT.${r2}
echo "Trimming ${prefix}"
bbduk.sh \
    in=INPUT.${r1} \
    in2=INPUT.${r2} \
    out="\$sample_name.1.trimmed.fastq.gz" \
    out2="\$sample_name.2.trimmed.fastq.gz" \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo \
    qtrim=r \
    trimq=10 \
    minlength=70 \
    adapters="${ADAPTERS}"
"""
}



process Align_PE {

    // Retry at most 3 times
    errorStrategy 'retry'
    maxRetries 3
    
    // Define the Docker container used for this step
    //container "quay.io/biocontainers/bbmap:38.76--h516909a_0"
    container "quay.io/vpeddu/lava_image:latest"
    // Define the input files
    input:
      tuple file(r1), file(r2)
      //file "*"
      file REF_FASTA
      


    // Define the output files
    output:
      file "*.bam"
      tuple file("${r1}"), file("${r2}")


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
#    -1 ${r1} | \
#    samtools view -Sb - > \$sample_name.bam
#    #tee -a \${sample_name}.log
out_cmd="out=""\$sample_name.bam"

/usr/local/miniconda/bin/bbmap.sh in=${r1} in2=${r2} \
ref=${REF_FASTA} \
perfectmode=f \
outm=\$sample_name.bam


      """
}
