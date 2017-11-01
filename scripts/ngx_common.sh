#!/bin/bash
log_avgtime()
{
type=$1;
dir=$2;
cmd=;
case ${type} in
 "all" )
   cmd="cat"
	;;
 "tail" )
   cmd="tail -n 100"
	;;
 "head" )
   cmd="head -n 100"
	;;
 * )
   echo "log_avgtime [all | tail]";
   return;
	;;
 esac
curr=`pwd`
cd $dir
${cmd} logs/http_error.log | grep "download cost" | awk '{print $18}' | sed 's/,//g'| awk 'BEGIN{a=0} {a=a+$1} END{print "dwld_time(ms)",a/NR, NR}'
${cmd} logs/http_error.log | grep "process" | sed s/,//g | awk 'BEGIN{a=0} {a+=$21;} END{print "proc_time(ms)",a/NR, NR}'
${cmd} logs/http_error.log | grep "upload cost" | awk '{print $16}' | sed 's/,//g' | awk 'BEGIN{a=0} {a=a+$1} END{print "upld_time(ms)",a/NR, NR}'
cd $curr
}

mngm_reload()
{
 dir=$1;
 dir=$(cd ${dir}; pwd -P);
 
 cd $dir;
 if [ -f sbin/nginx_ai ]; then
   sbin/nginx_ai -p $dir -t;
   sbin/nginx_ai -p $dir -s reload;
 else
   echo "not a nginx directory."
 fi
}
