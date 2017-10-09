#!/bin/bash
Scr_Lo=$(dirname $0);
source "${Scr_Lo}/common.sh";
where=`cd "${Scr_Lo}/../work/nginx"; pwd`;


ngx_test_and_run()
{
	pr_info "test conf[${where}/../../ngx_confs/ngx.conf]" warn verbose;
	${where}/sbin/nginx -t -c ${where}/../../ngx_confs/ngx.conf;  # `-c`'s path is to the nginx exe

	if [ $? -eq 0 ]; then
		pr_info "ready to run nginx..." info verbose
		${where}/sbin/nginx -c ${where}/../../ngx_confs/ngx.conf;

		ps -ef | grep "nginx" | grep --color=auto "fatiao";
	else
		pr_info "test configuration error!."  error verbose
	fi
}

ngx_kill()
{
	${where}/sbin/nginx -s quit
} 

ngx_reload()
{
	${where}/sbin/nginx -s reload
}

usage()
{
	echo "$0 [run | kill | reload]"
}

case $1 in
	run )
		ngx_test_and_run;
		;;
	kill )
		ngx_kill;
		;;
	reload )
		ngx_reload;
		;;
	* )
		usage;
		;;
esac
