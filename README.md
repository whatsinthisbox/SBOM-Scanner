# SBOM-Scanner

Below scripts utilize standalone Docker SBOM and Trivy commands. Make sure both are installed on the system.


sbom-scan.sh - scans a list of docker images and saves a list of software used in these images in TXT and JSON (software bill of materials = software list used to build the image)

trivy-scan.sh scans the JSON files for HIGH and CRITICAL vulnerabilities, omits vulns marked with "Fixed" status.



Usage:

./sbom-scan.sh -i /root/docker_image_list.txt -o some_folder

./trivy-scan.sh -i some_folder

#ubuntu #docker #vulnerability #secops #devsecops
