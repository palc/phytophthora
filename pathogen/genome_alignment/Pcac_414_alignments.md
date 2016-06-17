
# 1. Alignment of Pcac raw reads vs the 414 genome

Alignment of reads from a single run:

```bash
  Reference=$(ls repeat_masked/*/*/filtered_contigs_repmask/*_contigs_unmasked.fa | grep -w '414')
  for StrainPath in $(ls -d qc_dna/paired/P.cactorum/* | grep -v '10300' | grep -v '404' | grep -v '414' | grep -v '411'); do
    Organism=$(echo $StrainPath | rev | cut -f2 -d '/' | rev)
    Strain=$(echo $StrainPath | rev | cut -f1 -d '/' | rev)
    echo "$Organism - $Strain"
    F_Read=$(ls $StrainPath/F/*.fq.gz)
    R_Read=$(ls $StrainPath/R/*.fq.gz)
    echo $F_Read
    echo $R_Read
    OutDir=analysis/genome_alignment/bowtie/$Organism/$Strain/vs_414
    ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/genome_alignment
    qsub $ProgDir/bowtie/sub_bowtie.sh $Reference $F_Read $R_Read $OutDir
  done
```

Alignment of reads from multiple sequencing runs:

```bash
  Reference=$(ls repeat_masked/*/*/filtered_contigs_repmask/*_contigs_unmasked.fa | grep -w '414')
  for StrainPath in $(ls -d qc_dna/paired/P.cactorum/* | grep -w -e '404'); do
    echo $StrainPath
    Strain=$(echo $StrainPath | rev | cut -f1 -d '/' | rev)
    Organism=$(echo $StrainPath | rev | cut -f2 -d '/' | rev)
    echo "$Organism - $Strain"
    F1_Read=$(ls $StrainPath/F/*.fq.gz | head -n1);
    R1_Read=$(ls $StrainPath/R/*.fq.gz | head -n1);
    F2_Read=$(ls $StrainPath/F/*.fq.gz | tail -n1);
    R2_Read=$(ls $StrainPath/R/*.fq.gz | tail -n1);
    echo $F1_Read
    echo $R1_Read
    echo $F2_Read
    echo $R2_Read
    OutDir=analysis/genome_alignment/bowtie/$Organism/$Strain/vs_414
    qsub $ProgDir/bowtie/sub_bowtie_2lib.sh $Reference $F1_Read $R1_Read $F2_Read $R2_Read $OutDir
  done
  for StrainPath in $(ls -d qc_dna/paired/P.cactorum/* | grep -w -e '10300'); do
    echo $StrainPath
    Strain=$(echo $StrainPath | rev | cut -f1 -d '/' | rev)
    Organism=$(echo $StrainPath | rev | cut -f2 -d '/' | rev)
    echo "$Organism - $Strain"
    F1_Read=$(ls $StrainPath/F/*300bp*.fq.gz | head -n1);
    R1_Read=$(ls $StrainPath/R/*300bp*.fq.gz | head -n1);
    F2_Read=$(ls $StrainPath/F/*300bp*.fq.gz | tail -n1);
    R2_Read=$(ls $StrainPath/R/*300bp*.fq.gz | tail -n1);
    echo $F1_Read
    echo $R1_Read
    echo $F2_Read
    echo $R2_Read
    OutDir=analysis/genome_alignment/bowtie/$Organism/$Strain/300bp_vs_414
    qsub $ProgDir/bowtie/sub_bowtie_2lib.sh $Reference $F1_Read $R1_Read $F2_Read $R2_Read $OutDir
    F1_Read=$(ls $StrainPath/F/*1Kb*.fq.gz | head -n1);
    R1_Read=$(ls $StrainPath/R/*1Kb*.fq.gz | head -n1);
    F2_Read=$(ls $StrainPath/F/*1Kb*.fq.gz | tail -n1);
    R2_Read=$(ls $StrainPath/R/*1Kb*.fq.gz | tail -n1);
    echo $F1_Read
    echo $R1_Read
    echo $F2_Read
    echo $R2_Read
    OutDir=analysis/genome_alignment/bowtie/$Organism/$Strain/1Kb_vs_414
    qsub $ProgDir/bowtie/sub_bowtie_2lib.sh $Reference $F1_Read $R1_Read $F2_Read $R2_Read $OutDir
  done
```
<!--
Alignment of reads from P.idaei:

```bash
  Reference=$(ls repeat_masked/*/*/filtered_contigs_repmask/*_contigs_unmasked.fa | grep -w '414')
  for StrainPath in $(ls -d qc_dna/paired/P.ideai/*); do
    Organism=$(echo $StrainPath | rev | cut -f2 -d '/' | rev)
    Strain=$(echo $StrainPath | rev | cut -f1 -d '/' | rev)
    echo "$Organism - $Strain"
    F_Read=$(ls $StrainPath/F/*.fq.gz)
    R_Read=$(ls $StrainPath/R/*.fq.gz)
    echo $F_Read
    echo $R_Read
    OutDir=analysis/genome_alignment/bowtie/$Organism/$Strain/vs_414
    ProgDir=/home/armita/git_repos/emr_repos/tools/seq_tools/genome_alignment
    qsub $ProgDir/bowtie/sub_bowtie.sh $Reference $F_Read $R_Read $OutDir
  done
``` -->