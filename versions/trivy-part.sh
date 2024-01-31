#!/bin/bash

# Default values
input_folder="mbank4-output"

# Parse command-line parameters
while getopts "i:" opt; do
    case $opt in
        i)
            input_folder="$OPTARG"
            ;;
        \?)
            echo "Usage: $0 -i <input-folder>"
            exit 1
            ;;
    esac
done

# Check if the input folder is provided
if [ -z "${input_folder}" ]; then
    echo "Error: Input folder not provided. Usage: $0 -i <input-folder>"
    exit 1
fi

# Check if the input folder exists
if [ ! -d "${input_folder}" ]; then
    echo "Error: Input folder '${input_folder}' not found."
    exit 1
fi

# Perform Trivy scanning on JSON files
for json_file in "${input_folder}"/*.json; do
    if [ -e "${json_file}" ]; then
        report_file="${json_file%.json}-trivy-report.txt"
        trivy sbom -s HIGH,CRITICAL --ignore-status fixed "${json_file}" > "${report_file}"
    fi
done

echo "Trivy scanning completed for JSON files in: ${input_folder}"
