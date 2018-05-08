# 记录fasta 测序文件的整理过程
# 源文件最终存于 ../source 中

cd /home/elon/wgs/input/fasta

bgzip -dc ../source/GCF_000005845.2_ASM584v2_genomic.fna.gz > E.coli_K12_MG1655.fa

/home/elon/biosoft/samtools/1.0/samtools faidx E.coli_K12_MG1655.fa


elon@longsl:~/wgs/input/fasta$ tree
.
├── E.coli_K12_MG1655.fa
├── E.coli_K12_MG1655.fa.fai
└── work.log.sh


# 可以很方便地完成对参考序列（或者任意fasta文件）特定区域序列的提取
samtools faidx E.coli_K12_MG1655.fa NC_000913.3:1000000-1000200 

