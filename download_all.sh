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

while IFS=, read -r file_name url; do
	filename="logo-detentora-${file_name}"

	echo "${filename}" >> ./uri_base.txt
	
	curl --compressed --connect-timeout 5 -m 20 --http1.1 -s -v -L -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-User: ?1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' -o "./download/${filename}.svg" "$url"

	 if [ $? -ne 0 ]; then
      continue
   fi

	echo "${filename}" >> ./uri_dlownloaded.txt

  original_image="./download/${filename}.svg"
  converted_image="./convert/${filename}.png"

  if ! grep -q '<svg[^>]*' "$original_image"; then
   continue
  fi

  sed -i ':a;N;$!ba;s/\n/ /g' "$original_image"
  sed -i 's/ viewBox="[^"]*"//' "$original_image"
  sed -i '/<svg[^>]*>/s//&<g id="g-root">/' "$original_image"
  sed -i 's/<\/svg>/<\/g>&/' "$original_image"

  centerX=0
  centerY=0
  group_info=$(inkscape "$original_image" --query-all | grep "g-root,")
  width=$(echo $group_info | awk -F, '{print $4}')
  height=$(echo $group_info | awk -F, '{print $5}')
  maxSize=$(echo "$width $height" | awk '{if ($1 > $2) print $1; else print $2}')

  echo "Width: $width, Height: $height, MaxSize: $maxSize, CenterX: $centerX, CenterY: $centerY, group_info: $group_info"

  if ! grep -q '<svg[^>]* width="' "$original_image"; then
    sed -i -E "s/<svg/<svg width=\"$maxSize\"/" "$original_image"
  else
    sed -i -E "s/(<svg[^>]* width=\")[^\"]+(\")/\1$maxSize\2/" "$original_image"
  fi
  if ! grep -q '<svg[^>]* height="' "$original_image"; then
    sed -i -E "s/<svg/<svg height=\"$maxSize\"/" "$original_image"
  else
    sed -i -E "s/(<svg[^>]* height=\")[^\"]+(\")/\1$maxSize\2/" "$original_image"
  fi

  inkscape "$original_image" --batch-process --actions="select-by-id:g-root;object-align:hcenter vcenter page" --export-filename="$original_image"
  inkscape "$original_image" --batch-process --export-type=png --export-area-page --export-width=72 --export-height=72 --export-filename="$converted_image"

  if [ -f "${converted_image}" ]; then
    echo "${filename}" >> ./uri_converted.txt
  fi
done < ./uri.txt

echo "########### Arquivos que não baixaram"
diff ./uri_base.txt ./uri_dlownloaded.txt | grep "^<" | sed 's/^< //'

echo ""

echo "########### Arquivos que não converteram"
diff ./uri_base.txt ./uri_converted.txt | grep "^<" | sed 's/^< //'
