# 1.比对
cd ~/wgs/input/fastq/

time ~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:foo\tPL:illumina\tSM:E.coli_K12' ../fasta/E.coli_K12_MG1655.fa SRR3226035_1.fastq.gz SRR3226035_2.fastq.gz | ~/biosoft/samtools/1.0/bin/samtools view -Sb - > ~/wgs/output/SRR3226035.bam && echo "** bwa mapping done **"

time ~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:foo\tPL:illumina\tSM:E.coli_K12' ../fasta/E.coli_K12_MG1655.fa SRR3226039_1.fastq.gz SRR3226039_2.fastq.gz | ~/biosoft/samtools/1.0/bin/samtools view -Sb - > ~/wgs/output/SRR3226039.bam && echo "** bwa mapping done **"

time ~/biosoft/bwa/0.7.12/bwa mem -t 4 -R '@RG\tID:foo\tPL:illumina\tSM:E.coli_K12' ../fasta/E.coli_K12_MG1655.fa SRR3226042_1.fastq.gz SRR3226042_2.fastq.gz | ~/biosoft/samtools/1.0/bin/samtools view -Sb - > ~/wgs/output/SRR3226042.bam && echo "** bwa mapping done **"

# 2.排序
cd /home/elon/wgs/input/fastq

time ~/biosoft/samtools/1.0/bin/samtools sort -@ 4 -m 1G -O bam -o ~/wgs/output/SRR3226035.sorted.bam ~/wgs/output/SRR3226035.bam -T PREFIX.bam && echo "** BAM sort done **"

time ~/biosoft/samtools/1.0/bin/samtools sort -@ 4 -m 1G -O bam -o ~/wgs/output/SRR3226039.sorted.bam ~/wgs/output/SRR3226039.bam -T PREFIX.bam && echo "** BAM sort done **"

time ~/biosoft/samtools/1.0/bin/samtools sort -@ 4 -m 1G -O bam -o ~/wgs/output/SRR3226042.sorted.bam ~/wgs/output/SRR3226042.bam -T PREFIX.bam && echo "** BAM sort done **"


rm -f ~/wgs/output/SRR3226035.bam ~/wgs/output/SRR3226039.bam ~/wgs/output/SRR3226042.bam

# 3.标记PCR重复
time ~/biosoft/gatk/4.0/gatk MarkDuplicates -I ~/wgs/output/SRR3226035.sorted.bam -O ~/wgs/output/SRR3226035.sorted.markdup.bam -M ~/wgs/output/SRR3226035.sorted.markup_metrics.txt && echo "** markup done **"

time ~/biosoft/gatk/4.0/gatk MarkDuplicates -I ~/wgs/output/SRR3226039.sorted.bam -O ~/wgs/output/SRR3226039.sorted.markdup.bam -M ~/wgs/output/SRR3226039.sorted.markup_metrics.txt && echo "** markup done **"

time ~/biosoft/gatk/4.0/gatk MarkDuplicates -I ~/wgs/output/SRR3226042.sorted.bam -O ~/wgs/output/SRR3226042.sorted.markdup.bam -M ~/wgs/output/SRR3226042.sorted.markup_metrics.txt && echo "** markup done **"


rm -f ~/wgs/output/SRR3226035.sorted.bam ~/wgs/output/SRR3226039.sorted.bam ~/wgs/output/SRR3226042.sorted.bam

# 4.创建比对索引文件
time ~/biosoft/samtools/1.0/bin/samtools index ~/wgs/output/SRR3226035.sorted.markdup.bam && echo "** index done **"

time ~/biosoft/samtools/1.0/bin/samtools index ~/wgs/output/SRR3226039.sorted.markdup.bam && echo "** index done **"

time ~/biosoft/samtools/1.0/bin/samtools index ~/wgs/output/SRR3226042.sorted.markdup.bam && echo "** index done **"

# 5.变异检测
## 5.0 先为K12 参考序列生成一个.dict文件
time ~/biosoft/gatk/4.0/gatk CreateSequenceDictionary -R ~/wgs/input/fasta/E.coli_K12_MG1655.fa -O ~/wgs/input/fasta/E.coli_K12_MG1655.dict && echo "** dict done **"

## 5.1 生成各个样本的中间变异检测文件gvcf
time ~/biosoft/gatk/4.0/gatk HaplotypeCaller -R ~/wgs/input/fasta/E.coli_K12_MG1655.fa --emit-ref-confidence GVCF -I ~/wgs/output/SRR3226035.sorted.markdup.bam -O ~/wgs/output/SRR3226035.g.vcf && echo "** gvcf done **"

time ~/biosoft/gatk/4.0/gatk HaplotypeCaller -R ~/wgs/input/fasta/E.coli_K12_MG1655.fa --emit-ref-confidence GVCF -I ~/wgs/output/SRR3226039.sorted.markdup.bam -O ~/wgs/output/SRR3226039.g.vcf && echo "** gvcf done **"

time ~/biosoft/gatk/4.0/gatk HaplotypeCaller -R ~/wgs/input/fasta/E.coli_K12_MG1655.fa --emit-ref-confidence GVCF -I ~/wgs/output/SRR3226042.sorted.markdup.bam -O ~/wgs/output/SRR3226042.g.vcf && echo "** gvcf done **"

## 5.2 合并中间编译检测文件gvcf为一个整体vcf文件(使用GATK3.6 由于GATK4.0不支持多个--variant的gvcf文件的merge操作)
time java -jar ~/biosoft/gatk/3.6/GenomeAnalysisTK.jar -T GenotypeGVCFs -nt 4 -R ~/wgs/input/fasta/E.coli_K12_MG1655.fa --variant ~/wgs/output/SRR3226035.g.vcf --variant ~/wgs/output/SRR3226039.g.vcf --variant ~/wgs/output/SRR3226042.g.vcf -o ~/wgs/output/E_coli_K12.vcf && echo "** merge gvcf done **"

# 6.已获得来E.coli K12 这个样本的编译检测的结果 -- E_coli_K12.vcf
## 6.1 为vcf文件压缩
time bgzip -f ~/wgs/output/E_coli_K12.vcf

## 6.2 构建tabix索引
time ~/biosoft/samtools/1.0/bin/tabix -p vcf ~/wgs/output/E_coli_K12.vcf.gz


