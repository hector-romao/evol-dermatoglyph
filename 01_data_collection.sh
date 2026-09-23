#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="${1:-data/table_acc-sp.tsv}"
OUTPUT_DIR="${2:-data}"
API_KEY="${NCBI_API_KEY:-}"

if [[ ! -f "$DATA_FILE" ]]; then
  echo "Arquivo de entrada não encontrado: $DATA_FILE" >&2
  exit 1
fi

while IFS=$'\t' read -r species accession || [[ -n "${species:-}" || -n "${accession:-}" ]]; do
  species="${species:-}"
  accession="${accession:-}"

  [[ -z "$species" || -z "$accession" ]] && continue

  species_dir="$OUTPUT_DIR/$species"
  mkdir -p "$species_dir"

  echo "Baixando dados para $species ($accession)"

  if [[ -n "$API_KEY" ]]; then
    datasets download genome accession "$accession" \
      --include genome,protein,cds,gff3,gtf,rna \
      --api-key "$API_KEY" \
      --filename "$species_dir/ncbi_dataset.zip"
  else
    datasets download genome accession "$accession" \
      --include genome,protein,cds,gff3,gtf,rna \
      --filename "$species_dir/ncbi_dataset.zip"
  fi

  unzip -o "$species_dir/ncbi_dataset.zip" -d "$species_dir"
  echo "Dados de $species armazenados em $species_dir"

done < "$DATA_FILE"

exit 0
