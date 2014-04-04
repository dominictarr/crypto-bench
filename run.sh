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
  # these don't have all the hashes,
  # so continue if they fail
  bench "$1" jshashes          "$2" || true
  case "$2" in
    sha256 | ripemd )
      bench "$1" cryptomx          "$2"
    ;;
    sha1 )
      bench "$1" rusha          sha1
      bench "$1" git-sha1       sha1
    ;;
  esac
  # bench hash node
}

shorten () {
  # shorten column names, so that there is room on the graph legend.
  replace-stream /-[\\w\\d]+\\.[\\w\\/-_]+/ ''
}

graphs () {
  ls ./../dat-table/bin.js

  # sha hashing increasing file size.

  dat-table output/hash/*-sha1.csv -c 1,3 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'time to SHA1 largish file' \
  > graphs/hash-sha1.png

  dat-table output/hash/*-sha256.csv -c 1,3 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'time to SHA256 largish file' \
  > graphs/hash-sha256.png

  # sha hashing bytes/ms

  dat-table output/hash/*-sha1.csv -c 1,2 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'bytes/ms SHA1 hashed' \
  > graphs/hash-ops-sha1.png

  dat-table output/hash/*-sha256.csv -c 1,2 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'bytes/ms SHA256 hashed' \
  > graphs/hash-ops-sha256.png

  # key derivation

  dat-table output/pbkdf2/*-sha1.csv -c 0,2 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha1) iterations per millisecond' \
  > graphs/pbkdf2-ops-sha1.png

  dat-table output/pbkdf2/*-sha256.csv -c 0,2 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha256) iterations per millisecond' \
  > graphs/pbkdf2-ops-sha256.png

  # key derivation, iterations / ms

  dat-table output/pbkdf2/*-sha1.csv -c 0,1 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha1) increasing iterations' \
  > graphs/pbkdf2-sha1.png

  dat-table output/pbkdf2/*-sha256.csv -c 0,1 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'pbkdf2(sha256) increasing iterations' \
  > graphs/pbkdf2-sha256.png

  # zoomed in on the very start of the file hash graph

  dat-table output/hash/*-sha1.csv  -c 1,2 -s 0,30 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'sha1 hashing small values' \
  > graphs/small-hash-sha1.png

  dat-table output/hash/*-sha256.csv  -c 1,2 -s 0,30 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'sha256 hashing small values' \
  > graphs/small-hash-sha256.png

  # ripemd160 hashing increasing file size.

  dat-table output/hash/*-ripemd160.csv -c 1,3 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'time to RIPEMD160 largish file' \
  > graphs/hash-ripemd160.png

  # ripemd160 hashing bytes/ms

  dat-table output/hash/*-ripemd160.csv -c 1,2 \
  | shorten \
  | line-graph --width 600 --height 400 --title 'bytes/ms RIPEMD160 hashed' \
  > graphs/hash-ops-ripemd160.png

  # comparison of the best hashes, largeish file

  H=output/hash
  dat-table $H/forge-sha256.csv $H/blake2s-blake2s.csv $H/rusha-sha1.csv -c 1,3 \
  | line-graph --width 600 --height 400 --title 'comparison of the fastest hashes' \
  > graphs/hash-best.png

  dat-table $H/forge-sha256.csv $H/blake2s-blake2s.csv $H/rusha-sha1.csv -c 1,2 \
  | line-graph --width 600 --height 400 --title 'fastest hashes, bytes/ms' \
  > graphs/hash-ops-best.png

}

"$@"

