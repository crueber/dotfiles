#!/bin/bash
#
#	This script depends on:
#       
#	audible-cli: to download the files.
#		Repository can be found at https://github.com/mkb79/audible-cli
#
#		aaxclean-cli: to convert to .m4b audiobook.
#		Repository can be found at https://github.com/Mbucari/aaxclean-cli
#
#		jq: to parse the .voucher file for .aaxc conversion
#		search your Official Repositories or https://stedolan.github.io/jq/download/
#
#		This script can use full path or convert in folder with the files present
#		and will save the file(s) to a folder of the same name as the Audiobook
#
#

# convert any audible book *.{aaxc,aax} to .m4b format automatically

# this will pull the correctly named voucher file, needs to be in same folder as .aaxc file
voucher="$(printf '..%s..' "$1" | sed 's/.aaxc/.voucher/')" 

# Strip any leading directories from the name
file="$(basename "$1")"

# ensure the file will be in the correct format for conversion
audiofile1="$(printf '..%s..' "$(basename "$1")" | sed 's/-AAX_22_64.aaxc/.m4b/')"
audiofile2="$(printf '..%s..' "$(basename "$1")" | sed 's/-LC_128_44100_stereo.aax/.m4b/')"

# This will parse the activation bytes field automatically.
# No need to find the activation bytes every time.
authcode="$(jq -r '.activation_bytes' ~/.audible/audible.json)"

# Parses the IV value from the .voucher file automatically.
aaxc_iv="jq -r '.content_license.license_response.iv' "$voucher" | column -t"

# Parses the KEY value from the .voucher file automatically.
aaxc_key="jq -r '.content_license.license_response.key' "$voucher" | column -t" 

# Converts "$1" regardless of AAX or AAXC extension to MP3 or M4A respectively
# the files do not need an absolute path to work
if [[ "$1" =~ .*\.(aaxc$) ]];
	then
		aaxclean-cli "$2" -f --audible_key "$aaxc_key" --audible_iv "$aaxc_iv" -o ~/Audiobook/"$(printf '..%s..' "$file" | sed 's/-AAX_22_64.aaxc//')"/"$audiofile1"
elif [[ "$1" =~ .*\.(aax$) ]];
	then
		aaxclean-cli -f "$1" --activation_bytes "$authcode" -o ~/Audiobook/"$(printf '..%s..' "$file" | sed 's/-LC_128_44100_stereo.aax//')"/"$audiofile2"
fi

# Old setup this will convert all .aaxc files in a single directory

# Converts ALL AACX files to mp3 or m4b
#for aaxc in $(find . -iname "*.aaxc" | sed 's/.aaxc//')
#do
#aaxclean-cli -s -f "$aaxc".aaxc --audible_key "$(jq -r '.content_license.license_response.key' $voucher | column -t)" --audible_iv "$(jq -r '.content_license.license_response.iv' $voucher | column -t)" -o ~/Audiobook/"$aaxc".m4b
#done
