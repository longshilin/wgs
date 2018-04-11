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
INFO_RG='@RG\tID:SRR3226038\tPL:illumina\tSM:E.coli_K12_SRR3226038'

echo "* * * * 开始处理样本 SRR3226038 * * * *"

# 定义模板变量
INPUT_FILE_R1=SRR3226038_1.fastq.gz
INPUT_FILE_R2=SRR3226038_2.fastq.gz

cd /tmp
# 从HDFS上下载测序样本Block块
$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1
$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2
echo "* * * * download sample file from HDFS..."

# ××××××  基因测序 ×××××××
# 步骤一 比对
time $BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | \
$SAMTOOLS/samtools view -Sb - > SRR3226038.bam && echo "* * * * bwa mapping done..."

# 步骤二 排序
time $SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226038.sorted.bam \
SRR3226038.bam -T PREFIX.bam && echo "* * * * sort bam done..."

rm -f SRR3226038.bam

# 步骤三 标记重复
time $GATK MarkDuplicates -I SRR3226038.sorted.bam -O SRR3226038.sorted.markdup.bam \
-M SRR3226038.sorted.markup_metrics.txt && echo "* * * * MarkDuplicates bam done..."

rm -f SRR3226038.sorted.bam

# 步骤四 创建比对索引文件
time $SAMTOOLS/samtools index SRR3226038.sorted.markdup.bam \
&& echo "* * * * index bam done..."

# 步骤五 变异检测 | 生成各个样本的中间变异检测文件gvcf
time $GATK HaplotypeCaller -R $REF --emit-ref-confidence GVCF -I SRR3226038.sorted.markdup.bam \
-O SRR3226038.g.vcf && echo "* * * * Generate gvcf done..."

rm -f SRR3226038.sorted.markdup.bam* SRR3226038.sorted.markdup_metrics.txt

# 将各个样本分区的变异检测gvcf文件上传到HDFS上
$HADOOP/hadoop fs -put SRR3226038.g.vcf /wgsv2/output/gvcf \
&& echo "* * * * 变异检测结果gvcf文件上传到HDFS上..."
echo ""