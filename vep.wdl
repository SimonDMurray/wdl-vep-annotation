# VEP workflow

version 1.0

workflow VepWorkflow {
	call separateVCF
	call splitVCF {
	input:
		body_vcf=separateVCF.body_vcf
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
