---- 2018 4.9 ------

cd genome/output/

# 1.Align the paired reads to reference genome using bwa mem.
~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:SRR799550\tPL:illumina\tSM:SRR799550' ../fasta/hg19.fa SRR799550_1.fastq.gz SRR799550_2.fastq.gz | ~/biosoft/samtools/1.0/bin/samtools view -S -b - > ../../output/SRR799550.bam && echo "** 序列比对完成 **"

# 2.Sort Bam
time samtools sort -@ 4 -O bam -o SRR799550.sorted.bam SRR799550.bam -T PREFIX.bam && echo "** Bam 排序完成 **"

rm -rf SRR799550.bam

# 3.Mark Duplicate Reads 标记重复序列并去除
java -jar ~/biosoft/picard/2.18.2/picard.jar MarkDuplicates \
I=SRR799550.sorted.bam \
O=SRR799550.sorted.markup.bam \
M=SRR799550.markup_metrics.txt

[Mon Apr 09 22:24:37 CST 2018] picard.sam.markduplicates.MarkDuplicates done. Elapsed time: 31.15 minutes.


~/biosoft/samtools/1.0/bin/samtools index SRR799550.sorted.markup.bam

# 4.Create Realign Target 局部重比对
java -jar ~/biosoft/gatk/3.8/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R ~/genome/input/fasta/hg19.fa \
-I ~/genome/output/SRR799550.sorted.markup.bam \
-o ~/genome/output/SRR799550.IndelRealigner.intervals \
-known ~/Downloads/1000G_phase1.indels.hg19.sites.vcf \
-known ~/Downloads/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf

java -jar $GATK \
-R $REF
-T RealignerTargetCreator \
-I SRR799550.dedup.bam -o SRR799550.intervals \
-known 1000G_phase1.indels.hg19.sites.vcf

java -jar $GATK \
-R $REF
-T RealignerTargetCreator \
-I SRR799555.dedup.bam -o SRR799555.intervals \
-known 1000G_phase1.indels.hg19.sites.vcf

# 5.Indel Realigner
java $GATK \
-R $REF
-T IndelRealigner \
-I SRR799550.dedup.bam \
-targetIntervals SRR799550.intervals -o SRR799550.realign.bam

java $GATK \
-R $REF
-T IndelRealigner \
-I SRR799555.dedup.bam \
-targetIntervals SRR799555.intervals -o SRR799555.realign.bam

# 重新校正碱基质量值（BQSR）
~/biosoft/gatk/4.0/gatk BaseRecalibrator -R ../input/fasta/hg19.fa -I SRR799555.sorted.markup.bam -known-sites /media/elon/集群/1000G_phase1.indels.hg19.vcf -known-sites /media/elon/集群/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -known-sites /media/elon/集群/dbsnp_138.hg19.vcf -O SRR799555.recal_data.table


java -jar /path/to/GenomeAnalysisTK.jar \ 
-T BaseRecalibrator \ 
-R /path/to/human.fasta \ 
-I sample_name.sorted.markdup.realign.bam \ 
—knownSites /path/to/gatk/bundle/1000G_phase1.indels.b37.vcf \ 
—knownSites /path/to/gatk/bundle/Mills_and_1000G_gold_standard.indels.b37.vcf \ 
—knownSites /path/to/gatk/bundle/dbsnp_138.b37.vcf \ 
-o sample_name.recal_data.table 

java -jar /path/to/GenomeAnalysisTK.jar \ 
-T PrintReads \ 
-R /path/to/human.fasta \ 
-I sample_name.sorted.markdup.realign.bam \ 
—BQSR sample_name.recal_data.table \ 
-o sample_name.sorted.markdup.realign.BQSR.bam


# 变异检测 对每一个样本先产生GVCF文件，最后合并为一个VCF文件
java -jar /path/to/GenomeAnalysisTK.jar \ 
-T HaplotypeCaller \ 
-R /path/to/human.fasta \ 
-I SRR799550.sorted.markdup.realign.BQSR.bam \ 
--emitRefConfidence GVCF \ 
-o SRR799550.g.vcf

java -jar /path/to/GenomeAnalysisTK.jar \ 
-T HaplotypeCaller \ 
-R /path/to/human.fasta \ 
-I SRR799555.sorted.markdup.realign.BQSR.bam \ 
--emitRefConfidence GVCF \ 
-o SRR799555.g.vcf

