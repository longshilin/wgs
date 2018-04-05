#!/bin/bash

# Author: elon
# Description: 一个合并GVCF文件的模板
# Time: 2018-4-5

# 该脚本需要完成的是对各个样本分区的VCGF文件做一个merge操作
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/3.6/GenomeAnalysisTK.jar
export HADOOP=~/hadoop/bin


# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa


# 定义模板变量
INPUT_FILE1=SRR3226042.g.vcf
INPUT_FILE2=SRR3226039.g.vcf
INPUT_FILE3=SRR3226035.g.vcf

cd /tmp

# 从HDFS上download所有的GVCF文件
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE1
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE2
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE3
echo "* * * * download all gvcf done * * * *"

# merge all gvcf files -- E_coli_K12.vcf
time java -jar $GATK -T GenotypeGVCFs -nt 4 -R $REF --variant $INPUT_FILE1 --variant $INPUT_FILE2 \
--variant $INPUT_FILE3 -o E_coli_K12.vcf && echo "** merge gvcf done **"

## 1.为vcf文件压缩
time bgzip -f E_coli_K12.vcf

## 2.构建tabix索引
time $SAMTOOLS/tabix -p vcf E_coli_K12.vcf.gz

## 3. 上传最终的VCF文件以及索引文件到HDFS上
$HADOOP/hadoop fs -put E_coli_K12.vcf.gz* /wgsv2/output/vcf \
&& echo "* * * * 变异检测结果vcf文件上传到HDFS上 * * * *"