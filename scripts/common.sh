#!/bin/bash

# usage: pr_info <string> <info | warn | error> [verbose]
pr_info()
{
    type=$2;
	verbose=$3;
    if [ "${type}" = "" ]; then
        type="info";
    fi
	
	prefix="\033[3";
	suffix="\033[0m"; #system
	infostr="";

    case ${type} in
        info )
			prefix+="2m"; #green
            ;;
        warn )
			prefix+="3m"; #yellow
            ;;
        error )
			prefix+="1m"; #red
            ;;
		* )
			echo $1
			return;
			;;
    esac

	if [ "$verbose" != "" ]; then
		case ${type} in
			info )
				infostr="[ info ] ";
			;;
			warn )
				infostr="[ warn ] ";
			;;
			error )
				infostr="[ error] ";
			;;
		esac
	fi
	
	echo -e "${prefix}${infostr}${1}${suffix}"	
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

mkdir_if_not_exist()
{
	if [ ! -d ${1} ]; then
		mkdir -p ${1};
	fi
}

#
# unzip $1 to the same folder.
#
unzip_file()
{
	file_path=$1;
	dir=$(dirname ${file_path});
	file_fullname=${file_path##*/};

	file_prefix=${file_fullname%%.*};
	file_suffix=${file_fullname#*.};
	
	# echo ${dir};
	# echo ${file_fullname};
	
	# echo ${file_prefix};
	# echo ${file_suffix};
	if [ -d ${dir}/${file_prefix} ]; then
		pr_info "${dir}/${file_prefix}: target exist! do not unzip." warn verbose;
		return -1;
	else
		mkdir -p ${dir}/${file_prefix};
	fi

	case ${file_suffix} in
		"zip" )
			uzcmd="unzip ${file_path} -d ${dir}/${file_prefix}";
			;;
		"tar.gz" )
			uzcmd="tar zxvf ${file_path} -C ${dir}/${file_prefix}";
			;;
		* )
			pr_info "unsupported format: ${file_suffix}." error verbose;
			exit -1;
			;;
	esac
	
	eval ${uzcmd}
}
