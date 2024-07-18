#!/bin/bash

echo "" > ./extracted_fields.txt

curl -s "https://data.directory.openbankingbrasil.org.br/participants" | jq '.[].AuthorisationServers[] | [.AuthorisationServerId, .CustomerFriendlyLogoUri] | @csv' > ./extracted_fields.txt
sed -i 's/\\"//g' ./extracted_fields.txt
sed -i 's/\"//g' ./extracted_fields.txt

echo "Os campos foram extraídos para extracted_fields.json"