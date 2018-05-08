# 记录input数据

# split files from .sra to .fastq
elon@longsl:~/wgs/input/fastq$ ~/biosoft/sratoolkit/2.9.0/bin/fastq-dump --split-files SRR3226035.sra && ~/biosoft/sratoolkit/2.9.0/bin/fastq-dump --split-files SRR3226039.sra && ~/biosoft/sratoolkit/2.9.0/bin/fastq-dump --split-files SRR3226042.sra && echo "** fastq-dump split files done **"

# 将.fastq文件都转换为gz压缩文件，节约空间
elon@longsl:~/wgs/input/fastq$ bgzip -f SRR3226035_1.fastq && bgzip -f SRR3226035_2.fastq && bgzip -f SRR3226039_1.fastq && bgzip -f SRR3226039_2.fastq && bgzip -f SRR3226042_1.fastq && bgzip  -f SRR3226042_2.fastq
