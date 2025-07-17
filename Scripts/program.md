#!/bin/bash

# ==============================================
# ANÁLISIS FILOGENÉTICO DE MURIDAE CON RESISTENCIA AL CÁNCER
# ==============================================

# Configuración inicial
WORKDIR="Muridae_Cancer_Analysis"
INPUT_FASTA="muridae_sequences.fasta"
MUSCLE_BIN="./muscle3.8.31_i86linux64"
ASTRAL_JAR="astral.5.7.8.jar"
THREADS=$(nproc)

# Crear estructura de directorios
mkdir -p $WORKDIR/{data,alignment,trees,results}
cd $WORKDIR

# 1. Preparación de secuencias
echo "1. PROCESANDO SECUENCIAS..."

# Copiar archivo de entrada (simulado - en realidad usarías tu archivo FASTA)
echo ">X96996.1|A.airensis|mitochondrial cytb gene
ATGAAAATTATACGAAAAACACACCCACTCCTAAAAATCATTAACCATGCGTTCGTCGACCTCCCTGCAC
CCTCCAACATCTCATCATGATGAAACTTCGGCTCTCTATTAGGGGTATGCCTAGTAATCCAAATCCTCAC" > data/$INPUT_FASTA

# Limpieza de headers (reemplaza lo que harías manualmente en Atom)
echo "   Limpiando headers FASTA..."
perl -i -pe 's/>.*?\|([^|]+)\|.*/>$1/' data/$INPUT_FASTA

# 2. Alineamiento con MUSCLE
echo -e "\n2. ALINEAMIENTO CON MUSCLE..."
$MUSCLE_BIN -in data/$INPUT_FASTA -out alignment/aligned_$INPUT_FASTA -maxiters 1 -diags 2> muscle.log

# Verificar alineamiento
if [ ! -s alignment/aligned_$INPUT_FASTA ]; then
    echo "ERROR: Fallo en el alineamiento"
    exit 1
fi

# 3. CONSTRUCCIÓN DE ÁRBOL CON IQ-TREE
echo -e "\n3. CONSTRUYENDO ÁRBOL FILOGENÉTICO..."
iqtree2 -s alignment/aligned_$INPUT_FASTA -m GTR+G -bb 1000 -nt $THREADS -pre trees/muridae 2> iqtree.log

# 4. CONCORDANCIA DE ÁRBOLES CON ASTRAL
echo -e "\n4. ANALIZANDO CONCORDANCIA CON ASTRAL..."
if [ -f $ASTRAL_JAR ]; then
    java -jar $ASTRAL_JAR -i trees/muridae.treefile -o results/Astral.MuridaeCancer.tree 2> astral.log
else
    echo "WARNING: ASTRAL no encontrado, saltando este paso"
    cp trees/muridae.treefile results/Astral.MuridaeCancer.tree
fi

# 5. PREPARAR RESULTADOS FINALES
echo -e "\n5. PREPARANDO RESULTADOS..."
cp trees/muridae.contree results/Consensus.tree
cp trees/muridae.log results/ 

# Generar reporte
echo -e "\nANÁLISIS COMPLETADO:\n"
echo "Árbol de consenso: results/Consensus.tree"
echo "Árbol ASTRAL: results/Astral.MuridaeCancer.tree"
echo "Log de IQ-TREE: results/muridae.log"
echo "\nPara visualizar:"
echo "scp -r ${USER}@hoffman2.idre.ucla.edu:$(pwd)/results/ ."
echo "Luego abra los archivos .tree en FigTree"


