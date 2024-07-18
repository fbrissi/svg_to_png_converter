#!/bin/bash

rm -rf ./convert/*.png

rm -rf ./download/*.svg
rm -rf ./download/*.png
rm -rf ./download/*.jpg
rm -rf ./download/*.jpeg
rm -rf ./download/*.gif

echo "" > ./uri_base.txt
echo "" > ./uri_converted.txt
echo "" > ./uri_dlownloaded.txt

while IFS= read -r url; do
	filename=$(echo "$url" | sed 's/[^a-zA-Z0-9.-]/_/g')
	filename_base="${filename%.*}"

	echo "${filename_base}" >> ./uri_base.txt
	
	curl --compressed --connect-timeout 5 -m 20 --http1.1 -s -v -L -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -o "./download/${filename}" "$url"
	
	if [ $? -eq 0 ]; then
		echo "${filename_base}" >> ./uri_dlownloaded.txt

		inkscape "./download/${filename}" --export-type=png --export-area-page --export-width=800 --export-filename="./convert/${filename_base}.png"

		if [ -f "./convert/${filename_base}.png" ]; then
			echo "${filename_base}" >> ./uri_converted.txt
		fi
	fi
done < ./uri.txt

echo "########### Arquivos que não baixaram"
diff ./uri_base.txt ./uri_dlownloaded.txt | grep "^<" | sed 's/^< //'

echo ""

echo "########### Arquivos que não converteram"
diff ./uri_base.txt ./uri_converted.txt | grep "^<" | sed 's/^< //'
