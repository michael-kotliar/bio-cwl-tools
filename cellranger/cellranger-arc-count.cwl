cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: InlineJavascriptRequirement
- class: InitialWorkDirRequirement
  listing: |
    ${
      var listing = [
        {
          "entry": inputs.gex_fastq_file_r1,
          "entryname": "gex_S1_L001_R1_001.fastq",
          "writable": true
        },
        {
          "entry": inputs.gex_fastq_file_r2,
          "entryname": "gex_S1_L001_R2_001.fastq",
          "writable": true
        },
        {
          "entry": inputs.atac_fastq_file_r1,
          "entryname": "atac_S1_L001_R1_001.fastq",
          "writable": true
        },
        {
          "entry": inputs.atac_fastq_file_r2,
          "entryname": "atac_S1_L001_R2_001.fastq",
          "writable": true
        },
        {
          "entry": inputs.atac_fastq_file_r3,
          "entryname": "atac_S1_L001_R3_001.fastq",
          "writable": true
        },
        {
          "entry":`fastqs,sample,library_type
          ${runtime.outdir},gex,Gene Expression
          ${runtime.outdir},atac,Chromatin Accessibility`,
          "entryname": "libraries.csv"
        }
      ]
      if (inputs.gex_fastq_file_i1){
        listing.push(
          {
            "entry": inputs.gex_fastq_file_i1,
            "entryname": "gex_S1_L001_I1_001.fastq",
            "writable": true
          }
        );
      };
      if (inputs.gex_fastq_file_i2){
        listing.push(
          {
            "entry": inputs.gex_fastq_file_i2,
            "entryname": "gex_S1_L001_I2_001.fastq",
            "writable": true
          }
        );
      };
      if (inputs.atac_fastq_file_i1){
        listing.push(
          {
            "entry": inputs.atac_fastq_file_i1,
            "entryname": "atac_S1_L001_I1_001.fastq",
            "writable": true
          }
        );
      };
      return listing;
    }


hints:
- class: DockerRequirement
  dockerPull: cumulusprod/cellranger-arc:2.0.0