java -jar /path/to/GenomeAnalysisTK.jar \ 
-T GenotypeGVCFs \ 
-R /path/to/human.fasta \ 
--variant SRR799550.g.vcf \ 
--variant SRR799555.g.vcf \
-o wgs.HC.vcf


# 变异检测质控和过滤（VQSR）
## SNP Recalibrator
java -jar /path/to/GenomeAnalysisTK.jar \ 
-T VariantRecalibrator \ 
-R reference.fasta \ 
-input sample_name.HC.vcf \ 
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 /path/to/gatk/bundle/hapmap_3.3.b37.vcf \ -resource:omini,known=false,training=true,truth=false,prior=12.0 /path/to/gatk/bundle/1000G_omni2.5.b37.vcf \ -resource:1000G,known=false,training=true,truth=false,prior=10.0 /path/to/gatk/bundle/1000G_phase1.snps.high_confidence.b37.vcf \ -resource:dbsnp,known=true,training=false,truth=false,prior=6.0 /path/to/gatk/bundle/dbsnp_138.b37.vcf \ 
-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an DP \ 
-mode SNP \ 
-recalFile sample_name.HC.snps.recal \ 
-tranchesFile sample_name.HC.snps.tranches \ 
-rscriptFile sample_name.HC.snps.plots.R 

java -jar /path/to/GenomeAnalysisTK.jar 
-T ApplyRecalibration \ 
-R human_g1k_v37.fasta \ 
-input sample_name.HC.vcf \ 
--ts_filter_level 99.5 \ 
-tranchesFile sample_name.HC.snps.tranches \ 
-recalFile sample_name.HC.snps.recal \ 
-mode SNP \ 
-o sample_name.HC.snps.VQSR.vcf

## Indel Recalibrator
java -jar /path/to/GenomeAnalysisTK.jar 
-T VariantRecalibrator \ 
-R human_g1k_v37.fasta \ 
-input sample_name.HC.snps.VQSR.vcf \ 
-resource:mills,known=true,training=true,truth=true,prior=12.0 /path/to/gatk/bundle/Mills_and_1000G_gold_standard.indels.b37.vcf \ 
-an QD -an DP -an FS -an SOR -an ReadPosRankSum -an MQRankSum \ 
-mode INDEL \ 
-recalFile sample_name.HC.snps.indels.recal \ 
-tranchesFile sample_name.HC.snps.indels.tranches \ 
-rscriptFile sample_name.HC.snps.indels.plots.R 

java -jar /path/to/GenomeAnalysisTK.jar -T ApplyRecalibration \ 
-R human_g1k_v37.fasta\ 
-input sample_name.HC.snps.VQSR.vcf \ 
--ts_filter_level 99.0 \ 
-tranchesFile sample_name.HC.snps.indels.tranches \ 
-recalFile sample_name.HC.snps.indels.recal \ 
-mode INDEL \ 
-o sample_name.HC.snps.indels.VQSR.vcf









# 6.bam to mpileup
samtools mpileup -f $REF SRR799550.realign.bam 1>SRR799550.mpileup.txt

samtools mpileup -f $REF SRR799555.realign.bam 1>SRR799555.mpileup.txt

# 7.snp-calling by bcftools
samtools mpileup -guSDf $REF $i | bcftools view -cvNg - > SRR799550.bcftools.vcf


---- 2018 4.8 ------
# 对fastq样本文件做比对处理

cd ~/genome/input/fastq

~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:SRR799550\tPL:illumina\tSM:SRR799550' ../fasta/hg19.fa KPGP-00001_L1_R1.fq.gz KPGP-00001_L1_R2.fq.gz >../../output/KPGP-00001_L1.bam
... ...
[M::mem_process_seqs] Processed 70138 reads in 37.961 CPU sec, 9.552 real sec
[main] Version: 0.7.12-r1039
[main] CMD: /home/elon/biosoft/bwa/0.7.12/bwa mem -t 4 -R @RG\tID:KPGP-00001\tPL:illumina\tSM:KPGP-00001_L1 ../fasta/hg19.fa KPGP-00001_L1_R1.fq.gz KPGP-00001_L1_R2.fq.gz
[main] Real time: 22244.454 sec; CPU: 87050.180 sec
(arg: 0) 


# 比对完之后是对bam文件进行排序，相当于之前比对的无序文件内容做一个有序的规整
time ~/biosoft/samtools/1.0/bin/samtools sort -@ 4 -O bam -o /media/elon/集群/KPGP-00001_L1.sorted.bam KPGP-00001_L1.bam -T /media/elon/集群/PREFIX.bam && echo "** BAM sort done **"
[bam_sort_core] merging from 100 files...
real	117m40.319s
user	78m46.740s
sys	2m16.092s
** BAM sort done **

