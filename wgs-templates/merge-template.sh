#!/bin/sh

# 该脚本需要完成的是对各个样本分区的VCGF文件做一个merge操作
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/3.6/GenomeAnalysisTK.jar
export HADOOP=~/hadoop/bin

# 从java参数中输入样本序号
SAMPLE1=${sample1}.g.vcf
SAMPLE2=${sample2}.g.vcf
SAMPLE3=${sample3}.g.vcf

cd /tmp

# 从HDFS上download所有的GVCF文件
$HADOOP hadoop fs -get /wgs/output/gvcf

# merge all gvcf files -- E_coli_K12.vcf
time java -jar $GATK -T GenotypeGVCFs -nt $THERAD -R $REF --variant $SAMPLE1 --variant $SAMPLE2 --variant $SAMPLE3 -o E_coli_K12.vcf && echo "** merge gvcf done **"

## 1.为vcf文件压缩
time bgzip -f E_coli_K12.vcf

## 2.构建tabix索引
time $SAMTOOLS/tabix -p vcf E_coli_K12.vcf.gz

## 3. 上传最终的VCF文件以及索引文件到HDFS上
$HADOOP/hadoop fs -put E_coli_K12.vcf.gz* /wgs/output/vcf
