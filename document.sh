#! /bin/bash

ROUTES=/home/user/Escritorio/EsplacNeXt/server/controllers
SERVERJS=/home/user/Escritorio/EsplacNeXt/server.js
ROUTEFLDR=/home/user/Escritorio/EsplacNeXt/server/routes
rfileArray=()
lineArray=()
funcArray=()
fldrArray=()
ffileArray=()
modifArray=()
N=0
ifmodified() {
	mod=$(stat $ROUTES/$fldr/$rfile | grep -i "modif" | cut -d' ' -f2,3)
	acc=$(stat $ROUTES/$fldr/$rfile | grep -i "acces" | grep -v -i "uid" | cut -d' ' -f2,3) 
	if [[ "$mod" > "$acc" || "$mod" == "$acc" ]]; then 	
		modifArray[$N]="S"
	fi
}

prinfo() {
	S=0;
	try=$(grep "\.$(echo $func | cut -d'(' -f1) *$" $ffile -B3 -A1 | grep "\.$(echo $func | cut -d'(' -f1)")
	try2=$(grep "\.$(echo $func | cut -d'(' -f1) *$" $ffile -B3 -A1 | grep "passport.auth")
	endp=$(grep "\.$(echo $func | cut -d'(' -f1) *$" $ffile -B3 -A1 | grep "'.*/.*'")
	
	term=$(grep "$(echo $ffile | rev | cut -d'/' -f1,2,3 | rev)" $SERVERJS | cut -d' ' -f2)
	fullendp=https://sandbox.esplac.cat$(grep ", *$term.*);" $SERVERJS | tr "\"'" "\n" | grep "/")$(echo $endp | tr "\"'" "\n" | grep "/")
	S=${#try}
	if [ "${#try2}" -gt $S ]; then
		S=${#try2};
	fi
	if [ "${#endp}" -gt $S ]; then
		S=${#endp}
	fi
	
	pint=$(python -c "print('+-'+'='*$S+'-+')")
			
	info=$(python -c "print('$info'+' '*($S - ${#info}))")
	endp=$(python -c "print(\"$endp\"+' '*($S - ${#endp}))")
	try2=$(python -c "print(\"$try2\"+' '*($S - ${#try2}))")
	try=$(python -c "print(\"$try\"+' '*($S - ${#try}))")
	pad=''
	echo -e "\t\t\e[33m$pint\e[m";
	echo -e "\t\t\e[33m|\e[m $info \e[33m|\e[m" 
	echo -e "\t\t\e[33m|\e[m $endp \e[33m|\e[m"
	echo -e "\t\t\e[33m|\e[m $try2 \e[33m|\e[m"
	echo -e "\t\t\e[33m|\e[m $try \e[33m|\e[m"
	echo -e "\t\t\e[33m$pint\e[m";
	echo -e "\t\t\e[33m$(python -c "print(' '*(($S/2)+1)+'||')")\e[m"
	echo -e "\t\t\e[33m$(python -c "print(' '*(($S/2)+1)+'\\/')")\e[m"; echo "";
	echo -e "\t\t\e[1m\e[33m$(python -c "print(' '*(($S/2)+1-(${#fullendp}/2))+'$fullendp')")\e[m";
	
}
documentate() {
			N=$1
			clear;
			echo -e "\e[32mPress n to go to next function"
			echo -e "press p to go to previous function\e[m"
			echo -e "\e[92mPress c to documentate current function\e[m "

			rfile=${rfileArray[$N]}
			fldr=${fldrArray[$N]}
			func=${funcArray[$N]}
			ffile=${ffileArray[$N]}
			line=${lineArray[$N]}
			size=${#func}
			echo ""; 

			info=$(grep "\.$(echo $func | cut -d'(' -f1) *$" $ffile -B3 -A1 | grep "router")
			verb=$(echo $info | cut -d'.' -f2 | cut -d'(' -f1)
			edited=${modifArray[$N]}
			if [[ "$edited" == "S" ]]; then
				edited="MODIFICAT"
				linesecure=1
			else
				edited=""
				linesecure=$(tail --line=+$line $ROUTES/$fldr/$rfile | grep "Descrip.*template defi.*must change it" -m1 -n | cut -d":" -f1);				
			fi
			pint=$(python -c "print('#'*($size+4))")
			echo -e "\e[31menpoint $(( N + 1)) de ${#funcArray[@]}\e[m"; echo ""; echo "";
			echo -en "\e[1m[+] ${fldr^} \e[m"; echo -e  "\e[2m($rfile)\e[m:"; echo "";
			echo -e "	\e[33m$pint\e[m"; 
			echo -e " \e[95m${verb^^}\e[m\t\e[33m#\e[m\e[96m$func  \e[m\e[33m#\e[m\t\e[1;5;91m$edited\e[m"; 
			echo -e "	\e[33m$pint\e[m"; 
			echo " "; echo -e "\e[1m[+] Route:\e[m"; echo " ";

			prinfo
			echo "";
			echo -e "\e[1m[+] Possibles parametres a afegir:\e[m "; echo ""; 
			
			if [ "$verb" != "get" ]; then
			echo "@apiParam {Object} body Objecte que conté informació requerida per el controlador";
				
			match=$(tail --line=+$line $ROUTES/$fldr/$rfile | grep -n "(req, res.*).*{" | cut -d":" -f1 ) #| head -n2 | tail -n1 )
			
			if [[ "$(echo $match | tr " " "\n" | wc -l)" -lt "2"  ]]; then
				match=$(tail --line=+$line $ROUTES/$fldr/$rfile | wc -l)
			else
				match=$(echo $match | tr " " "\n" | head -n2 | tail -n1)
				
			fi	
			tail --line=+$((line + linesecure -1 ))  $ROUTES/$fldr/$rfile | head -n$match |  grep -e "body\." | tr ". " "\n" | grep -E "^body$" -A1 | grep -v body | grep -v "\-\-" | xargs -i echo body.{} | tr ",){[)]};" "@" | cut -d"@" -f1 | sort -u | xargs -i echo "@apiParam {Object} {}"
			fi
			echo ""; echo "";


			
			key="D"
			while [[ "$key" != "c" && "$key" != "p" && "$key" != "n" ]]; do
				read -n1 -r -s key; echo "";
			done;
						
			if [[ "$key" == "c" ]]; then
				vim "+call cursor($((line + linesecure - 1)), 19)" $ROUTES/$fldr/$rfile ;
				ifmodified
			fi


			if [[ "$key" == "p" ]]; then
				if [ "$N" -gt 0 ]; then
					
					N=$(($N - 1))	
				fi			
			fi


			if [[ "$key" == "n" ]]; then
				if [ "${#rfileArray[@]}" -gt $((N+1)) ]; then
					
					N=$(($N + 1))	
				fi	
			fi

	


}

for fldr in $(ls $ROUTES); do
	for rfile in $(ls $ROUTES/$fldr); do 

		for line in $(grep "Descrip.*template defi.*must change it" $ROUTES/$fldr/$rfile -n | cut -d":" -f1); do
		
		ffile=$ROUTEFLDR/$fldr/$(echo $rfile | cut -d"." -f1).rou*		
		
		func=$(tail --line=+$line $ROUTES/$fldr/$rfile | grep -m1 -E "\s*.+\(.*\)")
			rfileArray+=("$rfile")
			lineArray+=($line)
			funcArray+=("$func")
			ffileArray+=("$ffile")
			fldrArray+=("$fldr")
			modifArray+=("N")
		done
	done
done
while [[ "1"=="1" ]]; do
	documentate $N
done

