#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-data}"
THREADS="${THREADS:-16}"

mkdir -p "$DATA_DIR/orthofinder"

if [[ -d "$DATA_DIR/filtered" ]]; then
  cp "$DATA_DIR"/filtered/*_protein.longestisof.faa "$DATA_DIR/orthofinder/"
fi

if command -v orthofinder >/dev/null 2>&1; then
  orthofinder -f "$DATA_DIR/orthofinder" -og -t "$THREADS" -a "$THREADS"
else
  echo "orthofinder não encontrado no PATH. Instale o programa antes de executar esta etapa."
fi

cat > "$DATA_DIR/r8s.nexus" <<'EOF'
begin trees;
  tree TREE1 = [&R] (((((Aotus_nancymaae:0.0120277468,((Callithrix_jacchus:0.0175918189,Saimiri_boliviensis_boliviensis:0.0139034732):0.0004453600,(Cebus_imitator:0.0057722887,Sapajus_apella:0.0042540758):0.0092096139):0.0008103320):0.0181730020,((((((Cercocebus_atys:0.0073601620,Mandrillus_leucophaeus:0.0093344214)65:0.0006555549,(Papio_anubis:0.0045133727,Theropithecus_gelada:0.0030747821)65:0.0010368548):0.0007259621,(((Macaca_fascicularis:0.0027650968,Macaca_mulatta:0.0022092006):0.0006745402,Macaca_nemestrina:0.0029670531):0.0004721622,Macaca_thibetana_thibetana:0.0026299178):0.0020918235):0.0013099004,Chlorocebus_sabaeus:0.0062132802):0.0023986594,((Colobus_angolensis_palliatus:0.0103471645,Piliocolobus_tephrosceles:0.0064141353):0.0012647452,((Rhinopithecus_bieti:0.0071084912,Rhinopithecus_roxellana:0.0018582799):0.0025203518,Trachypithecus_francoisi:0.0051740504):0.0023645598):0.0026148567):0.0084535324,(((Gorilla_gorilla_gorilla:0.0056183650,(Homo_sapiens:0.0052592740,(Pan_paniscus:0.0028527937,Pan_troglodytes:0.0033318312):0.0023660600):0.0011151116):0.0039696577,(Pongo_abelii:0.0023892092,Pongo_pygmaeus:0.0021620809):0.0075418824):0.0014055786,((Hylobates_moloch:0.0046874770,Symphalangus_syndactylus:0.0057955216):0.0006601187,Nomascus_leucogenys:0.0040645843):0.0070594331):0.0045992792):0.0085851929):0.0267577329,Carlito_syrichta:0.0698862064):0.0052061543,(((Eulemur_rufifrons:0.0094119029,Lemur_catta:0.0118494251):0.0099526715,(Microcebus_murinus:0.0296365556,Propithecus_coquereli:0.0225190408):0.0017887502):0.0168575157,(Nycticebus_coucang:0.0205774216,Otolemur_garnettii:0.0210647725):0.0378475810):0.0152002995):0.0522551314,Cynocephalus_volans:0.0079961666,Galeopterus_variegatus:0.0134549628);
end;

begin r8s;
  blformat lengths=persite nsites=924443;
  collapse;

  mrca OL Galeopterus_variegatus Eulemur_rufifrons;
  mrca TS Carlito_syrichta Cercocebus_atys;
  mrca PC Aotus_nancymaae Cercocebus_atys;
  mrca HO Nomascus_leucogenys Pan_troglodytes;
  mrca HU Homo_sapiens Gorilla_gorilla_gorilla;

  fixage taxon=OL age=79;
  fixage taxon=TS age=69;
  fixage taxon=PC age=43;
  fixage taxon=HO age=19;
  fixage taxon=HU age=9;

  set smoothing=100;
  divtime method=pl;
  describe plot=chronogram;
  describe plot=tree_description;
end;
EOF

if command -v pyr8s >/dev/null 2>&1; then
  pyr8s -b "$DATA_DIR/r8s.nexus" 2> "$DATA_DIR/r8s.log"
else
  echo "pyr8s não encontrado. Ajuste o ambiente antes de rodar a etapa ultramétrica."
fi

if command -v cafe5 >/dev/null 2>&1; then
  cafe5 -i "$DATA_DIR/orthofinder/cafe.Orthogroups.GeneCount.tsv" \
    -t "$DATA_DIR/orthofinder/ultrametric.nwk" \
    -c 24
else
  echo "cafe5 não encontrado. Ajuste o ambiente antes de rodar a etapa de CAFE."
fi

for fasta in "$DATA_DIR/selected_OGs"/OG*; do
  [[ -e "$fasta" ]] || continue
  if command -v guidance.pl >/dev/null 2>&1; then
    perl guidance.pl --seqFile "$fasta" --msaProgram PRANK --seqType codon \
      --outDir "${fasta}_out" --bootstraps 5 --msaFile "${fasta}.pal2nal" 2> guidance.log
  else
    echo "guidance.pl não encontrado; pulei $fasta"
  fi
done

for alignment in "$DATA_DIR/Homininae_analyses"/*.pal2nal; do
  [[ -e "$alignment" ]] || continue
  base=${alignment%.pal2nal}
  for model_pair in "M3 M0" "M2 M1" "M8 M7" "M8 M8a"; do
    set -- $model_pair
    if command -v ete3 >/dev/null 2>&1; then
      ete3 evol -t "$DATA_DIR/Homininae_analyses/homininae_tree.nwk" \
        --alg "$alignment" \
        --models "$1" "$2" \
        -o "${base}_gene_results/" \
        --cpu 8 --codeml_param icode,0 > "${base}_${1}_${2}.log"
    else
      echo "ete3 não encontrado; pulei a comparação para $alignment"
    fi
  done
done

exit 0


