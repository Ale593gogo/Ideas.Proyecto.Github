#!/bin/bash

# Directorios y archivos de salida
output_dir="Muridae_Cancer_Resistance"
output_file="${output_dir}/combined_sequences.fasta"
max_sequences=15
min_sequence_size=300

# Genes a analizar
cancer_genes=("Trp53" "Brca1" "Chek2" "Puma")
reference_genes=("cytb" "rag1")
familia="Muridae"

# Crear directorio si no existe
mkdir -p "$output_dir"

# Encabezado del archivo FASTA
echo "> Muridae Cancer Resistance Gene Sequences" > "$output_file"
echo "> Downloaded from NCBI on $(date '+%Y-%m-%d')" >> "$output_file"
echo "" >> "$output_file"

# Función para descargar secuencias
download_sequences() {
    local gen=$1
    local temp_file="${output_dir}/${gen}_temp.fasta"
    
    echo "Descargando secuencias para ${gen}..."
    
    # Buscar IDs en NCBI
    ids=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nuccore&term=${gen}[GENE]+AND+${familia}[ORGN]&retmax=${max_sequences}" | \
          grep -Eo '<Id>[0-9]+</Id>' | sed 's/<Id>//;s/<\/Id>//' | tr '\n' ',')
    
    if [ -n "$ids" ]; then
        # Descargar secuencias en formato FASTA
        curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${ids}&rettype=fasta&retmode=text" > "$temp_file"
        
        # Filtrar por tamaño mínimo y limitar cantidad
        awk -v min_len="$min_sequence_size" '
            /^>/ { 
                if (seqlen >= min_len && header) print header "\n" seq
                header=$0; seq=""; seqlen=0 
            } 
            !/^>/ { seq=seq $0; seqlen+=length($0) } 
            END { if (seqlen >= min_len) print header "\n" seq }
        ' "$temp_file" | head -n $((max_sequences*2)) >> "$output_file"
        
        echo "  → ${gen}: OK"
    else
        echo "  → ${gen}: No se encontraron secuencias"
    fi
    
    rm -f "$temp_file"
    sleep 1
}

# Descargar genes de referencia
download_references() {
    for gen in "${reference_genes[@]}"; do
        download_sequences "$gen"
        echo "> Reference: ${gen}" >> "$output_file"
    done
}

# Verificar programas necesarios
check_tools() {
    for tool in muscle iqtree2 curl; do
        if ! command -v $tool &>/dev/null; then
            echo "Error: $tool no está instalado"
            exit 1
        fi
    done
}

# Procesamiento principal
check_tools

# Descargar datos
for gen in "${cancer_genes[@]}"; do
    download_sequences "$gen"
done

download_references

# Procesar secuencias
echo "Procesando secuencias..."
sed -i 's/ .*//' "$output_file"  # Simplificar headers

# Alinear con MUSCLE
aligned_file="alignment.fasta"
muscle -in "$output_file" -out "$aligned_file" 2>/dev/null

# Construir árbol filogenético
echo "Construyendo árbol filogenético..."
iqtree2 -s "$aligned_file" -nt AUTO -quiet -bb 1000

# Resultados finales
echo "Análisis completado:"
echo "- Secuencias: $output_file"
echo "- Alineamiento: $aligned_file"
echo "- Árbol filogenético: ${aligned_file}.treefile"
