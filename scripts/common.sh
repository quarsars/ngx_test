#!/bin/bash

# usage: pr_info <string> <info | warn | error>
pr_info()
{
    type=$2
    if [ "${type}" = "" ]; then
        type="info"
    fi

    case ${type} in
        info )
            echo -e "\033[32m[ info ] $1\033[0m"
            ;;
        warn )
            echo -e "\033[33m[ warn ] $1\033[0m"
            ;;
        error )
            echo -e "\033[31m[ error] $1\033[0m"
            ;;
		* )
			echo $1
			;;
    esac
}


# usage: pr_key_value <name_of_associate_array> 
pr_key_value()
{
	name=$1;
	ktitle=$2;
	vtitle=$3;
	level=$4;

	cmd_str='${!';
	cmd_str+=$name;
	cmd_str+='[@]}';
	eval "keys=${cmd_str}"
	
	cmd_str='${';
	cmd_str+=$name;
	cmd_str+="[@]}";
	eval "values=${cmd_str}";
	
	
	karr=($keys);
	varr=($values);
	num=${#karr[@]};	
	
	lk=${#ktitle};
	lv=${#vtitle};

	for((i=0; i<num; i++))
	{
		key=${karr[$i]};
		if [ ${#key} -gt $lk ]; then
			lk=${#key}
		fi
		val=${varr[$i]};
		if [ ${#val} -gt $lv ]; then
			lv=${#val}
		fi
	}
	
	if [ "$level" != 'info' ] && [ "$level" != 'warn' ] && [ "$level" != 'error' ];then
		level='info';
	fi

	str=`printf "| %-${lk}s | %-${lv}s |" $ktitle $vtitle`
	pr_info "$str" $level	

	for((i=0; i<num; i++))
	{
		key=${karr[$i]};
		val=${varr[$i]};

		str=`printf "| %-${lk}s | %-${lv}s |" $key $val`
		pr_info "$str" $level
	}
}
