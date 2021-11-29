rule all:
	input:
		["analyses/iRep/Bt_1_1_4_S1_iRep.tsv", "analyses/iRep/G6_1_1_4_S1_iRep.tsv"]

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
		multiext("mm39/mm39", ".fa", ".fa.fai", ".fa.sizes", ".gaps.bed")
	params:
		source="UCSC",
		masking="hard",
		dir="./"
	conda:
		"envs/genomepy.yml"
	shell:
		"""
		genomepy plugin disable blacklist bowtie2 bwa gmap hisat2 minimap2 star
		genomepy install mm39 -p {params.source} -m {params.masking} -g {params.dir}
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
	conda:
		"envs/trimmomatic.yml"
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
		outu1="analyses/decontaminated/1_1_4_S1_R1_001.decon.fastq.gz",
		outu2="analyses/decontaminated/1_1_4_S1_R2_001.decon.fastq.gz"
	conda:
		"envs/bbmap.yml"
	shell:
		"""
		bbmap.sh ref={input.ref} in1={input.r1} in2={input.r2} outu1={output.outu1} outu2={output.outu2} -Xmx10g
		"""
		
rule Bt_indexing:
    input:
        reference="data/genomes/Bacteroides_thetaiotaomicron_VPI_5482_genomic.fna"
    output:
        multiext("BTheta", ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
    log:
        "logs/bowtie2_build/build_Bt.log"
    params:
        extra=""  # optional parameters
    threads: 8
	conda:
		"envs/indexing_mapping.yml"
    wrapper:
        "v0.80.1/bio/bowtie2/build"

rule G6_indexing:
    input:
        reference="data/genomes/Muribaculum_intestinale_G6_genomic.fna"
    output:
        multiext("MIntestinale",".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
    log:
        "logs/bowtie2_build/build_G6.log"
    params:
        extra=""  # optional parameters
    threads: 8
	conda:
		"envs/indexing_mapping.yml"
    wrapper:
        "v0.80.1/bio/bowtie2/build"
		
rule Bt_mapping:
	input:
		r1="analyses/decontaminated/1_1_4_S1_R1_001.decon.fastq.gz",
		r2="analyses/decontaminated/1_1_4_S1_R2_001.decon.fastq.gz",
		idxdone=multiext("BTheta", ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
	output:
		sam="analyses/alignments/B_theta/Bt_1_1_4_S1_alignment.sam"
	params:
		idx="BTheta"
	conda:
		"envs/indexing_mapping.yml"
	shell:
		"""
		bowtie2 -D 20 -R 3 -N 0 -L 20 -i S,1,0.50 --reorder -x {params.idx} -1 {input.r1} -2 {input.r2} --no-unal -p 15 -S {output.sam}
		"""
		
rule G6_mapping:
	input:
		r1="analyses/decontaminated/1_1_4_S1_R1_001.decon.fastq.gz",
		r2="analyses/decontaminated/1_1_4_S1_R2_001.decon.fastq.gz",
		idxdone=multiext("MIntestinale", ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
	output:
		sam="analyses/alignments/M_intestinale/G6_1_1_4_S1_alignment.sam"
	params:
		idx="MIntestinale"
	conda:
		"envs/indexing_mapping.yml"
	shell:
		"""
		bowtie2 -D 20 -R 3 -N 0 -L 20 -i S,1,0.50 --reorder -x {params.idx} -1 {input.r1} -2 {input.r2} --no-unal -p 15 -S {output.sam}
		"""
		
rule iRep_Bt:
	input:
		ref="data/genomes/Bacteroides_thetaiotaomicron_VPI_5482_genomic.fna",
		sam="analyses/alignments/B_theta/Bt_1_1_4_S1_alignment.sam"
	output:
		multiext("analyses/iRep/Bt_1_1_4_S1_iRep",".tsv", ".pdf")
	conda:
		"envs/irep.yml"
	shell:
		"""
		iRep -ff -f {input.ref} -s {input.sam} -o analyses/iRep/Bt_1_1_4_S1_iRep
		"""
		
rule iRep_G6:
	input:
		ref="data/genomes/Muribaculum_intestinale_G6_genomic.fna",
		sam="analyses/alignments/M_intestinale/G6_1_1_4_S1_alignment.sam"
	output:
		multiext("analyses/iRep/G6_1_1_4_S1_iRep",".tsv", ".pdf")
	conda:
		"envs/irep.yml"
	shell:
		"""
		iRep -ff -f {input.ref} -s {input.sam} -o analyses/iRep/G6_1_1_4_S1_iRep
		"""