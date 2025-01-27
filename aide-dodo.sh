#!/bin/bash

getCurrentVolume () { amixer get Master|sed -nE 's/(Front.*Left.*|Mono.*)\[([0-9]*)%\].*/\2/p';}
currentVolume="$(getCurrentVolume)"


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Add description of the script functions here."
   echo
echo "Syntax: scriptTemplate [-h|d|D|p]"
   echo "options:"
   echo "h     Print this Help."
   echo "a X   Set le delai avant de commencer à X minutes"
   echo "d X   Set la durée de diminution à X minutes"
   echo "p X   Set le nombre de diminutions"
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
# Get the options
while getopts ":hd:a:p:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      a)
	 attenteInitiale="$(( $OPTARG * 60 ))";;
      p) 
	 nombreDeBaisse=$OPTARG;;
      d)
	 dureeDeBaisse="$(( $OPTARG * 60 ))";;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
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
	echo "baisse a $currentVolume. Prochaine baisse dans $frequenceDeBaisse secondes"
	sleep $frequenceDeBaisse
	if [ $currentVolume -lt "$(getCurrentVolume)" ]; then
		echo "Le volume a été augmenté manuellement."
		exit 1
	fi
done
