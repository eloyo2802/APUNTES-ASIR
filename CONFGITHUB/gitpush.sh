#!/bin/bash

url="https://github.com/eloyo2802/APUNTES-ASIR.git"
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
