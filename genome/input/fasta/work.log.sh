# 记录hg19测序参考文件的整理过程

cd ~/genome/input/fasta

tar xvzf chromFa.tar.gzip
cat *.fa > hg19.fa
rm chr*.fa

# 为参考基因组的构建索引

~/biosoft/bwa/0.7.12/bwa index hg19.fa
[bwa_index] Pack FASTA... 33.21 sec
[bwa_index] Construct BWT for the packed sequence...
[BWTIncCreate] textLength=6274322528, availableWord=453484340
[BWTIncConstructFromPacked] 10 iterations done. 100000000 characters processed.

[bwt_gen] Finished constructing BWT in 695 iterations.
[bwa_index] 2833.47 seconds elapse.
[bwa_index] Update BWT... 16.83 sec
[bwa_index] Pack forward-only FASTA... 19.15 sec
[bwa_index] Construct SA from BWT and Occ... 1141.03 sec
[main] Version: 0.7.12-r1039
[main] CMD: /home/elon/biosoft/bwa/0.7.12/bwa index hg19.fa
[main] Real time: 4215.845 sec; CPU: 4043.697 sec

# 为参考序列生成一个.dict文件
java -jar ~/biosoft/picard/2.18.2/picard.jar CreateSequenceDictionary \
> R=hg19.fa \
> O=hg19.dict && echo "** generate dict done **"

time ~/biosoft/gatk/4.0/gatk CreateSequenceDictionary \
> -R hg19.fa \
> -O hg19.dict && echo "** generate dict done **"

# 我们用samtools为它创建一个索引，这是为方便其他数据分析工具（比如GATK）能够快速地获取fasta上的任何序列做准备。
~/biosoft/samtools/1.0/bin/samtools faidx hg19.fa && echo "** index done **"

