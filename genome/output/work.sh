#!/bin/bash

cd /home/elon/genome/input/fastq

time ~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:SRR799555\tPL:illumina\tSM:SRR799555' ../fasta/hg19.fa SRR799555_1.fastq.gz SRR799555_2.fastq.gz | ~/biosoft/samtools/1.0/bin/samtools view -S -b - > ../../output/SRR799555.bam && echo "** 序列比对完成 **"

cd /home/elon/genome/output

time samtools sort -@ 4 -O bam -o SRR799555.sorted.bam SRR799555.bam -T PREFIX.bam && echo "** Bam 排序完成 **"

rm -rf SRR799555.bam

time java -jar ~/biosoft/picard/2.18.2/picard.jar MarkDuplicates \
I=SRR799555.sorted.bam \
O=SRR799555.sorted.markup.bam \
M=SRR799555.markup_metrics.txt && echo "** 重复比对完成 **"

~/biosoft/samtools/1.0/bin/samtools index SRR799555.sorted.markdup.bam && echo "index done"
