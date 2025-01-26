#!/bin/bash

getCurrentVolume () { amixer get Master|sed -nE 's/(Front.*Left.*|Mono.*)\[([0-9]*)%\].*/\2/p';}
currentVolume="$(getCurrentVolume)"

attenteInitiale=600 #On attend dix minutes avant de commencer à baisser le son
dureeDeBaisse=1500  #On baisse le volume pendant 25 minutes
nombreDeBaisse=25

#attenteInitiale=1
#dureeDeBaisse=60
#nombreDeBaisse=10

frequenceDeBaisse="$(( $dureeDeBaisse / $nombreDeBaisse ))"
valeurDeBaisse="$(( $currentVolume / $nombreDeBaisse ))"

echo "$currentVolume";exit 0;
sleep $attenteInitiale
while [ $currentVolume -gt 0 ];
do
	currentVolume="$(( $currentVolume - $valeurDeBaisse ))"
	amixer -q set Master ${currentVolume}%
	echo "baisse a $currentVolume. Prochaine baisse dans $frequenceDeBaisse secondes"
	sleep $frequenceDeBaisse
	if [ $currentVolume -lt "$(getCurrentVolume)" ]; then
		echo "Le volume a été augmenté manuellement."
		exit 1
	fi
done
