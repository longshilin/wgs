#!/bin/bash

# Author: elon
# Description: 合并所有样本的GVCF文件的模板
# Time: 2018-4-5

# 该脚本需要完成的是对各个样本分区的VCGF文件做一个merge操作
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/3.6/GenomeAnalysisTK.jar
export HADOOP=~/hadoop/bin

# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa

echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############"
echo "--- 开始合并处理样本 SRR3226042 SRR3226041 SRR3226040 SRR3226039 SRR3226039 SRR3226038 SRR3226037 SRR3226036 SRR3226035 SRR3226034 ---"

# 定义模板变量
INPUT_FILE1=SRR3226042.g.vcf
INPUT_FILE2=SRR3226041.g.vcf
INPUT_FILE3=SRR3226040.g.vcf
INPUT_FILE4=SRR3226039.g.vcf
INPUT_FILE5=SRR3226038.g.vcf
INPUT_FILE6=SRR3226037.g.vcf
INPUT_FILE7=SRR3226036.g.vcf
INPUT_FILE8=SRR3226035.g.vcf
INPUT_FILE9=SRR3226034.g.vcf


cd /tmp

# 从HDFS上download所有的GVCF文件
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE1
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE2
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE3
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE4
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE5
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE6
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE7
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE8
$HADOOP/hadoop fs -get /wgsv2/output/gvcf/$INPUT_FILE9
echo "*** 从HDFS上获取所有相关的gVCF文件"

# 合并所有的gVCF文件为VCF文件 -- E_coli_K12.vcf
echo "###COMMAND LINE###：" >&2
echo "java -jar $GATK -T GenotypeGVCFs -nt 4 -R $REF --variant $INPUT_FILE1 --variant $INPUT_FILE2 \
--variant $INPUT_FILE3 --variant $INPUT_FILE4 --variant $INPUT_FILE5 --variant $INPUT_FILE6 \
--variant $INPUT_FILE7 --variant $INPUT_FILE8 --variant $INPUT_FILE9 \
-o E_coli_K12.vcf" >&2

time java -jar $GATK -T GenotypeGVCFs -nt 4 -R $REF --variant $INPUT_FILE1 --variant $INPUT_FILE2 \
--variant $INPUT_FILE3 --variant $INPUT_FILE4 --variant $INPUT_FILE5 --variant $INPUT_FILE6 \
--variant $INPUT_FILE7 --variant $INPUT_FILE8 --variant $INPUT_FILE9 \
-o E_coli_K12.vcf 1>&2 && echo "*** 合并所有的gVCF文件为VCF文件" && echo "">&2

## 1.将vcf文件压缩
echo "###COMMAND LINE###：" >&2
echo "bgzip -f E_coli_K12.vcf" >&2

time bgzip -f E_coli_K12.vcf && echo "*** 将vcf文件进行压缩" && echo "">&2

## 2.构建tabix索引
echo "###COMMAND LINE###：" >&2
echo "$SAMTOOLS/tabix -p vcf E_coli_K12.vcf.gz" >&2
time $SAMTOOLS/tabix -p vcf E_coli_K12.vcf.gz \
&& echo "*** 给压缩文件构建tabix索引" && echo "">&2


## 3. 上传最终的VCF文件以及索引文件到HDFS上
echo "###COMMAND LINE###：" >&2
echo "$HADOOP/hadoop fs -f -put E_coli_K12.vcf.gz* /wgsv2/output/vcf" >&2

time $HADOOP/hadoop fs -put -f E_coli_K12.vcf.gz* /wgsv2/output/vcf && echo "*** 变异检测结果vcf文件上传到HDFS上" && echo "">&2

#rm -f E_coli_K12.vcf* *g.vcf*

echo "--- 结束处理样本  ---"
echo "############" `date "+%Y-%m-%d %H:%M:%S"` "############" && echo ""