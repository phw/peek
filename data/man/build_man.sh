#!/usr/bin/env sh

PROJECT=$1
VERSION=$2
INPUT=$3
OUTPUT=$4

txt2man -t "$PROJECT" -r "$VERSION" \
  -s 1 -v "User commands" \
  "$INPUT" | gzip > "$OUTPUT"
