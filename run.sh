#!/bin/bash/ -e

shippable_decrypt() {
  local source_file=$1
  local key_file=$2
  local temp_dest='/tmp/shippable/decrypt'

  if [ "$key_file" == "" ]; then
    key_file=/tmp/ssh/00_sub
  fi

  echo "shippable_decrypt: Decrypting $source_file using key $key_file"

  if [ ! -f "$key_file" ]; then
    echo "shippable_decrypt: ERROR - Key file $key_file not found"
    exit 100
  fi

  if [ -d "$temp_dest" ]; then
    rm -r ${temp_dest:?}
  fi
  mkdir -p $temp_dest/fragments

  base64 --decode < "$source_file" > $temp_dest/encrypted.raw
  split -b 256 "$temp_dest/encrypted.raw" $temp_dest/fragments/
  local fragments
  fragments=$(ls -b $temp_dest/fragments)
  for fragment in $fragments; do
    openssl rsautl -decrypt -inkey "$key_file" -oaep < "$temp_dest/fragments/$fragment" >> "$source_file.decrypted"
  done;

  rm -r ${temp_dest:?}/*
  echo "shippable_decrypt: Decrypted $source_file to $source_file.decrypted"
}

#cat "/home/shippable/decrypt/encrypted.txt"
shippable_decrypt "/home/shippable/decrypt/encrypt.txt" "/home/shippable/decrypt/key.pem"
# cp  newfile.txt

# file="newfile.txt"

# let count=0
# while read LINE 
# do
#   ((count++))
# #echo checks line by line
#   echo $LINE > $file
#   echo "================starting==================="

#   out1="shippable_decrypt "$file" "/tmp/ssh/00_sub" "
#   echo $out1
# done 

# echo "number of strings encrypted"
# echo $count 
