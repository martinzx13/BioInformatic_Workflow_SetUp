#!/bin/bash
set -euo pipefail

OUTPUT_DIR=$1
mkdir -p "$OUTPUT_DIR"

random_seq() {
  local len=$1
  local bases=(A C G T)
  seq=""
  for j in $(seq 1 $len); do
    seq+=${bases[$((RANDOM % 4))]}
  done
  echo "$seq"
}

random_qual() {
  local len=$1
  # Use Phred+33 range: ASCII 33–73 (chars like ! " # $ % ... I)
  qual=""
  for j in $(seq 1 $len); do
    # Pick a random ASCII between 33 and 73
    qual+=$(printf "\\$(printf '%03o' $((33 + RANDOM % 40)))")
  done
  echo "$qual"
}

for i in {1..10}; do
  R1_FILE="$OUTPUT_DIR/sample${i}_R1.fastq"
  R2_FILE="$OUTPUT_DIR/sample${i}_R2.fastq"

  for r in {1..20}; do
    seq1=$(random_seq 50)
    qual1=$(random_qual 50)
    seq2=$(random_seq 50)
    qual2=$(random_qual 50)

    echo "@sample${i}_R1_read${r}" >>"$R1_FILE"
    echo "$seq1" >>"$R1_FILE"
    echo "+" >>"$R1_FILE"
    echo "$qual1" >>"$R1_FILE"

    echo "@sample${i}_R2_read${r}" >>"$R2_FILE"
    echo "$seq2" >>"$R2_FILE"
    echo "+" >>"$R2_FILE"
    echo "$qual2" >>"$R2_FILE"
  done

  gzip "$R1_FILE"
  gzip "$R2_FILE"
done

echo "Created 10 dummy paired FASTQ.gz files in $OUTPUT_DIR"
