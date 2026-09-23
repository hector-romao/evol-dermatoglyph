
#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-data}"
SPECIES_FILE="${SPECIES_FILE:-$DATA_DIR/species_folder.list}"

if [[ ! -f "$SPECIES_FILE" ]]; then
  echo "Species file not found: $SPECIES_FILE" >&2
  exit 1
fi

shopt -s nullglob

while IFS= read -r primate || [[ -n "$primate" ]]; do
  primate="${primate%%$'\r'}"
  [[ -z "$primate" ]] && continue

  echo "Processing $primate"
  species_dir="$DATA_DIR/$primate"
  mkdir -p "$species_dir/filtered"

  gff_candidates=("$species_dir"/ncbi_dataset/data/GCF*/*.gff)
  if [[ ${#gff_candidates[@]} -eq 0 ]]; then
    echo "No .gff files found in $species_dir" >&2
    continue
  fi

  for gff_file in "${gff_candidates[@]}"; do
    base_name=$(basename "$gff_file")
    filtered_dir="$species_dir/filtered"

    echo "Running AGAT on $base_name"
    agat_sp_keep_longest_isoform.pl -gff "$gff_file" -o "$filtered_dir/${base_name}.longest"

    echo "Extracting protein IDs for $base_name"
    grep -o 'cds-[A-Za-z0-9._-]*' "$filtered_dir/${base_name}.longest" \
      | cut -d '-' -f2 \
      | sort -u > "$filtered_dir/${base_name}.id"

    protein_file=$(find "$species_dir" -name 'protein.faa' -print -quit)
    if [[ -z "$protein_file" ]]; then
      echo "protein.faa file not found in $species_dir" >&2
      continue
    fi

    echo "Extracting sequences with blastdbcmd"
    makeblastdb -in "$protein_file" -dbtype prot -parse_seqids
    blastdbcmd -db "$protein_file" \
      -entry_batch "$filtered_dir/${base_name}.id" \
      -out "$filtered_dir/${base_name}_protein.longestisof.faa"
  done

  echo "Running BUSCO for $primate"
  busco -i "$filtered_dir"/*_protein.longestisof.faa \
    -f -m protein \
    -l primates_odb10 \
    -o "$primate" \
    -c 12

done < "$SPECIES_FILE"

exit 0

