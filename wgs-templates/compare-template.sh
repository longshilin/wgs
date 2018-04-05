#!/bin/sh

# 脚本所需的环境变量定义
export BWA=~/biosoft/bwa/0.7.12
export SAMTOOLS=~/biosoft/samtools/1.0/bin
export GATK=~/biosoft/gatk/3.6/GenomeAnalysisTK.jar
export HADOOP=~/hadoop/bin

# 定义参考序列
export REF=~/wgs/input/fasta/E.coli_K12_MG1655.fa

# 定义单个节点可利用的线程数
THREAD=4
# 定义单个节点可利用的内存资源
MEMORY=4G

# 定义RG INFO
INFO_RG='@RG\tID:foo\tPL:illumina\tSM:E.coli_K12'

# 定义模板变量
SAMPLE_FILE=${input_file}
INPUT_FILE_R1=${SAMPLE_FILE}_1.fastq.gz
INPUT_FILE_R2=${SAMPLE_FILE}_2.fastq.gz

cd /tmp
# 从HDFS上下载测序样本Block块
$HADOOP/hadoop fs -get /wgs/input/fastq/$INPUT_FILE_R1
$HADOOP/hadoop fs -get /wgs/input/fastq/$INPUT_FILE_R2

# ××××××  基因组测序 ×××××××
# 步骤一 比对
time $BWA/bwa mem -t $THREAD -R $INFO_RG $REF $INPUT_FILE_R1 $INPUT_FILE_R2 | $SAMTOOLS view -Sb - > ${SAMPLE_FILE}.bam && echo "** bwa mapping done **" > 1
# 步骤二 排序

time $SAMTOOLS sort -@ $THREAD -m $MEMORY -O bam -o ${SAMPLE_NAME}.sorted.bam ${SAMPLE_FILE}.bam -T PREFIX.bam && echo "** BAM sort done **"

# 步骤三 标记重复
time java -jar $GATK -T MarkDuplicates -I ${SAMPLE_FILE}.sorted.bam -O ${SAMPLE_FILE}.sorted.markup_metrics.txt && echo "** markup done **"

# 步骤四 创建比对索引文件
time $SAMTOOLS index ${SAMPLE_FILE}.sorted.markdup.bam && echo "** index done **"

# 步骤五 变异检测
# 步骤五(一) 生成各个样本的中间变异检测文件 GVCF
time java -jar $GATK HaplotyperCaller -R $REF --emit-ref-confidence GVCF -I ${SAMPLE_FILE}.g.vcf && echo "** ${SAMPLE_NAME} gvcf done **"

# 将各个样本分区的变异检测结果上传到HDFS上
$HADOOP/hadoop fs -put ${SAMPLE_NAME}.g.vcf /wgs/output/gvcf
