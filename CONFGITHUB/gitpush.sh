#!/bin/bash

url="https://github.com/DavidRodera/Grado-Superior-ASIR.git"
repositorio=$(basename "$url" .git)
ruta=$(find /home/$(whoami) -type d -name "$repositorio" -print -quit)
cd $ruta
if [ $? -eq 0 ]
then
	echo ''
	git add .
	git commit -m '⬆️ ASIR: Subida de nuevos materiales y prácticas'
	git push
	if [ $? -eq 0 ]
	then
		echo ''
		echo 'Cambios publicados correctamente'
	else
		echo ''
		echo 'ERROR al publicar los cambios'
	fi
else
	exit
fi
