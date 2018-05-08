#!/bin/bash

# Author: elon
# Description: 对于一个比对程序脚本的模板
# Time: 2018-4-5
# 脚本所需的环境变量定义

export BWA=/home/elon/biosoft/bwa/0.7.12
export SAMTOOLS=/home/elon/biosoft/samtools/1.0/bin
export PICARD=/home/elon/biosoft/picard/2.18.2/picard.jar
export GATK=/home/elon/biosoft/gatk/4.0/gatk
export HADOOP=/home/elon/hadoop/bin

# 定义参考序列
export REF=/home/elon/wgs/input/fasta/E.coli_K12_MG1655.fa

# 定义单个节点可利用的线程数
THREAD=3
# 定义单个节点可利用的内存资源
MEMORY=1G

# 定义RG INFO
INFO_RG='@RG\tID:foo\tPL:illumina\tSM:E.coli_K12'

echo "* * * * 开始处理样本 SRR3226035 * * * *">&2

# 定义模板变量
time INPUT_FILE_R1=SRR3226035_1.fastq.gz
time INPUT_FILE_R2=SRR3226035_2.fastq.gz

cd /tmp
# 从HDFS上下载测序样本Block块
$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R1
$HADOOP/hadoop fs -get /wgsv2/input/fastq/$INPUT_FILE_R2
echo "* * * * download sample file from HDFS..."

# ××××××  基因测序 ×××××××
# 步骤一 比对
time $BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 |$SAMTOOLS/samtools view -Sb - > SRR3226035.bam && echo "* * * * bwa mapping done...">&2

# 步骤二 排序
time $SAMTOOLS/samtools sort -@ $THREAD -m $MEMORY -O bam -o SRR3226035.sorted.bam SRR3226035.bam -T PREFIX.bam && echo "* * * * sort bam done...">&2

#rm -f SRR3226035.bam

# 步骤三 标记重复
time $GATK MarkDuplicates -I SRR3226035.sorted.bam -O SRR3226035.sorted.markdup.bam -M SRR3226035.sorted.markup_metrics.txt && echo "* * * * MarkDuplicates bam done...">&2

#java -jar $PICARD MarkDuplicates I=SRR3226035.sorted.bam O=SRR3226035.sorted.markdup.bam M=SRR3226035.sorted.markup_metrics.txt


#rm -f SRR3226035.sorted.bam

# 步骤四 创建比对索引文件
time $SAMTOOLS/samtools index SRR3226035.sorted.markdup.bam && echo "* * * * index bam done...">&2

# 步骤五 变异检测 | 生成各个样本的中间变异检测文件gvcf
time $GATK HaplotypeCaller -R $REF --emit-ref-confidence GVCF -I SRR3226035.sorted.markdup.bam -O SRR3226035.g.vcf && echo "* * * * Generate gvcf done...">&2

#rm -f SRR3226035.sorted.markdup.bam* SRR3226035.sorted.markdup_metrics.txt

# 将各个样本分区的变异检测gvcf文件上传到HDFS上
time $HADOOP/hadoop fs -put SRR3226035.g.vcf /wgsv2/output/gvcf && echo "* * * * 变异检测结果gvcf文件上传到HDFS上...">&2
echo ""
