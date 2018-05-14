#!/bin/bash

# Author: elon
# Description: 对于一个比对程序脚本的模板
# Time: 2018-4-5

# 脚本所需的环境变量定义
export BWA=~/biosoft/bwa/0.7.12
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/4.0/gatk
export HADOOP=~/hadoop/bin

# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa

# 定义单个节点可利用的线程数
THREAD=4
# 定义单个节点可利用的内存资源
MEMORY=4G

# 定义RG INFO
INFO_RG='@RG\tID:SRR3226034\tPL:illumina\tSM:E.coli_K12_SRR3226034'

echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############"
echo "--- 开始处理样本 SRR3226034 ---"

# 定义模板变量
INPUT_FILE_R1=SRR3226034_1.fastq.gz
INPUT_FILE_R2=SRR3226034_2.fastq.gz

cd /tmp
# 从HDFS上下载测序样本Block块
echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1" >&2
time $HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1 && echo "" >&2

echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2" >&2
time $HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2
echo "*** download sample file from HDFS" && echo "" >&2

# ××××××  基因测序 ×××××××
# 步骤一 比对
echo "###COMMAND LINE###：" >&2
echo "$BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | \
$SAMTOOLS/samtools view -Sb - > SRR3226034.bam" >&2
time $BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | \
$SAMTOOLS/samtools view -Sb - > SRR3226034.bam && echo "*** bwa mapping done" && echo "" >&2

rm -f $INPUT_FILE_R1 $INPUT_FILE_R2

# 步骤二 排序
echo "###COMMAND LINE###：" >&2
echo "$SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226034.sorted.bam \
SRR3226034.bam -T PREFIX.bam" >&2
time $SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226034.sorted.bam \
SRR3226034.bam -T PREFIX.bam && echo "*** sort bam done" && echo "" >&2

rm -f SRR3226034.bam

# 步骤三 标记重复
echo "###COMMAND LINE###：" >&2
echo "$GATK MarkDuplicates -I SRR3226034.sorted.bam -O SRR3226034.sorted.markdup.bam \
-M SRR3226034.sorted.markup_metrics.txt" >&2
time $GATK MarkDuplicates -I SRR3226034.sorted.bam -O SRR3226034.sorted.markdup.bam \
-M SRR3226034.sorted.markup_metrics.txt && echo "*** 对BAM文件进行重复标记" && echo "" >&2

rm -f SRR3226034.sorted.bam

# 步骤四 创建比对索引文件
echo "###COMMAND LINE###：" >&2
echo "time $SAMTOOLS/samtools index SRR3226034.sorted.markdup.bam" >&2
time $SAMTOOLS/samtools index SRR3226034.sorted.markdup.bam && echo "*** 对BAM文件创建比对索引" && echo "" >&2

# 步骤五 变异检测 | 生成各个样本的中间变异检测文件gvcf
echo "###COMMAND LINE###：" >&2
echo "$GATK HaplotypeCaller -R $REF --emit-ref-confidence GVCF -I SRR3226034.sorted.markdup.bam \
-O SRR3226034.g.vcf" >&2
time $GATK HaplotypeCaller -R $REF --emit-ref-confidence GVCF -I SRR3226034.sorted.markdup.bam \
-O SRR3226034.g.vcf && echo "*** 生成样本SRR3226034的中间变异检测文件gvcf" && echo "" >&2

rm -f SRR3226034.sorted.markdup.bam* SRR3226034.sorted.markdup_metrics.txt

# 将各个样本分区的变异检测gvcf文件上传到HDFS上
echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -put -f SRR3226034.g.vcf /wgsv2/output/gvcf" >&2
$HADOOP/hadoop fs -put -f SRR3226034.g.vcf /wgsv2/output/gvcf && echo "*** 变异检测结果gvcf文件上传到HDFS上" && echo "">&2
echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############"
echo "--- 结束处理样本 SRR3226034 ---"