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


include Trim_SE from './modules.nf'
include Align_SE from './modules.nf'

include Trim_PE from './modules.nf'
include Align_PE from './modules.nf' 

BOWTIE2_PREFIX = params.BOWTIE2_PREFIX

params.PAIRED = false

   BWT_FILES = Channel
        .fromPath("${params.BOWTIE2_REF_LOCATION}/${params.BOWTIE2_PREFIX}*")
        .map{it -> file(it)}
        .collect()


// Run the workflow
workflow {
        if(params.PAIRED){ 
        input_read_ch = Channel
            .fromFilePairs("${params.INPUT_FOLDER}*_R{1,2}*.gz")
            .ifEmpty { error "Cannot find any FASTQ pairs in ${params.INPUT_FOLDER} ending with .gz" }
            .map { it -> [it[0], it[1][0], it[1][1]]}
        } else {
        input_read_ch = Channel
            .fromPath("${params.INPUT_FOLDER}**.fastq.gz")
        }


        // Validate that the inputs are paired-end gzip-compressed FASTQ
        // This will also enforce that all read pairs are named ${sample_name}.R[12].fastq.gz
        if( params.PAIRED){ 
        Trim_PE(
            input_read_ch,
            file(params.ADAPTER_FILE)
        )
        Align_PE(
            Trim_PE.out ,
            //BWT_FILES,
            file(params.REF_FASTA)
        )
        } else { 
        Trim_SE(
            input_read_ch,
            file(params.ADAPTER_FILE)
        )
        Align_SE(
            Trim_SE.out ,
            //BWT_FILES,
            file(params.REF_FASTA)
            )
        }
        
    
     publish:
         Align_SE.out to: "${params.OUTDIR}"
}
