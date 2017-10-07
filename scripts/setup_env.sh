#!/bin/bash

Scr_Lo=$(dirname $0)							# scripts location
RES_Lo="${Scr_Lo}/../resource"					# resource location


declare -A RES_URLs  # resource's URLs
RES_URLs=(
['luajit']='http://luajit.org/download/LuaJIT-2.0.5.tar.gz' 
['ndk']='https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz'
['ngx_lua']='https://github.com/openresty/lua-nginx-module/archive/v0.10.11rc2.tar.gz'
['ngx']='https://nginx.org/download/nginx-1.13.5.tar.gz'
)

declare -A RES_FILEs;



source ${Scr_Lo}/common.sh

dl()
{
	for k in ${!RES_URLs[@]}
	do
		val=${RES_URLs[$k]};
		RES_FILEs[${k}]=${k}-${val##*/};

		if [ ! -f "${RES_Lo}/${RES_FILEs[${k}]}" ]; then
			pr_info "dl $k from ${RES_URLs[${k}]}:" warn verbose
			wget -O "${RES_Lo}/${RES_FILEs[${k}]}" ${RES_URLs[${k}]}
		fi
	done
}




main_process()
{
	dl
}


main_process;
