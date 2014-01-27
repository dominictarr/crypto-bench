#! /usr/bin/env bash

PATH=node_modules/.bin:$PATH

set -e

bench () {
  name="$2"-"$3"
  echo "***************************************"
  echo "* running benchmark: $1 with $2"
  echo "***************************************"
  echo
  mkdir -p output/"$1"
  node bench-"$1".js "$2" "$3" | tee output/"$1"/"$name".csv
  echo
}

all () {
  # usage : all hash sha1

  bench "$1" crypto-browserify "$2"
  bench "$1" sjcl              "$2"
  bench "$1" crypto-js         "$2"
  bench "$1" forge             "$2"
  # bench hash node
}

graphs () {
  ls ./../dat-table/bin.js


  # sha hashing increasing file size.

  dat-table output/hash/*-sha1.csv -c 1,3 \
  | line-graph --width 600 --height 400 --title 'time to SHA1 largish file' \
  > graphs/hash-sha1.png

  dat-table output/hash/*-sha256.csv -c 1,3 \
  | line-graph --width 600 --height 400 --title 'time to SHA256 largish file' \
  > graphs/hash-sha256.png

  # sha hashing bytes/ms

  dat-table output/hash/*-sha1.csv -c 1,2 \
  | line-graph --width 600 --height 400 --title 'bytes/ms SHA1 hashed' \
  > graphs/hash-ops-sha1.png

  dat-table output/hash/*-sha256.csv -c 1,2 \
  | line-graph --width 600 --height 400 --title 'bytes/ms SHA256 hashed' \
  > graphs/hash-ops-sha256.png

  # key derivation

  dat-table output/pbkdf2/*-sha1.csv -c 0,2 \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha1) iterations per millisecond' \
  > graphs/pbkdf2-ops-sha1.png

  dat-table output/pbkdf2/*-sha256.csv -c 0,2 \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha256) iterations per millisecond' \
  > graphs/pbkdf2-ops-sha256.png

  # key derivation, iterations / ms

  dat-table output/pbkdf2/*-sha1.csv -c 0,1 \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha1) increasing iterations' \
  > graphs/pbkdf2-sha1.png

  dat-table output/pbkdf2/*-sha256.csv -c 0,1 \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha256) increasing iterations' \
  > graphs/pbkdf2-sha256.png

  # zoomed in on the very start of the file hash graph

  dat-table output/hash/*-sha1.csv  -c 1,2 -s 0,30 \
  | line-graph --width 600 --height 400 --title 'sha1 hashing small values' \
  > graphs/small-hash-sha1.png

  dat-table output/hash/*-sha256.csv  -c 1,2 -s 0,30 \
  | line-graph --width 600 --height 400 --title 'sha256 hashing small values' \
  > graphs/small-hash-sha256.png

}

"$@"