# 重比对
time ~/biosoft/gatk/4.0/gatk MarkDuplicates -I /media/elon/集群/KPGP-00001_L1.sorted.bam -O /media/elon/集群/KPGP-00001_L1.sorted.markup.bam -M /media/elon/集群/KPGP-00001_L1.sorted.markup_metrics.txt && echo "** markup done **" 
Using GATK jar /home/elon/biosoft/gatk/4.0/gatk-package-4.0.2.1-local.jar
Running:
    java -Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -jar /home/elon/biosoft/gatk/4.0/gatk-package-4.0.2.1-local.jar MarkDuplicates -I /media/elon/集群/KPGP-00001_L1.sorted.bam -O /media/elon/集群/KPGP-00001_L1.sorted.markup.bam -M /media/elon/集群/KPGP-00001_L1.sorted.markup_metrics.txt
18:01:41.759 INFO  NativeLibraryLoader - Loading libgkl_compression.so from jar:file:/home/elon/biosoft/gatk/4.0/gatk-package-4.0.2.1-local.jar!/com/intel/gkl/native/libgkl_compression.so
[Sun Apr 08 18:01:41 CST 2018] MarkDuplicates  --INPUT /media/elon/集群/KPGP-00001_L1.sorted.bam --OUTPUT /media/elon/集群/KPGP-00001_L1.sorted.markup.bam --METRICS_FILE /media/elon/集群/KPGP-00001_L1.sorted.markup_metrics.txt  --MAX_SEQUENCES_FOR_DISK_READ_ENDS_MAP 50000 --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 8000 --SORTING_COLLECTION_SIZE_RATIO 0.25 --TAG_DUPLICATE_SET_MEMBERS false --REMOVE_SEQUENCING_DUPLICATES false --TAGGING_POLICY DontTag --CLEAR_DT true --ADD_PG_TAG_TO_READS true --REMOVE_DUPLICATES false --ASSUME_SORTED false --DUPLICATE_SCORING_STRATEGY SUM_OF_BASE_QUALITIES --PROGRAM_RECORD_ID MarkDuplicates --PROGRAM_GROUP_NAME MarkDuplicates --READ_NAME_REGEX <optimized capture of last three ':' separated fields as numeric values> --OPTICAL_DUPLICATE_PIXEL_DISTANCE 100 --MAX_OPTICAL_DUPLICATE_SET_SIZE 300000 --VERBOSITY INFO --QUIET false --VALIDATION_STRINGENCY STRICT --COMPRESSION_LEVEL 1 --MAX_RECORDS_IN_RAM 500000 --CREATE_INDEX false --CREATE_MD5_FILE false --GA4GH_CLIENT_SECRETS client_secrets.json --help false --version false --showHidden false --USE_JDK_DEFLATER false --USE_JDK_INFLATER false
[Sun Apr 08 18:01:41 CST 2018] Executing as elon@longsl on Linux 4.13.0-36-generic amd64; Java HotSpot(TM) 64-Bit Server VM 1.8.0_161-b12; Deflater: Intel; Inflater: Intel; Picard version: Version:4.0.2.1
INFO	2018-04-08 18:01:41	MarkDuplicates	Start of doWork freeMemory: 187979552; totalMemory: 197132288; maxMemory: 1756364800
INFO	2018-04-08 18:01:41	MarkDuplicates	Reading input file and constructing read end information.
INFO	2018-04-08 18:01:41	MarkDuplicates	Will retain up to 6363640 data points before spilling to disk.
INFO	2018-04-08 18:01:49	MarkDuplicates	Read     1,000,000 records.  Elapsed time: 00:00:07s.  Time for last 1,000,000:    7s.  Last read position: chr10:16,620,751
INFO	2018-04-08 18:01:49	MarkDuplicates	Tracking 5935 as yet unmatched pairs. 285 records in RAM.
INFO	2018-04-08 18:01:53	MarkDuplicates	Read     2,000,000 records.  Elapsed time: 00:00:11s.  Time for last 1,000,000:    4s.  Last read position: chr10:32,999,209
INFO	2018-04-08 18:01:53	MarkDuplicates	Tracking 11705 as yet unmatched pairs. 478 records in RAM.
... ...
INFO	2018-04-08 18:20:19	MarkDuplicates	Found 4266786 optical duplicate clusters.
INFO	2018-04-08 18:20:19	MarkDuplicates	Reads are assumed to be ordered by: coordinate
INFO	2018-04-08 18:21:21	MarkDuplicates	Written    10,000,000 records.  Elapsed time: 00:01:01s.  Time for last 10,000,000:   61s.  Last read position: chr10:130,497,767
INFO	2018-04-08 18:22:19	MarkDuplicates	Written    20,000,000 records.  Elapsed time: 00:01:59s.  Time for last 10,000,000:   58s.  Last read position: chr12:22,263,584
INFO	2018-04-08 18:23:18	MarkDuplicates	Written    30,000,000 records.  Elapsed time: 00:02:58s.  Time for last 10,000,000:   59s.  Last read position: chr13:71,422,459
INFO	2018-04-08 18:24:18	MarkDuplicates	Written    40,000,000 records.  Elapsed time: 00:03:58s.  Time for last 10,000,000:   59s.  Last read position: chr15:49,312,528
INFO	2018-04-08 18:25:21	MarkDuplicates	Written    50,000,000 records.  Elapsed time: 00:05:01s.  Time for last 10,000,000:   62s.  Last read position: chr17:21,469,050
INFO	2018-04-08 18:26:21	MarkDuplicates	Written    60,000,000 records.  Elapsed time: 00:06:01s.  Time for last 10,000,000:   60s.  Last read position: chr19:30,882,199
INFO	2018-04-08 18:27:20	MarkDuplicates	Written    70,000,000 records.  Elapsed time: 00:07:00s.  Time for last 10,000,000:   59s.  Last read position: chr1:147,335,144
INFO	2018-04-08 18:28:21	MarkDuplicates	Written    80,000,000 records.  Elapsed time: 00:08:01s.  Time for last 10,000,000:   60s.  Last read position: chr21:10,459,932
INFO	2018-04-08 18:29:23	MarkDuplicates	Written    90,000,000 records.  Elapsed time: 00:09:03s.  Time for last 10,000,000:   61s.  Last read position: chr2:90,376,512
INFO	2018-04-08 18:30:22	MarkDuplicates	Written   100,000,000 records.  Elapsed time: 00:10:02s.  Time for last 10,000,000:   58s.  Last read position: chr3:2,002,949
INFO	2018-04-08 18:31:21	MarkDuplicates	Written   110,000,000 records.  Elapsed time: 00:11:01s.  Time for last 10,000,000:   59s.  Last read position: chr3:164,217,449
INFO	2018-04-08 18:32:21	MarkDuplicates	Written   120,000,000 records.  Elapsed time: 00:12:01s.  Time for last 10,000,000:   59s.  Last read position: chr4:112,416,068
INFO	2018-04-08 18:33:15	MarkDuplicates	Written   130,000,000 records.  Elapsed time: 00:12:55s.  Time for last 10,000,000:   53s.  Last read position: chr5:80,303,477
INFO	2018-04-08 18:34:14	MarkDuplicates	Written   140,000,000 records.  Elapsed time: 00:13:54s.  Time for last 10,000,000:   59s.  Last read position: chr6:63,387,872
INFO	2018-04-08 18:35:08	MarkDuplicates	Written   150,000,000 records.  Elapsed time: 00:14:48s.  Time for last 10,000,000:   54s.  Last read position: chr7:50,800,202
INFO	2018-04-08 18:36:04	MarkDuplicates	Written   160,000,000 records.  Elapsed time: 00:15:44s.  Time for last 10,000,000:   55s.  Last read position: chr8:46,851,696
INFO	2018-04-08 18:37:03	MarkDuplicates	Written   170,000,000 records.  Elapsed time: 00:16:43s.  Time for last 10,000,000:   58s.  Last read position: chr9:77,613,444
INFO	2018-04-08 18:38:01	MarkDuplicates	Written   180,000,000 records.  Elapsed time: 00:17:41s.  Time for last 10,000,000:   58s.  Last read position: chrX:61,685,442
INFO	2018-04-08 18:38:43	MarkDuplicates	Before output close freeMemory: 1906828344; totalMemory: 1927282688; maxMemory: 1927282688
INFO	2018-04-08 18:38:43	MarkDuplicates	After output close freeMemory: 1910501312; totalMemory: 1927282688; maxMemory: 1927282688
[Sun Apr 08 18:38:43 CST 2018] picard.sam.markduplicates.MarkDuplicates done. Elapsed time: 37.03 minutes.
Runtime.totalMemory()=1927282688
Tool returned:
0

real	37m4.500s
user	43m48.960s
sys	2m22.084s
** markup done **


#

