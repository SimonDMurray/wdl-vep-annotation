# VEP workflow

version 1.0

workflow VepWorkflow {
	call separateVCF
	call splitVCF {
	input:
		body_vcf=separateVCF.body_vcf
	}
	scatter (oneVCF in splitVCF.file_paths) {
		call CCDSFilter {input: oneVCF=oneVCF}
		call CSN {input:input_vcf=CCDSFilter.CCDS_vcf}
		call Carol {input:input_vcf=CSN.CSN_vcf}
		call Downstream {input:input_vcf=Carol.Carol_vcf}
		call Draw {input:input_vcf=Downstream.Downstream_vcf}
		call GXA {input:input_vcf=Draw.Draw_vcf}
		call LOVD {input:input_vcf=GXA.GXA_vcf}
		call NMD {input:input_vcf=LOVD.LOVD_vcf}
		call NearestGene {input:input_vcf=NMD.NMD_vcf}
		call AncestralAllele {input:input_vcf=NearestGene.NearestGene_vcf}
	}
	call recombineVCF{input:input_vcfs=AncestralAllele.AncestralAllele_vcf,header_vcf=separateVCF.header_vcf,grep_vcf=AncestralAllele.AncestralAllele_vcf[0]}
	output {
		File final_vcf = recombineVCF.final_vcf
	}	
}

task separateVCF {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	zcat < '~{input_vcf}' | grep -e "^#" > header.vcf
	zcat < '~{input_vcf}' | grep -v -e "^#" > body.vcf
	>>>
	output {
		File header_vcf = 'header.vcf'
		File body_vcf = 'body.vcf'
	}
}

task splitVCF {
	input {
		File body_vcf
	}
	command <<<
	set -euo pipefail
	split -l 1 '~{body_vcf}' 
	readlink -f x* > file_list.txt	
	>>>
	output {
		Array[String] file_paths = read_lines("file_list.txt")
	}
}

task CCDSFilter {
	input {
		File oneVCF
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{oneVCF}' --output_file "CCDS.vcf" -plugin CCDSFilter
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File CCDS_vcf = 'CCDS.vcf'
	}
}

task CSN {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "CSN.vcf" -plugin CSN
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File CSN_vcf = 'CSN.vcf'
	}
}

task Carol {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "Carol.vcf" -plugin Carol
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File Carol_vcf = 'Carol.vcf'
	}
}

task Downstream {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "Downstream.vcf" -plugin Downstream
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File Downstream_vcf = 'Downstream.vcf'
	}
}

task Draw {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "Draw.vcf" -plugin Draw
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File Draw_vcf = 'Draw.vcf'
	}
}

task GXA {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "GXA.vcf" -plugin GXA
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File GXA_vcf = 'GXA.vcf'
	}
}

task LOVD {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "LOVD.vcf" -plugin LOVD
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File LOVD_vcf = 'LOVD.vcf'
	}
}

task NMD {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "NMD.vcf" -plugin NMD
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File NMD_vcf = 'NMD.vcf'
	}
}

task NearestGene {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "NearestGene.vcf" -plugin NearestGene
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File NearestGene_vcf = 'NearestGene.vcf'
	}
}

task AncestralAllele {
	input {
		File input_vcf
	}
	command <<<
	set -euo pipefail
	vep --cache --offline --format vcf --vcf --force_overwrite --input_file '~{input_vcf}' --output_file "AncestralAllele.vcf" -plugin AncestralAllele,homo_sapiens_ancestor_GRCh38.fa.gz	
	>>>
	runtime {
		docker: "test:v0.1"
	}
	output {
		File AncestralAllele_vcf = 'AncestralAllele.vcf'
	}
}

task recombineVCF {
	input {
		Array[File] input_vcfs
		File header_vcf
		File grep_vcf
	}
	command <<<
	set -euo pipefail
	grep -e "^##" '~{header_vcf}' > final.vcf
	grep -e "^##INFO=<ID=CSQ" '~{grep_vcf}' | uniq | cut -f 2 -d : | uniq >> final.vcf
	grep -e "^##CAROL" '~{grep_vcf}' | uniq | cut -f 2 -d : | uniq >> final.vcf
	grep -e "^##LOVD" '~{grep_vcf}' | uniq | cut -f 2 -d : | uniq >> final.vcf
	grep -e "^##NMD" '~{grep_vcf}' | uniq | cut -f 2 -d : | uniq >> final.vcf
	grep -e "^##NearestGene" '~{grep_vcf}' | uniq | cut -f 2 -d : | uniq >> final.vcf
	grep -e "^#CHROM" '~{header_vcf}' >> final.vcf
	for vcf_file in '~{sep=" " input_vcfs}'; do tail -n 1 $vcf_file | grep -v "==>" | grep -e "^." >> final.vcf; done
	gzip final.vcf
	>>>
	output {
		File final_vcf = 'final.vcf.gz'
	}
}
