# Orthofinder
mkdir -p orthofinder
cp /data/$line/*genomic.gff_protein.longestisof.faa orthofinder
orthofinder.py -f orthofinder -og -t 16 -a 16

# Ultrametric tree

# NEXUS
echo "
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

end;" > r8s.nexus

pyr8s -b r8s.nexus 2> r8s.log

# CAFE
cafe5 -i /data/orthofinder/cafe.Orthogroups.GeneCount.tsv -t /data/orthofinder/ultrametric.nwk -c 24

# Selective pressure analysis

for i in /data/selected_OGs/OG*; do
perl guidance.pl --seqFile $i --msaProgram PRANK --seqType codon --outDir ${i}_out --bootstraps 5 --msaFile ${i}.pal2nal 2> guidance.log
done

# dN/dS
for i in /data/Homininae_analyses/*.pal2nal; do
  base=${i%.pal2nal}

  ete3 evol -t /data/Homininae_analyses/homininae_tree.nwk \
            --alg /data/Homininae_analyses/$i \
            --models M3 M0 \
            -o "${base}_gene_results/" \
            --cpu 8 --codeml_param icode,0 > "${base}_m3_m0.log"
done

for i in /data/Homininae_analyses/*.pal2nal; do
  base=${i%.pal2nal}

  ete3 evol -t /data/Homininae_analyses/homininae_tree.nwk \
            --alg /data/Homininae_analyses/$i \
            --models M2 M1 \
            -o "${base}_gene_results/" \
            --cpu 8 --codeml_param icode,0 > "${base}_m2_m1.log"
done

for i in /data/Homininae_analyses/*.pal2nal; do
  base=${i%.pal2nal}

  ete3 evol -t /data/Homininae_analyses/homininae_tree.nwk \
            --alg /data/Homininae_analyses/$i \
            --models M8 M7 \
            -o "${base}_gene_results/" \
            --cpu 8 --codeml_param icode,0 > "${base}_m8_m7.log"
done

for i in /data/Homininae_analyses/*.pal2nal; do
  base=${i%.pal2nal}

  ete3 evol -t /data/Homininae_analyses/homininae_tree.nwk \
            --alg /data/Homininae_analyses/$i \
            --models M8 M8a \
            -o "${base}_gene_results/" \
            --cpu 8 --codeml_param icode,0 > "${base}_m8_m8a.log"
done


