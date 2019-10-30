#! /bin/bash


ROUTES=/home/user/Escritorio/EsplacNeXt/server/routes

showFiles() {

	ROUTE=$ROUTES/$opt
	OUTFILE=/home/user/Escritorio/EsplacNeXt/server/controllers/$opt
	opts=$(ls $ROUTE)
	length=$(echo $opts | wc -w)
	echo "$opt - Tria un fitxer: (1-$length o * per documentar-los tots)"
	for  (( i=1; i<=$length; i++))  do
		opt=$(echo $opts | cut -d" " -f$i)
		echo "$i - $opt";
		
	done;
	read opt;
	if [[ "$opt" == "*" ]]; then
		
		back=$OUTFILE
		for i in `seq 1 $length` 
		do
		        opt=$(echo $opts | cut -d" " -f$i);
			FILE=$ROUTE/$opt
			OUTFILE=$back/$( echo $opt | cut -d"." -f1 ).controller.js
			[ ! -f "$OUTFILE" ] && continue;
			echo "Generating Templates for $OUTFILE:"
			echo "";
			findGroup;
			documentate;
			
		done
		exit
	
	elif (("$opt" < "1" || "$opt" > "$length")); then
		clear;
		echo ERROR: el valor ha de estar entre 1 i $length;
		showFiles;
	else
		echo " "; 
		opt=$(echo $opts | cut -d" " -f$opt);
		FILE=$ROUTE/$opt

		OUTFILE=$OUTFILE/$( echo $opt | cut -d"." -f1 ).controller.js
		
	fi

}


showRoutes() {
	opts=$(ls $ROUTES)
	length=$(echo $opts | wc -w)
	echo "Tria el directori: (1-$length)"
	for  (( i=1; i<=$length; i++))  do
		opt=$(echo $opts | cut -d" " -f$i)
		echo "$i - $opt";
		
	done;
	read opt;
	if (("$opt" < "1" || "$opt" > "$length")); then
		clear;
		echo ERROR: el valor ha de estar entre 1 i $length;
		showRoutes;
	else
		echo " "; 
		opt=$(echo $opts | cut -d" " -f$opt);
		showFiles;
	fi
}


findGroup() {
	if [ ! -f "$OUTFILE" ]; then exit; fi;
	group=$(cat $OUTFILE | grep "@apiGroup" -m1 | tr " " "\n" | tail -n 1)
	if [[ "$group" == "" ]]; then
		group=$(echo $OUTFILE | tr "/" "\n" | tail -n 1 | cut -d"." -f1)
		group=${group^}
	fi
}

documentate() {
	PREFIX=$(cat $FILE | grep  "Controller()" | cut -d" " -f2)
	length=$(grep "router\." $FILE | wc -l)
	for (( i=1; i<=$length; i++)) do 
		b=$(grep -n "router\." $FILE -m $i | tail -n1 | cut -d":" -f1)
		e=$(grep -n "router\." $FILE -m $((i+1)) | tail -n1 | cut -d":" -f1)
		if [[ $e -eq $b ]]; then
			e=$(wc -l $FILE | cut -d" " -f1)
					
		fi
	
		func=$(cat $FILE| head -n $((e-1)) | tail -n $((e-b)) )
		verb=$(echo $func | tr ".(" "\n" |  head -n2 | tail -n1 )
		endpoint=$(echo $func | cut -d \' -f2)
		name=$(echo $func | tr " " "\n" | grep "$PREFIX\." | cut -d"." -f2)
		
		params=$( echo $endpoint | tr "/" "\n" | grep ":" )
		line=$( cat $OUTFILE |  grep -n "^[ \t]*$name(.*{" | cut -d":" -f1 )
		if [[ "$name" == "" || "$line" == "" ]]; then
			continue;
		fi

		if ( cat $OUTFILE | grep "^[ \t]*$name(.*{" -B 4 |  grep "\*/ *$" > /dev/null ); then
			echo "[+]  Documentation Found: 	$name" ;
		else
		
			echo "[*]  Adding template documentation for $name() in line $line"
			fillparams=""
			for param in `echo $params | tr ":" " "` 
			do 
				fillparams="$fillparams\n * @apiParam {Object} $param template definition, must change it"
			done;
			template="$((line))i\/**\n * @api {$verb} $endpoint $name\n * @apiName $name\n * @apiGroup $group\n * @apiDescription template definition, must change it "$fillparams"\n*/\n"
			sed -i "$template" $OUTFILE
			echo "";
		fi
	done;
}

showRoutes;
findGroup;
documentate;
