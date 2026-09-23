#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-data}"
OUT_DIR="${OUT_DIR:-$DATA_DIR/single_copy-gene}"
THREADS="${THREADS:-16}"

mkdir -p "$OUT_DIR"

if command -v conda >/dev/null 2>&1; then
  echo "Ativando ambiente BUSCO_phylogenomics, se disponível."
  conda activate BUSCO_phylogenomics || true
fi

if [[ -f "BUSCO_phylogenomics.py" ]]; then
  python BUSCO_phylogenomics.py \
    -i "$DATA_DIR" \
    --supermatrix_only \
    -t "$THREADS" \
    -o single_copy-gene
fi

mkdir -p "$OUT_DIR/alignments" "$OUT_DIR/trimmed"

for fasta in "$OUT_DIR"/supermatrix/sequences/*.faa; do
  [[ -e "$fasta" ]] || continue
  name=$(basename "$fasta")
  mafft --thread "$THREADS" --local-pair --maxiterate 1000 "$fasta" > "$OUT_DIR/alignments/alg.${name}"
done

for file in "$OUT_DIR/alignments"/alg*; do
  [[ -e "$file" ]] || continue
  trimal -automated1 \
    -in "$file" \
    -out "$OUT_DIR/trimmed/$(basename "$file").trim" \
    -htmlout "$OUT_DIR/trimmed/$(basename "$file").report.trimal.html"
done

catfasta2phyml.pl -c -f "$OUT_DIR/trimmed"/*.trim > "$OUT_DIR/concatenated_dataset_single_copy.fasta"

iqtree3 -s "$OUT_DIR/concatenated_dataset_single_copy.fasta" \
  -m MFP \
  -B 1000 \
  -T "$THREADS" \
  -o Cynocephalus_volans,Galeopterus_variegatus

exit 0

