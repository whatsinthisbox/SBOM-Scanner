#!/bin/bash

# Default values
input_file=""
output_folder="SBOM-outputs"

# Parse command-line parameters
while getopts "i:o:" opt; do
    case $opt in
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_folder="${OPTARG}-output"
            ;;
        \?)
            echo "Usage: $0 -i <input-file> -o <output-folder>"
            exit 1
            ;;
    esac
done

# Check if the input file is provided
if [ -z "${input_file}" ]; then
    echo -e "SBOM-Scanner v0.1 - by Lukasz Racinowski - creates Docker SBOM (software list of image in txt and json formats)\n"
    echo -e "Parse it with Trivy to scan for docker image vulns \n" 
    echo -e " "
    echo "Error: Input file not provided. Usage: $0 -i <input-file> -o <output-folder>"
    exit 1
fi

# Check if the input file exists
if [ ! -f "${input_file}" ]; then
    echo "Error: Input file '${input_file}' not found."
    exit 1
fi

# Create output folder
mkdir -p "${output_folder}"

# Perform SBOM scanning in CycloneDX JSON and TXT formats
while read -r image; do
    image_name=$(echo "${image}" | sed 's/[^A-Za-z0-9._-]/_/g')

    # CycloneDX JSON format
    docker sbom --format cyclonedx-json "${image}" > "${output_folder}/${image_name}-sbom.json"

    # TXT format
    docker sbom --format text "${image}" > "${output_folder}/${image_name}-sbom.txt"
done < "${input_file}" > "${output_folder}/sbom-scan.log" 2>&1

echo "SBOM scanning completed. Files stored in: ${output_folder}"