inputs:
  
  gex_fastq_file_r1:
    type: File
    doc: |
      GEX FASTQ read 1 file (will be staged into workdir as gex_S1_L001_R1_001.fastq)

  gex_fastq_file_r2:
    type: File
    doc: |
      GEX FASTQ read 2 file (will be staged into workdir as gex_S1_L001_R2_001.fastq)

  gex_fastq_file_i1:
    type: File?
    doc: |
      GEX FASTQ index i7 file (will be staged into workdir as gex_S1_L001_I1_001.fastq)

  gex_fastq_file_i2:
    type: File?
    doc: |
      GEX FASTQ index i5 file (will be staged into workdir as gex_S1_L001_I2_001.fastq)

  atac_fastq_file_r1:
    type: File
    doc: |
      ATAC FASTQ read 1 file (will be staged into workdir as atac_S1_L001_R1_001.fastq)

  atac_fastq_file_r2:
    type: File
    doc: |
      ATAC FASTQ read 2 (it's actually index i5) file (will be staged into workdir as atac_S1_L001_R2_001.fastq)

  atac_fastq_file_r3:
    type: File
    doc: |
      ATAC FASTQ read 3 (it's actually read 2) file (will be staged into workdir as atac_S1_L001_R3_001.fastq)

  atac_fastq_file_i1:
    type: File?
    doc: |
      ATAC FASTQ index i7 file (will be staged into workdir as atac_S1_L001_I1_001.fastq)

  indices_folder:
    type: Directory
    inputBinding:
      position: 5
      prefix: "--reference"
    doc: |
      Compatible with Cell Ranger ARC reference folder that includes
      STAR and BWA indices. Should be generated by "cellranger-arc mkref"
      command

  exclude_introns:
    type: boolean?
    inputBinding:
      position: 6
      prefix: "--gex-exclude-introns"
    doc: |
      Disable counting of intronic reads. In this mode, only reads that are exonic
      and compatible with annotated splice junctions in the reference are counted.
      Note: using this mode will reduce the UMI counts in the feature-barcode matrix

  force_min_atac_counts:
    type: int?
    inputBinding:
      position: 7
      prefix: "--min-atac-count"
    doc: |
      Cell caller override: define the minimum number of ATAC transposition events
      in peaks (ATAC counts) for a cell barcode.
      Note: this option must be specified in conjunction with `--min-gex-count`.
      With `--min-atac-count=X` and `--min-gex-count=Y` a barcode is defined as a cell
      if it contains at least X ATAC counts AND at least Y GEX UMI counts

  force_min_gex_counts:
    type: int?
    inputBinding:
      position: 8
      prefix: "--min-gex-count"
    doc: |
      Cell caller override: define the minimum number of GEX UMI counts for a cell barcode.
      Note: this option must be specified in conjunction with `--min-atac-count`.
      With `--min-atac-count=X` and `--min-gex-count=Y` a barcode is defined as a cell
      if it contains at least X ATAC counts AND at least Y GEX UMI counts

  force_peaks_bed_file:
    type: File?
    inputBinding:
      position: 9
      prefix: "--peaks"
    doc: |
      Peak caller override: specify peaks to use in downstream analyses from supplied 3-column BED file.
      The supplied peaks file must be sorted by position and not contain overlapping peaks;
      comment lines beginning with `#` are allowed

  threads:
    type: int?
    inputBinding:
      position: 10
      prefix: "--localcores"
    doc: |
      Set max cores the pipeline may request at one time.
      Default: all available

  memory_limit:
    type: int?
    inputBinding:
      position: 11
      prefix: "--localmem"
    doc: |
      Set max GB the pipeline may request at one time
      Default: all available

  virt_memory_limit:
    type: int?
    inputBinding:
      position: 12
      prefix: "--localvmem"
    doc: |
      Set max virtual address space in GB for the pipeline
      Default: all available


outputs:

  web_summary_report:
    type: File
    outputBinding:
      glob: "sample/outs/web_summary.html"
    doc: |
      Run summary metrics and charts in HTML format

  metrics_summary_report:
    type: File
    outputBinding:
      glob: "sample/outs/summary.csv"
    doc: |
      Run summary metrics in CSV format

  barcode_metrics_report:
    type: File
    outputBinding:
      glob: "sample/outs/per_barcode_metrics.csv"
    doc: |
      ATAC and GEX read count summaries generated for every
      barcode observed in the experiment. The columns contain
      the paired ATAC and Gene Expression barcode sequences,
      ATAC and Gene Expression QC metrics for that barcode,
      as well as whether this barcode was identified as a
      cell-associated partition by the pipeline.
      More details:
      https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/output/per_barcode_metrics

  gex_possorted_genome_bam_bai:
    type: File
    outputBinding:
      glob: "sample/outs/gex_possorted_bam.bam"
    secondaryFiles:
    - .bai
    doc: |
      GEX position-sorted reads aligned to the genome and transcriptome annotated with barcode
      information in BAM format
  
  atac_possorted_genome_bam_bai:
    type: File
    outputBinding:
      glob: "sample/outs/atac_possorted_bam.bam"
    secondaryFiles:
    - .bai
    doc: |
      ATAC position-sorted reads aligned to the genome annotated with barcode
      information in BAM format

  filtered_feature_bc_matrix_folder:
    type: Directory
    outputBinding:
      glob: "sample/outs/filtered_feature_bc_matrix"
    doc: |
      Filtered feature barcode matrix stored as a CSC sparse matrix in MEX format.
      The rows consist of all the gene and peak features concatenated together
      (identical to raw feature barcode matrix) and the columns are restricted to
      those barcodes that are identified as cells.

  filtered_feature_bc_matrix_h5:
    type: File
    outputBinding:
      glob: "sample/outs/filtered_feature_bc_matrix.h5"
    doc: |
      Filtered feature barcode matrix stored as a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and peak features concatenated together
      (identical to raw feature barcode matrix) and the columns are restricted to
      those barcodes that are identified as cells.

  raw_feature_bc_matrices_folder:
    type: Directory
    outputBinding:
      glob: "sample/outs/raw_feature_bc_matrix"
    doc: |
      Raw feature barcode matrix stored as a CSC sparse matrix in MEX format.
      The rows consist of all the gene and peak features concatenated together
      and the columns consist of all observed barcodes with non-zero signal for
      either ATAC or gene expression.

  raw_feature_bc_matrices_h5:
    type: File
    outputBinding:
      glob: "sample/outs/raw_feature_bc_matrix.h5"
    doc: |
      Raw feature barcode matrix stored as a CSC sparse matrix in hdf5 format.
      The rows consist of all the gene and peak features concatenated together
      and the columns consist of all observed barcodes with non-zero signal for
      either ATAC or gene expression.   

  secondary_analysis_report_folder:
    type: Directory
    outputBinding:
      glob: "sample/outs/analysis"
    doc: |
      Various secondary analyses that utilize the ATAC data, the GEX data, and their
      linkage: dimensionality reduction and clustering results for the ATAC and GEX
      data, differential expression, and differential accessibility for all clustering
      results above and linkage between ATAC and GEX data.

  gex_molecule_info_h5:
    type: File
    outputBinding:
      glob: "sample/outs/gex_molecule_info.h5"
    doc: |
      Count and barcode information for every GEX molecule observed in the experiment
      in hdf5 format.

  loupe_browser_track:
    type: File
    outputBinding:
      glob: "sample/outs/cloupe.cloupe"
    doc: |
      Loupe Browser visualization file with all the analysis outputs

  atac_fragments_file:
    type: File
    outputBinding:
      glob: "sample/outs/atac_fragments.tsv.gz"
    secondaryFiles:
    - .tbi
    doc: |
      Count and barcode information for every ATAC fragment observed in
      the experiment in TSV format.

  atac_peaks_bed_file:
    type: File
    outputBinding:
      glob: "sample/outs/atac_peaks.bed"
    doc: |
      Locations of open-chromatin regions identified in this sample.
      These regions are referred to as "peaks".

  atac_cut_sites_bigwig_file:
    type: File
    outputBinding:
      glob: "sample/outs/atac_cut_sites.bigwig"
    doc: |
      Genome track of observed transposition sites in the experiment
      smoothed at a resolution of 400 bases in BIGWIG format.

  atac_peak_annotation_file:
    type: File
    outputBinding:
      glob: "sample/outs/atac_peak_annotation.tsv"
    doc: |
      Annotations of peaks based on genomic proximity alone.
      Note that these are not functional annotations and they
      do not make use of linkage with GEX data.

  stdout_log:
    type: stdout

  stderr_log:
    type: stderr


baseCommand: ["cellranger-arc", "count", "--disable-ui", "--libraries", "libraries.csv", "--id", "sample"]


stdout: cellranger_arc_count_stdout.log
stderr: cellranger_arc_count_stderr.log


$namespaces:
  s: http://schema.org/

$schemas:
- https://github.com/schemaorg/schemaorg/raw/main/data/releases/11.01/schemaorg-current-http.rdf

label: "Cell Ranger ARC count - generates single cell feature counts for a single multiome library"
s:name: "Cell Ranger ARC count - generates single cell feature counts for a single multiome library"
s:alternateName: "Counts ATAC and gene expression reads from a single 10x Genomics Cell Ranger Multiome ATAC + Gene Expression library"

s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898


doc: |
  Count ATAC and gene expression reads from a single library.

  Cell Ranger ARC count performs alignment, filtering, barcode counting,
  peak calling and counting of both ATAC and GEX molecules. Furthermore,
  it uses the Chromium cellular barcodes to generate feature-barcode matrices,
  perform dimensionality reduction, determine clusters, perform differential
  analysis on clusters and identify linkages between peaks and genes. The
  count pipeline can take input from multiple sequencing runs on the same
  GEM well.

  Parameters set by default:
  --disable-ui - no need in any UI when running in Docker container
  --id - hardcoded to `sample` to simplify output files location
  --libraries - points to the file libraries.csv generated based on the input FASTQ files

  No implemented parameters:
  --no-bam - we want to always generate BAM files
  --dry
  --noexit
  --nopreflight
  --description
  --uiport
  --overrides
  --jobinterval
  --maxjobs
  --mempercore
  --jobmode (we will use local by default)

  Why do we need to rename input files?
  https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/using/using/fastq-input