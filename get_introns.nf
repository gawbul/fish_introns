#!/usr/bin/env nextflow

params.species_filename = "species.csv"
params.data_directory = "$projectDir/perl_data"

process convertNames {
    input:
    tuple val(CommonName), val(ScientificName)

    output:
    stdout

    script:
    """
    echo -n "${ScientificName}" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'
    """
}

process downloadIntrons {
    debug true

    maxForks = 10

    input:
    val LatinName

    output:
    stdout

    script:
    """
    get_introns.pl $LatinName ${params.data_directory}
    """
}

workflow {
    species = Channel
    .fromPath( params.species_filename ) \
    | splitCsv( header: true ) \
    | map { row -> tuple( row."Common Name", row."Scientific Name" ) } \
    | convertNames
    
    downloadIntrons(species)
}