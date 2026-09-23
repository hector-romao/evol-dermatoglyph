# evol-dermatoglyph

Pipeline para coleta, avaliação de qualidade, inferência filogenética e análise evolutiva de genomas e ortólogos em primatas.

## Visão geral

Este repositório reúne um conjunto de scripts para:

1. baixar dados de genomas do NCBI;
2. filtrar isoformas e preparar proteínas de interesse;
3. avaliar qualidade com BUSCO;
4. realizar alinhamentos filogenéticos;
5. inferir árvores com IQ-TREE;
6. estimar árvores ultramétricas e tendências evolutivas com OrthoFinder, CAFE e análises de pressão seletiva.

## Estrutura do repositório

- `01_data_collection.sh` — download dos genomas 
- `02_quality_assessment.sh` — remoção de isoformas e avaliação com BUSCO
- `03_phylogenetic_inference.sh` — alinhamento, trimming, concatenação e IQ-TREE
- `04_evolutionary_analyis.sh` — OrthoFinder, r8s, CAFE e testes de seleção
- `data/` — tabelas de metadados e arquivos de entrada/saída

## Requisitos

Os pipelines dependem de ferramentas externas do ecossistema de bioinformática, incluindo:

- NCBI Datasets CLI
- AGAT
- BUSCO
- BLAST+
- MAFFT
- trimAl
- IQ-TREE
- OrthoFinder
- r8s / pyr8s
- CAFE
- GUIDANCE
- ETE3
- Python 3

A maioria dos passos exige um ambiente bioinformático com estas ferramentas instaladas e acessíveis no `PATH`.

## Preparação

1. Ajuste os dados em `data/table_acc-sp.tsv` e `data/species_folder.list` conforme o projeto.
2. Verifique se os nomes de espécies e acessos correspondem ao banco NCBI.
3. Defina uma chave de API do NCBI, se necessário:

```bash
export NCBI_API_KEY="sua_chave"
```

## Execução

### 1) Coleta de dados

```bash
bash 01_data_collection.sh
```

### 2) Avaliação de qualidade

```bash
bash 02_quality_assessment.sh
```

### 3) Inferência filogenética

```bash
bash 03_phylogenetic_inference.sh
```

### 4) Análises evolutivas

```bash
bash 04_evolutionary_analyis.sh
```

## Observações importantes

- Os scripts foram revisados para reduzir erros comuns de sintaxe e de path.
- O projeto assume que os diretórios `data/` e os arquivos de entrada já existem.
- Algumas etapas são computacionalmente pesadas e podem exigir uma máquina com múltiplos núcleos.
- Os dados brutos gerados por download e alinhamentos podem ser grandes; em um repositório GitHub, recomenda-se armazenar outputs pesados em armazenamento externo ou em LFS.

## Licença

Este projeto foi desenvolvido para fins de pesquisa e análise evolutiva. Consulte os termos das ferramentas externas e das bases de dados utilizadas antes de reutilizar os dados em outros contextos.

## Contato

Para dúvidas sobre o fluxo ou ajustes computacionais, consulte o mantenedor do repositório ou os registros de execução do pipeline.
