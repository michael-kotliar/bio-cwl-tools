#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

doc: MashMap is an approximate long read or contig mapper based on Jaccard similarity

label: MashMap

hints:
  DockerRequirement:
    dockerPull: "quay.io/biocontainers/mashmap:2.0--gsl2.2_1"
  SoftwareRequirement:
    packages:
      mashmap:
        specs: [ "https://github.com/marbl/MashMap" ]
        version: [ "2.0" ]

baseCommand: mashmap

inputs:
  query:
    type: File?
    inputBinding:
      prefix: "-q"
    doc: |
      input query file (fasta/fastq)[.gz]
  query_list:
    type: File?
    inputBinding:
      prefix: "--ql"
    doc: |
      a file containing list of query files, one per line
  reference:
    type: File?
    inputBinding:
      prefix: "-r"
    doc: |
      an input reference file (fasta/fastq)[.gz]      
  reference_genomes_list:
    type: File?
    inputBinding:
      prefix: "--rl"
    doc: |
      a file containing list of reference files, one per line
  output_file:
    type: string
    inputBinding:
      prefix: "-o"
    doc: |
      output file name [default : mashmap.out]
      Space-delimited with each line consisting of 
      query name, length, 0-based start, end, strand,
      target name, length, start, end and mapping nucleotide identity

  # optionals
  minimum_segment_length:
    type: int?
    inputBinding:
      prefix: "--segLength"
    doc: |
      mapping segment length [default : 5,000]
      sequences shorter than segment length will be ignored
  no_split:
    type: boolean
    inputBinding:
      prefix: "--noSplit"
    default: false
    doc: |
      disable splitting of input sequences during mapping [enabled by default]
  identity_threshold:
    type: int?
    inputBinding:
      prefix: "--pi"
    doc: |
      threshold for identity [default : 85]
  kmer_size:
    type: int?
    inputBinding:
      prefix: "--kmer"
    doc: |
      kmer size <= 16 [default : 16] 
  filter_mode:
    type:
      - "null"
      - type: enum
        name: "filter_mode"
        symbols: 
          - "one-to-one"
          - "map"
          - "none"
    inputBinding:
      prefix: "--filter_mode"
    doc: |
      filter modes in mashmap: 'map', 'one-to-one' or 'none' [default: map]
      'map' computes best mappings for each query sequence
      'one-to-one' computes best mappings for query as well as reference sequence
      'none' disables filtering
  # running
  threads:
    type: int?
    inputBinding:
      prefix: "--threads"
    doc: |
      count of threads for parallel execution [default : 1] 

stdout: stdout
stderr: stderr

outputs:
  mashmap:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    doc: |
        space-delimited with each line consisting of 
        query name, length, 0-based start, end, strand,
        target name, length, start, end and mapping nucleotide identity

$namespaces:
  s: http://schema.org/
  edam: https://edamontology.org/

$schemas:
  - https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf
  - https://edamontology.org/EDAM_1.20.owl


s:name: "MashMap"
s:license: "https://github.com/marbl/MashMap/blob/master/LICENSE.txt"

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "EMBL - European Bioinformatics Institute"
  s:member:
  - class: s:Person
    s:name: Martin Beracochea
    s:email: mailto:mbc@ebi.ac.uk
    s:sameAs:
    - id: https://orcid.org/0000-0003-3472-3736
