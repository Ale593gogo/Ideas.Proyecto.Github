#!/bin/bash

# Script completo para descargar genes de Muridae y procesarlos

# 1. Verificar/instalar dependencias
echo "=== Verificando dependencias ==="

# Función para instalar NCBI Datasets
install_datasets() {
    if ! command -v conda &> /dev/null; then
        echo "Instalando Miniconda..."
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
        bash miniconda.sh -b -p $HOME/miniconda
        rm miniconda.sh
        export PATH="$HOME/miniconda/bin:$PATH"
        conda init bash
        source ~/.bashrc
    fi
    
    echo "Instalando NCBI Datasets..."
    conda install -c conda-forge -c bioconda ncbi-datasets-cli -y
}

# Verificar NCBI Datasets
if ! command -v datasets &> /dev/null; then
    echo "NCBI Datasets no encontrado, instalando..."
    install_datasets
    # Verificar instalación
    if ! command -v datasets &> /dev/null; then
        echo "Error: No se pudo instalar NCBI Datasets"
        exit 1
    fi
fi

# 2. Configuración
GENES=("IFIH1" "TP53" "PARP1" "BRCA1")
OUTPUT_DNA="Muridae_genes.fasta"
OUTPUT_GENESEDITADOS="Muridae_geneseditados.fasta"
OUTPUT_DNA_EDITED="${OUTPUT_DNA%.*}_edited.fasta"
OUTPUT_GENESEDITADOS_EDITED="${OUTPUT_GENESEDITADOS%.*}_edited.fasta"

# 3. Procesamiento
echo "=== Procesando genes ==="
> "$OUTPUT_DNA"
> "$OUTPUT_GENESEDITADOS"

for GENE in "${GENES[@]}"; do
    echo "Descargando $GENE..."
    
    # Descargar datos
    datasets download gene symbol "$GENE" --ortholog Muridae --filename "${GENE}_Muridae.zip"
    
    # Extraer y procesar
    unzip -q "${GENE}_Muridae.zip" -d "${GENE}_Muridae"
    
    if [[ -f "${GENE}_Muridae/ncbi_dataset/data/gene.fna" ]]; then
        dataformat fasta gene --inputfile "${GENE}_Muridae/ncbi_dataset/data/gene.fna" >> "$OUTPUT_DNA"
    fi

    if [[ -f "${GENE}_Muridae/ncbi_dataset/data/protein.faa" ]]; then
        dataformat fasta protein --inputfile "${GENE}_Muridae/ncbi_dataset/data/protein.faa" >> "$OUTPUT_GENESEDITADOS"
    fi

    # Limpieza
    rm -rf "${GENE}_Muridae.zip" "${GENE}_Muridae"
done

# 4. Editar nombres
echo "Editando nombres de secuencias..."
perl -pe 's/(>\w+\.\d+)\s.+/\1/' "$OUTPUT_DNA" > "$OUTPUT_DNA_EDITED"
perl -pe 's/(>\w+\.\d+)\s.+/\1/' "$OUTPUT_GENESEDITADOS" > "$OUTPUT_GENESEDITADOS_EDITED"

# 5. Resultados
echo -e "\n=== Proceso completado ==="
echo "Archivos generados:"
echo " - ADN completo: $OUTPUT_DNA"
echo " - ADN editado: $OUTPUT_DNA_EDITED"
echo " - Geneseditados completos: $OUTPUT_GENESEDITADOS"
echo " - Geneseditados editados: $OUTPUT_GENESEDITADOS_EDITED"
