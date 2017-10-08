#!/bin/bash

Scr_Lo=$(dirname $0)							# scripts location
RES_Lo="${Scr_Lo}/../resource"					# resource location
WRK_Lo="${Scr_Lo}/../work"						# working directory

declare -A RES_URLs  # resource's URLs
RES_URLs=(
['luajit']='http://luajit.org/download/LuaJIT-2.0.5.tar.gz' 
['ndk']='https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz'
['ngx_lua']='https://github.com/openresty/lua-nginx-module/archive/v0.10.11rc2.tar.gz'
['ngx']='https://nginx.org/download/nginx-1.13.5.tar.gz'
)

declare -A RES_PRE_URLs
RES_PRE_URLs=(
['PCRE']='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz'
['gzip']='http://www.gzip.org/gz124src.zip'
['zlib']='https://zlib.net/zlib-1.2.11.tar.gz'
)

declare -A RES_FILEs;
declare -A REP_DIRs;
LuaJit_Path="";
Ngnix_Path="";
Ngx_Build_Script="";

source ${Scr_Lo}/common.sh



pre_work()
{
	if [ ! -d ${RES_Lo} ]; then
		mkdir -p ${RES_Lo};
	fi
	
	if [ ! -d ${WRK_Lo} ]; then
		mkdir -p ${WRK_Lo};
	fi

	# prerequire
	
	
}

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

unzip()
{
	dirabs=`cd ${RES_Lo}; pwd`;
	for k in ${!RES_FILEs[@]}; do
		if [ ! -d "${dirabs}/${k}" ]; then
			mkdir -p "${dirabs}/${k}"
		fi
		if [ ! -f "${dirabs}/${k}/.extract.tag" ]; then
			tar -zxvf "${RES_Lo}/${RES_FILEs[${k}]}" -C "${dirabs}/${k}" > /dev/null
			touch "${dirabs}/${k}/.extract.tag"
		fi
		# echo ${dirabs}/${k}
		# ls ${dirabs}/${k}
		p=`ls ${dirabs}/${k}`		

		pr_info "${k} extracted to: ${dirabs}/${k}/${p}" info verbose
		REP_DIRs[${k}]=${dirabs}/${k}/${p}
		# echo ${REP_DIRs[$k]};
	done
}

build_luajit()
{
	curr=`pwd`;
	build_tag=`cd ${WRK_Lo}; pwd`;
	build_tag+="/.luajit_build.tag";
	
	log_file=`cd ${WRK_Lo}; pwd`
	log_file+="/luajit.build_log"

	if [ ! -d "${WRK_Lo}/luajit" ]; then
		mkdir -p "${WRK_Lo}/luajit"
	fi
	LuaJit_Path=`cd "${WRK_Lo}/luajit"; pwd`

	if [ -f ${build_tag} ]; then
		return;
	fi

	cd ${REP_DIRs['luajit']};
	echo "======= make luajit ===============" > ${log_file}
	pr_info "build luajit: compiling..." warn verbose
	make PREFIX="${LuaJit_Path}" >> ${log_file}
	ret=$?
	if [ $ret -eq 0 ]; then
		pr_info "  compile success." info verbose
	else
		pr_info "  compile failed: ${ret}." error verbose
		return $ret;
	fi

	echo "======= make install luajit =======" >> ${log_file}
	pr_info "build luajit: installing..." warn verbose

	make install PREFIX="${LuaJit_Path}" >> ${log_file}
	ret=$?	

    if [ $ret -eq 0 ]; then
        pr_info "  install success, installed to [ ${LuaJit_Path} ]." info verbose
    else
        pr_info "  install failed: $ret." error verbose
        return $ret;
    fi  

	touch ${build_tag};

	cd $curr;
	return 0;
}

build_ngx()
{
	curr=`pwd`;
	Ngnix_Path=`cd ${WRK_Lo}; pwd`;
	Ngnix_Path+="/ngnix";
	
	ngx_log=`cd ${WRK_Lo}; pwd`;
	ngx_log+="/ngx.build_log"

	build_tag=`cd ${WRK_Lo}; pwd`;
	build_tag+="/.ngx_build.tag"	

	if [ ! -d $Ngnix_Path ]; then
		mkdir -p $Ngnix_Path;
	fi
	if [ -f ${build_tag} ]; then
		return;
	fi


	lj_lib=`cd ${LuaJit_Path}/lib; pwd`;
	lj_inc=`cd ${LuaJit_Path}/include; ls`;
	lj_inc=`cd ${LuaJit_Path}/include/${lj_inc}; pwd`;
	
	export LUAJIT_LIB=${lj_lib};
	export LUAJIT_INC=${lj_inc};
	
	cd ${REP_DIRs['ngx']};
	pwd;
	Ngx_Build_Script="";
	run="./configure --prefix=${Ngnix_Path} "
	run+="--with-ld-opt=\"-Wl,-rpath,${lj_lib}\" "
	run+="--add-module=${REP_DIRs['ndk']} "
	run+="--add-module=${REP_DIRs['ngx_lua']} "
	
	run=`echo -e ${run}`;
	echo $run;
	Ngx_Build_Script+="$run";
	
	echo "======== configure ============" > ${ngx_log}
	pr_info "build ngx: configuring..." warn verbose
	eval "$run >> ${ngx_log}"
	ret=$?
    if [ $ret -eq 0 ]; then
        pr_info "  configure success." info verbose
    else
        pr_info "  configure failed: ${ret}." error verbose
        return $ret;
    fi	

	
	echo "======== make -j2 =============" >> ${ngx_log}
	run="make -j2"
	Ngx_Build_Script+=";$run";	
	
	pr_info "build ngx: compiling..." warn verbose
	eval "$run >> ${ngx_log}"
	ret=$?;	
    if [ $ret -eq 0 ]; then
        pr_info "  compile success." info verbose
    else
        pr_info "  compile failed: ${ret}." error verbose
        return $ret;
    fi


	echo "======== make install =========" >> ${ngx_log}
	run="make install"
 	Ngx_Build_Script+=";$run";

	pr_info "build ngx: installing..." warn verbose
	eval "$run >> ${ngx_log}"

	ret=$?;
    if [ $ret -eq 0 ]; then
        pr_info "  install success." info verbose
    else
        pr_info "  install failed: ${ret}." error verbose
        return $ret;
    fi

	
	touch ${build_tag}

	cd $curr;
	return 0;
}

digest()
{
	wrk=`cd ${WRK_Lo}; pwd`
	pr_info "++++++++++++++ Summary for Ngx Env +++++++++++++++++" info
	pr_info "+ working_directory | ${wrk} " info
	pr_info "+ ngx_dir           | ${Ngnix_Path}" info
	pr_info "+ ngx_build_script  " info
	pr_info "${Ngx_Build_Script} " info
}


main_process()
{
	pre_work;
	dl;
	unzip;

	build_luajit;
	if [ $? -eq 0 ]; then
		build_ngx;
		if [ $? -eq 0 ]; then
			digest;
		fi
	fi
}


main_process;
