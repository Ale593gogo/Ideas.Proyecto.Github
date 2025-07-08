# Proceso para analisis de filogenia para Muridae usando secuencias de estos roedores con genes resistentes al cancer

## 1. CON EL ARCHIVO DE DATA QUE SON:
    SECUENCIAS DE GENES DE MURIDAE CON RESISTENCIA AL CANCER YA COMBINADAS EN .FASTA C
    COPIARLAS AL COMPUTADOR Y EDITARLAS EN ATOM 
    -----OPCIONAL ((descarga de ncbi de Muridae los genes con resistencia a cancer de muridae usa el script de bash para descargarlo))

 ## 2. Extracción de Código y Nombre del Gen
     Editar el archivo FASTA para conservar solo el nombre del gen y su codigo.

  ## 3. Usando ATOM en el computador
    VERIFICAR SI ATOM ESTA INSTALADO SINO DESCARGARLO E INSTALARLO https://atom-editor.cc/
    1. Abre el archivo .fasta en Atom
    2. Ve al panel en find in buffer y seleccionando la opcion ".*"
    3. Edita la secuencia teniendo el codigo del gen y su nombre usando:
     - >.*?\|(.*?)\|.*\n+
    4. Reemplazar: >$1,$2
    3. Guardarlo como genesedited.fasta
    4. Copialos a hoffman con el comando scp

   ## 4. Alineacion con muscle
    1.en una carpeta en hoffman copia muscle ahi
    2.con el comando usar el programa "./muscle3.8.31_i86linux64"
    3. for filename in *.fasta
    do muscle3.8.31_i86linux64 -in $filename -out muscle_$filename -maxiters 1 -diags done
    puedes usar cat para ver si los archivos fueron generados

  ## 5. Uso de IQTREE
    1. Cargar el modulo con load iqtree/2.2.2.6
    2. for filename in muscle_*  do iqtree2 -s $filename  done
    3. usando cat combinar los archivos .tree en uno solo con *.treefile > All.trees
  
## 6. Uso de ASTRAL 
    1. Verificar que java este instalado o corriendo 
    2.correrlo con -jar astral.5.7.8.jar recuerda usar tab para completar la version java -jar astral -i All.trees -o Astral.Muridaecancer.tree
    3. con el comando scp en laterminal del computador copiar este archivo 
## 7. Uso de FIGTREE PARA EL ARBOL
    VERIFICAR SI FIGTREE ESTA INSTALADO SINO DESCARGARLO E INSTALARLO DE https://tree.bio.ed.ac.uk/software/figtree/
    1. Abrir Figtree y abrir el archivo Astral.Muridaecancer.tree 
    2. usando las herramientas colour resaltarlos
    3. con las herramientas tip labels y node labels mejorar la visualizacion 
    4. Manejar a gusto el softeware para generar relaciones
 


