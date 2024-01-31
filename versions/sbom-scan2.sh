#!/bin/bash

# Default values
input_file=""
output_folder_json="sbom-json"
output_folder_txt="sbom-txt"

# Parse command-line parameters
while getopts "i:o:" opt; do
    case $opt in
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_folder_json="${OPTARG}-json"
            output_folder_txt="${OPTARG}-txt"
            ;;
        \?)
            echo "Usage: $0 -i <input-file> -o <output-folder>"
            exit 1
            ;;
    esac
done

# Check if the input file is provided
if [ -z "${input_file}" ]; then
    echo "Error: Input file not provided. Usage: $0 -i <input-file> -o <output-folder>"
    exit 1
fi

# Check if the input file exists
if [ ! -f "${input_file}" ]; then
    echo "Error: Input file '${input_file}' not found."
    exit 1
fi

# Create output folders
mkdir -p "${output_folder_json}"
mkdir -p "${output_folder_txt}"

# Perform SBOM scanning in JSON format
while IFS= read -r image; do
    image_name=$(echo "${image}" | sed 's/[^A-Za-z0-9._-]/_/g')
    docker sbom --format cyclonedx-json "${image}" > "${output_folder_json}/${image_name}-sbom.json"
done < "${input_file}"

# Perform SBOM scanning in TXT format
while IFS= read -r image; do
    image_name=$(echo "${image}" | sed 's/[^A-Za-z0-9._-]/_/g')
    docker sbom --format text "${image}" > "${output_folder_txt}/${image_name}-sbom.txt"
done < "${input_file}"

# Parse JSON files and create reports using Trivy
for json_file in "${output_folder_json}"/*.json; do
    trivy sbom -s HIGH,CRITICAL --ignore-status fixed "${json_file}"
done

echo "SBOM scanning completed. JSON files stored in: ${output_folder_json}"
echo "TXT files stored in: ${output_folder_txt}"
