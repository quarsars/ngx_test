#!/bin/bash

f1()
{
	yh="yjg";

	declare -A aa;
	aa['ab']='woku';


	declare -A a2;
	a2=(
			['key1']='val1',
			["${yh}"]="val2"
	   );

	echo ${!a2[*]};
}


f2()
{
	o1=$(pwd);
	o2=$(dirname $0);
	o3=`pwd`;
	o4=`dirname ./resource/abv`

	echo $o1;
	echo $o2;
	echo $o3;
	echo $o4;
}

function sf
{
	name=$1
	str='${!';
	str+=${name}
	str+='[@]}'
	eval "echo $str"
}

declare -A conf
conf[pou]=789
conf[mail]="ab\npo"
conf[doo]=456

sf "conf"

echo ${!conf[@]}
