#!/bin/bash

# Check if the input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

input_file="$1"

# Check if the input file exists
if [ ! -f "${input_file}" ]; then
    echo "Error: Input file '${input_file}' not found."
    exit 1
fi

# Create a timestamp for unique folder naming
timestamp=$(date +"%Y%m%d%H%M%S")
output_folder_json="sbom-json-${timestamp}"
output_folder_txt="sbom-txt-${timestamp}"

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
