


# 1 Find single copy busco genes in P.cactorum assemblies


Create a list of all BUSCO IDs

```bash
cd /home/groups/harrisonlab/project_files/idris

# pushd /home/sobczm/bin/BUSCO_v1.22/fungi/hmms
OutDir=analysis/popgen/busco_phylogeny
mkdir -p $OutDir
BuscoDb="eukaryota_odb9"
ls -1 /home/groups/harrisonlab/dbBusco/$BuscoDb/hmms/*hmm | rev | cut -f1 -d '/' | rev | sed -e 's/.hmm//' > $OutDir/all_buscos_"$BuscoDb".txt
```

For each busco gene create a folder and move all single copy busco hits from
each assembly to the folder.
Then create a fasta file containing all the aligned reads for each busco gene for
alignment later.

```bash
printf "" > analysis/popgen/busco_phylogeny/single_hits.txt
for Busco in $(cat analysis/popgen/busco_phylogeny/all_buscos_*.txt); do
echo $Busco
OutDir=analysis/popgen/busco_phylogeny/$Busco
mkdir -p $OutDir
for Fasta in $(ls gene_pred/busco/*/*/assembly/run_contigs_min_500bp_renamed/single_copy_busco_sequences/$Busco*.fna | grep -v -w '414'); do
Strain=$(echo $Fasta | rev | cut -f5 -d '/' | rev)
Organism=$(echo $Fasta | rev | cut -f6 -d '/' | rev)
FileName=$(basename $Fasta)
cat $Fasta | sed "s/:.*.fasta:/:"$Organism"_"$Strain":/g" > $OutDir/"$Organism"_"$Strain"_"$Busco".fasta
done
cat $OutDir/*_*_"$Busco".fasta > $OutDir/"$Busco"_appended.fasta
SingleBuscoNum=$(cat $OutDir/"$Busco"_appended.fasta | grep '>' | wc -l)
printf "$Busco\t$SingleBuscoNum\n" >> analysis/popgen/busco_phylogeny/single_hits.txt
done
```


If all isolates have a single copy of a busco gene, move the appended fasta to
a new folder

```bash
  OutDir=analysis/popgen/busco_phylogeny/alignments
  mkdir -p $OutDir
  OrganismNum=$(cat analysis/popgen/busco_phylogeny/single_hits.txt | cut -f2 | sort -nr | head -n1)
  for Busco in $(cat analysis/popgen/busco_phylogeny/all_buscos_*.txt); do
  echo $Busco
  HitNum=$(cat analysis/popgen/busco_phylogeny/single_hits.txt | grep "$Busco" | cut -f2)
  if [ $HitNum == $OrganismNum ]; then
    cp analysis/popgen/busco_phylogeny/$Busco/"$Busco"_appended.fasta $OutDir/.
  fi
  done
```

Submit alignment for single copy busco genes with a hit in each organism


```bash
  AlignDir=analysis/popgen/busco_phylogeny/alignments
  CurDir=$PWD
  cd $AlignDir
  ProgDir=/home/armita/git_repos/emr_repos/scripts/popgen/phylogenetics
  qsub $ProgDir/sub_mafft_alignment.sh
  cd $CurDir
```



```bash
# For closely related organisms (same species etc.): identify genes with high nucleotide diversity (Pi) and average number of pairwise differences, medium number of segregating sites
# (avoid alignments with low homology and lots of phylogenetically uninformative singletons).
# For analyses involving cross-species comparisons involving highly diverged sequences with high nucleotide diversity
# (e.g. 0.1<Pi<0.4), looking for genes with the lowest number of segregating sites.
AlignDir=analysis/popgen/busco_phylogeny/alignments
CurDir=$PWD
cd $AlignDir

# pip install dendropy --user
for Alignment in $(ls *aligned.fasta); do
ProgDir=/home/armita/git_repos/emr_repos/scripts/popgen/phylogenetics
python $ProgDir/calculate_nucleotide_diversity.py $Alignment
Busco=$(echo $Alignment | cut -f1 -d '_')
mv sequence_stats.txt "$Busco"_seqeunce_stats.txt
mv excel_stats.txt "$Busco"_excel_stats.txt
mkdir -p ../phylogeny
## Copy FASTA files of the aligments into a new directory
cp $Alignment ../phylogeny/.
done

cd $CurDir
```

Visually inspect the alignments of select genes (genes_selected_for_phylogeny.txt) to be used in
constructing the phylogenies and trim them as necessary in MEGA7.
Copy the relevant trimmed alignment FASTA files into

```bash
  # mkdir $CurDir/beast_runs/candidates/select/trimmed
```


##PartitionFinder (nucleotide sequence evolution model)

```bash
cd analysis/popgen/busco_phylogeny

config_template=/home/sobczm/bin/PartitionFinder1.1.1/partition_finder.cfg
ct=$(basename "$config_template")

mkdir NEXUS

# prepare directory for PartitionFinder run:
for f in $(ls *fasta); do
sed -i 's/:/_/g' $f
c="$(cat $f | awk 'NR%2==0' | awk '{print length($1)}' | head -1)"
p="${f%.fasta}.phy"
n="${f%.fasta}.NEXUS"
dir="${f%.fasta}"

mkdir $dir
cp $config_template $dir/.

# Substitute the name of the alignment file and the sequence length in the config file to become correct for the current run.
sed -i 's,^\(alignment = \).*,\1'"$p;"',' $dir/$ct
sed -i 's,^\(Gene1_pos1 = \).*,\1'"1-$c\\\3;"',' $dir/$ct
sed -i 's,^\(Gene1_pos2 = \).*,\1'"2-$c\\\3;"',' $dir/$ct
sed -i 's,^\(Gene1_pos3 = \).*,\1'"3-$c\\\3;"',' $dir/$ct

# Convert FASTA to phylip for the Partition Finder run
ProgDir=/home/armita/git_repos/emr_repos/scripts/popgen/phylogenetics
$ProgDir/fasta2phylip.pl $f>$p
mv $p $dir

# Convert FASTA to NEXUS for the BEAST run
$ProgDir/Fasta2Nexus.pl $f>$n
mv $n NEXUS

#Problems running PartitionFinder on the cluster. May have to be run locally on your Mac or Windows machine.
# qsub $ProgDir/sub_partition_finder.sh $dir
done
```

Partition finder wasnt run on the cluster. As such fasta alignment files were
downloaded to the local machine where partitionfinder was run
patritionfinder2 was downloaded from:
http://www.robertlanfear.com/partitionfinder/

and the anaconda libraries to support it were downloaded from:
https://www.continuum.io/downloads#macos


copy the fasta files and the partitionfinder config files to
your local computer

```bash
scp -r cluster:/home/groups/harrisonlab/project_files/idris/analysis/popgen/busco_phylogeny/phylogeny/* .
for Dir in $(ls -d *_appended_aligned); do
/Users/armita/anaconda2/bin/python ../partitionfinder-2.1.1/PartitionFinder.py $Dir --no-ml-tree --force-restart
done > log.txt

```