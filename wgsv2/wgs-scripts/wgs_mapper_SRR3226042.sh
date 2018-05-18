#!/bin/bash

# Author: elon
# Description: 对于一个比对程序脚本的模板
# Time: 2018-4-5

# 脚本所需的环境变量定义
export BWA=~/biosoft/bwa/0.7.12
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/3.6/GenomeAnalysisTK.jar
export PICARD=~/biosoft/picard/2.18.2/picard.jar
export HADOOP=~/hadoop/bin

# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa

# 定义单个节点可利用的线程数
THREAD=4
# 定义单个节点可利用的内存资源
MEMORY=4G

# 定义RG INFO
INFO_RG='@RG\tID:SRR3226042\tPL:illumina\tSM:E.coli_K12_SRR3226042'

echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############"
echo "--- 开始处理样本 SRR3226042 ---"

# 定义模板变量
INPUT_FILE_R1=SRR3226042_1.fastq.gz
INPUT_FILE_R2=SRR3226042_2.fastq.gz

cd /tmp
# 从HDFS上下载测序样本Block块
echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1" >&2

time $HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1 && echo "" >&2

echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2" >&2

time $HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2
echo "*** 从HDFS上下载样本数据块" && echo "" >&2

# ××××××  基因测序 ×××××××
# 步骤一 比对
echo "###COMMAND LINE###：" >&2
echo "$BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | $SAMTOOLS/samtools view -Sb - > SRR3226042.bam" >&2

time $BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | $SAMTOOLS/samtools view -Sb - > SRR3226042.bam && echo "*** 基因比对操作完成" && echo "" >&2

# 步骤二 排序
echo "###COMMAND LINE###：" >&2
echo "$SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226042.sorted.bam SRR3226042.bam -T PREFIX.bam" >&2

time $SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226042.sorted.bam SRR3226042.bam -T PREFIX.bam && echo "*** 基因数据排序完成" && echo "" >&2

#rm -f SRR3226042.bam

# 步骤三 标记重复
echo "###COMMAND LINE###：" >&2
echo "java -jar $PICARD MarkDuplicates I=SRR3226042.sorted.bam O=SRR3226042.sorted.markdup.bam M=SRR3226042.sorted.markdup_metrics.txt" >&2

time java -jar $PICARD MarkDuplicates I=SRR3226042.sorted.bam O=SRR3226042.sorted.markdup.bam M=SRR3226042.sorted.markdup_metrics.txt 1>&2 && echo "*** 对BAM文件进行重复标记" && echo "" >&2

# 步骤四 创建比对索引文件
echo "###COMMAND LINE###：" >&2
echo "time $SAMTOOLS/samtools index SRR3226042.sorted.markdup.bam" >&2

time $SAMTOOLS/samtools index SRR3226042.sorted.markdup.bam && echo "*** 对BAM文件创建比对索引" && echo "" >&2

# 步骤五 变异检测 | 生成各个样本的中间变异检测文件gvcf
echo "###COMMAND LINE###：" >&2
echo "java -jar $GATK -T HaplotypeCaller -R $REF --emitRefConfidence GVCF -I SRR3226042.sorted.markdup.bam -o SRR3226042.g.vcf" >&2

time java -jar $GATK -T HaplotypeCaller -R $REF --emitRefConfidence GVCF -I SRR3226042.sorted.markdup.bam -o SRR3226042.g.vcf 1>&2 && echo "*** 生成样本SRR3226042的中间变异检测文件gvcf" && echo "" >&2

# 将各个样本分区的变异检测gvcf文件上传到HDFS上
echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -put -f SRR3226042.g.vcf /wgsv2/output/gvcf" >&2

time $HADOOP/hadoop fs -put -f SRR3226042.g.vcf /wgsv2/output/gvcf && echo "*** 变异检测结果gvcf文件上传到HDFS上" && echo "">&2

rm -f rm -f $INPUT_FILE_R1 $INPUT_FILE_R2 SRR3226042*

echo "--- 结束处理样本 SRR3226042 ---"
echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############" && echo ""