echo "################################################################################################################################"
echo "# This BASH script contains a set of instructions to download genomic sequences from the NCBI FTP site,                        #"
echo "# pcruzmorales may 9 2020                                                                                                      #"
echo "# Type download_genomes.sh and a keyword the script will download the genomes with th keyword                                  #"
echo "# usage: download_genomes.sh  'Genus specie strain'   use the quotation marks '                                                #"
echo "# or: download_genomes.sh  'KEYWORD' single word no spaces                                                                     #"
echo "# WARNING: Depending on the keyword you can download THE ENTIRE DATABASE!, you may try grep with your keyword first            #"
echo "# dependencies: curl gunzip                                                                                                    #"
echo "################################################################################################################################"
echo " "
echo " "
set -u # or set -o nounset
#This line Downloads the complete list of bacterial assemblies in the refseq 
echo "GETTING THE DATABASE..."
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt
#Add a '#' symbol after the first time so you dont have to repeat this download every time, but leave it to get the latest database
#this line is to filter only the entries with the keyword 
echo "FINDING THE RIGHT ENTRIES..."
grep "$1"  assembly_summary.txt  > list.txt
#this line is to use the $1.list.txt file (entries with only the keyword) and create file with a list of downloads
awk '{FS="\t"} !/^#/ {print $20} ' list.txt  | sed -E 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fna.gz|'|sed s'/identical//' > downloads.txt
echo "MAKING A LIST OF DOWNLOADS..."
#this line may be problematic in some osX with different sed syntaxis, change the -r option to -E
#osX line
cut -f20 list.txt  | sed -E 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fna.gz|'|sed s'/identical//' > downloads.txt
#ubuntu and no problematic osX line
#cut -f20 list.txt  | sed -r 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fna.gz|'|sed s'/identical//' > downloads.txt
echo "DOWNLOADING THE FILES..."
#this line is to download the files in the list of downloads
wget --input-file=downloads.txt
#this line is to decompress the files which are in gzip format
gunzip *.gz
echo "RENAMING FILES..."
#this line is to create a little script with the orders to rename the files with the species + strain name
awk 'BEGIN {FS="\t"}; {print "mv,"$1"*genomic.fna,"$8$9$1".fna"}' list.txt | sed s'/ /_/g'|sed s'/=/-/g'|sed s'/strain//'|sed s'/(//'|sed s'/)//'|sed 's/-/_/g'|sed 's/,/ /g' >rename.sh
#his line is to run the script that renames the files
sh rename.sh
#this line is to eliminate all the intermediate files that we created 
echo "CLEANING UP..."
rm rename.sh downloads.txt list.txt
echo "ALL DONE :) ..."
