#!/usr/bin/env nextflow
/*
========================================================================================
                         SARS-CoV-2-align
========================================================================================
wow it works
----------------------------------------------------------------------------------------
*/

// Using the Nextflow DSL-2 to account for the logic flow of this workflow
nextflow.preview.dsl=2



/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}



/*
 * Import the processes used in this workflow
 */


include Trim from './modules.nf'
include Align from './modules.nf' 

BOWTIE2_PREFIX = params.BOWTIE2_PREFIX



   BWT_FILES = Channel
        .fromPath("${params.BOWTIE2_REF_LOCATION}/${params.BOWTIE2_PREFIX}*")
        .map{it -> file(it)}
        .collect()


// Run the workflow
workflow {

        input_read_ch = Channel
            .fromPath("${params.INPUT_FOLDER}**.fastq.gz")



        // Validate that the inputs are paired-end gzip-compressed FASTQ
        // This will also enforce that all read pairs are named ${sample_name}.R[12].fastq.gz
        Trim(
            input_read_ch,
            file(params.ADAPTER_FILE)
        )
        Align(
        Trim.out ,
        BWT_FILES

        )

        
    
    publish:
        Align.out to: "${params.OUTDIR}"
}