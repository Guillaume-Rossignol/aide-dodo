#!/bin/bash

getCurrentVolume () { amixer get Master|sed -nE 's/(Front.*Left.*|Mono.*)\[([0-9]*)%\].*/\2/p';}
currentVolume="$(getCurrentVolume)"


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Ce script bash réduit progressivement le volume pour aider à"
   echo "s'endormir devant une vidéo."
   echo "Par défaut, il attendra 10 minutes avant de lancer la baisse"
   echo "puis diminuera progressivement le volume pendant 25 minutes."
   echo "Ça permet de coller à une durée d'épisode de 40 minutes."
   echo
echo "Syntax: aide-dodo [-h|w|d|s] [--help|waiting|delay|steps]"
   echo "options:"
   echo "-h|--help       Print this Help."
   echo "-w|--waiting X  Set le delai avant de commencer à X minutes"
   echo "-d|--delay X    Set la durée de diminution à X minutes"
   echo "-s|--steps X    Set le nombre de diminutions"
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

attenteInitiale=600 #On attend dix minutes avant de commencer à baisser le son
dureeDeBaisse=1500  #On baisse le volume pendant 25 minutes
nombreDeBaisse=25

############################################################
# Process the input options. Add options as needed.        #
############################################################
TEMP=$(getopt -o 'hw:d:s:' --long 'help,waiting:,delay:,steps:' -n 'aide-dodo' -- "$@")

# getopt a planté
if [ $? -ne 0 ]; then
	echo 'Erreur dans la gestion des options' >&2
	Help
	exit 1
fi

eval set -- "$TEMP"
unset TEMP

while true; do
   case "$1" in
      '-h'|'--help') # display Help
         Help
         exit 0
	;;
      '-w'|'--waiting')
	 attenteInitiale="$(( $2 * 60 ))"
	 shift 2
	 continue
	;;
      '-s'|'--steps') 
	 nombreDeBaisse=$2
	 shift 2
	 continue
	;;
      '-d'|'--delay')
	 dureeDeBaisse="$(( $2 * 60 ))"
	 shift 2
	 continue
	;;
      '--')
         shift
	 break
	;;
      *)
	 echo "internal error!" >&2
         exit 1
	;;
   esac
done

frequenceDeBaisse="$(( $dureeDeBaisse / $nombreDeBaisse ))"
valeurDeBaisse="$(( $currentVolume / $nombreDeBaisse ))"
if [ $valeurDeBaisse -lt 1 ]; then
	valeurDeBaisse=1
fi
echo "Valeur de baisse $valeurDeBaisse"
sleep $attenteInitiale
while [ $currentVolume -gt 0 ];
do
	currentVolume="$(( $currentVolume - $valeurDeBaisse ))"
	amixer -q set Master ${currentVolume}%
	if [ $currentVolume -eq 0 ]; then
		echo "Volume à 0"
		echo "Bonne nuit !"
		break
	fi
	echo "baisse a $currentVolume. Prochaine baisse dans $frequenceDeBaisse secondes"
	sleep $frequenceDeBaisse
	if [ $currentVolume -lt "$(getCurrentVolume)" ]; then
		echo "Le volume a été augmenté manuellement."
		exit 1
	fi
done
