rule all:
	input:
		["Analyses/iRep/Bt_1_1_4_S1_iRep.pdf", "Analyses/iRep/G6_1_1_4_S1_iRep.pdf"]

rule download_ref:
	output:
		"data/genomes/Bacteroides_thetaiotaomicron_VPI_5482_genomic.fna"
	shell:
		"""
		wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/011/065/GCF_000011065.1_ASM1106v1/GCF_000011065.1_ASM1106v1_genomic.fna.gz -O {output}.gz
		gunzip {output}.gz
		"""
		
rule download_reads:
	output:
		r1_R1="data/samples/1_1_4_S1_R1_001.fastq.gz",
		r1_R2="data/samples/1_1_4_S1_R2_001.fastq.gz"
	shell:
		"""
		wget https://www.dropbox.com/s/kjatx9b4jsj1w2y/1_1_4_S1_R1_001.fastq.gz?dl=1 -O {output.r1_R1}
		wget https://www.dropbox.com/s/211o0y426yzhekd/1_1_4_S1_R2_001.fastq.gz?dl=1 -O {output.r1_R2}
		"""
		
rule download_host:
	output:
		multiext("mm39/mm39", ".fa", ".fa.fai", ".fa.sizes", ".gaps.bed", ".annotation.gtf.gz", ".blacklist.bed")
	params:
		source="UCSC",
		dir="data/genomes",
		masking="hard"
	shell:
		"""
		genomepy install mm39 -p {params.source} -g {params.dir} -m {params.masking}
		"""
		
rule trimmomatic:
	input:
		r1_R1="data/samples/1_1_4_S1_R1_001.fastq.gz",
		r1_R2="data/samples/1_1_4_S1_R2_001.fastq.gz"
	output:
		r1="analyses/trimmed/1_1_4_S1_R1_001.trimmed.fastq.gz",
		r2="analyses/trimmed/1_1_4_S1_R2_001.trimmed.fastq.gz",
		r1_unpaired="analyses/trimmed/1_1_4_S1_R1_001.unpaired.fastq.gz",
		r2_unpaired="analyses/trimmed/1_1_4_S1_R2_001.unpaired.fastq.gz"
	log:
		"logs/trimmomatic/1_1_4_S1.log"
	shell:
		"""
		trimmomatic PE -phred33 {input.r1_R1} {input.r1_R2} {output.r1} {output.r1_unpaired} {output.r2} {output.r2_unpaired} ILLUMINACLIP:data/adapters/NexteraPE-PE.fa:2:3:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:35
		"""
		
rule host_decontam:
	input:
		ref="mm39/mm39.fa",
		r1="analyses/trimmed/1_1_4_S1_R1_001.trimmed.fastq.gz",
		r2="analyses/trimmed/1_1_4_S1_R2_001.trimmed.fastq.gz"
	output:
		outu1="analyses/trimmed/1_1_4_S1_R1_001.decon.fastq.gz",
		outu2="analyses/trimmed/1_1_4_S1_R2_001.decon.fastq.gz"
	shell:
		"""
		bbmap.sh ref={input.ref} in1={input.r1} in2={input.r2} outu1={output.outu1} outu2={output.outu2}
		"""
		
rule Bt_indexing:
	input:
		Bt="data/genomes/Bacteroides_thetaiotaomicron_VPI_5482_genomic.fna"
	output:
		multiext("B_theta",".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
	shell:
		"""
		bowtie2-build {input.Bt} {output}
		"""
	
rule G6_indexing:
	input:
		G6="data/genomes/Muribaculum_intestinale_G6_genomic.fna"
	output:
		multiext("M_intestinale",".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
	shell:
		"""
		bowtie2-build {input.G6} {output}
		"""
rule Bt_mapping:
	input:
		r1="analyses/trimmed/1_1_4_S1_R1_001.decon.fastq.gz",
		r2="analyses/trimmed/1_1_4_S1_R2_001.decon.fastq.gz"
	output:
		sam="Alignments/B_theta/Bt_1_1_4_S1_alignment.sam"
	shell:
		"""
		bowtie2 -D 20 -R 3 -N 0 -L 20 -i S,1,0.50 --reorder -x B_theta -1 {input.r1} -2 {input.r2} --no-unal -p 15 -S {output.sam}
		"""
		
rule G6_mapping:
	input:
		r1="analyses/trimmed/1_1_4_S1_R1_001.decon.fastq.gz",
		r2="analyses/trimmed/1_1_4_S1_R2_001.decon.fastq.gz"
	output:
		sam="Alignments/M_intestinale/G6_1_1_4_S1_alignment.sam"
	shell:
		"""
		bowtie2 -D 20 -R 3 -N 0 -L 20 -i S,1,0.50 --reorder -x M_intestinale -1 {input.r1} -2 {input.r2} --no-unal -p 15 -S {output.sam}
		"""
		
rule iRep_Bt:
	input:
		ref="data/genomes/Bacteroides_thetaiotaomicron_VPI_5482_genomic.fna",
		sam="Alignments/B_theta/Bt_1_1_4_S1_alignment.sam"
	output:
		multiext("Analyses/iRep/Bt_1_1_4_S1_iRep",".pdf", ".tsv")
	shell:
		"""
		iRep -ff -f {input.ref} -s {input.sam} -o {output}
		"""
		
rule iRep_G6:
	input:
		ref="data/genomes/Muribaculum_intestinale_G6_genomic.fna",
		sam="Alignments/M_intestinale/G6_1_1_4_S1_alignment.sam"
	output:
		multiext("Analyses/iRep/G6_1_1_4_S1_iRep",".pdf", ".tsv")
	shell:
		"""
		iRep -ff -f {input.ref} -s {input.sam} -o {output}
		"""
