#!/bin/bash

cd /SSD/bluray/rips/episodes/queue

currshowid='Show Name (YYYY) [tvdbid-123456]'
convcount=${1:-5}
files=(*.mkv)
hb_files=()
arrsize=${#files[@]}

if [ $arrsize -eq 0 ]
then
 exit 2
fi

if [ $arrsize -lt $convcount ]
then
 convcount=$arrsize
fi

convcount=$(($convcount-1))

for f in $(seq 0 $convcount)
do
 mv "/SSD/bluray/rips/episodes/queue/${files[f]}" '/SSD/bluray/rips/episodes/encode/'
 hb_files+=(${files[f]})
done

cd /SSD/bluray/rips/episodes/encode

for m in "${hb_files[@]}"
do

 HandBrakeCLI --input "/SSD/bluray/rips/episodes/encode/$m" \
  --output "/SSD/bluray/rips/episodes/cut/$m" \
  --format av_mkv --encoder x265_10bit --encoder-preset slower \
  --quality 20 --vfr --all-audio --aencoder copy:dtshd,copy:ac3 --all-subtitles
  #--audio 1,2,3,4 --aencoder copy:truehd,copy:ac3,copy:truehd,copy:ac3 --subtitle 1,2

 mkvpropedit "/SSD/bluray/rips/episodes/cut/$m" \
  --edit info --set "title=${m/%.mkv}" \
  --edit track:a1 --set flag-default=1 --set "name=ENG DTS-HD 5.1 Surround" \
  --edit track:a3 --set flag-default=0 --set "name=ENG DD Stereo" \
  --edit track:s1 --set flag-default=1 --set "name=English - PGS - Full"
  --edit track:s2 --set flag-default=0 --set "name=English - PGS - Forced"

done

for e in "${hb_files[@]}"
do
 mv "/SSD/bluray/rips/episodes/encode/$e" '/HDD/original/bluray/files/'
done

for c in "${hb_files[@]}"
do
 cp "/SSD/bluray/rips/episodes/cut/$c" "/SSD/backup/bluray/$currshowid/"
 cp "/SSD/bluray/rips/episodes/cut/$c" '/SSD/bluray/cloud/save/'
 mv "/SSD/bluray/rips/episodes/cut/$c" "/SSD/jellyfin/$currshowid/"
done
