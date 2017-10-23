#!/bin/bash

Scr_Lo=$(dirname $0)							# scripts location
Scr_Lo=$(cd $dirname; pwd -P)					
source ${Scr_Lo}/common.sh

RES_Lo="${Scr_Lo}/../resource"					# resource location
RES_PRE_Lo="${Scr_Lo}/../deps"
Build_Lo="${Scr_Lo}/../build"					# working directory

declare -A RES_URLs  # resource's URLs
RES_URLs=(
['luajit']='http://luajit.org/download/LuaJIT-2.0.5.tar.gz' 
['ndk']='https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz'
['ngx_lua']='https://github.com/openresty/lua-nginx-module/archive/v0.10.11rc2.tar.gz'
['ngx']='https://nginx.org/download/nginx-1.13.5.tar.gz'
)
declare -A RES_FILEs;

declare -A RES_PRE_URLs
RES_PRE_URLs=(
['PCRE']='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz'
['gzip']='http://www.gzip.org/gz124src.zip'
['zlib']='https://zlib.net/zlib-1.2.11.tar.gz'
)
declare -A RES_PRE_FILEs;


declare -A REP_DIRs;
LuaJit_Path="";
Ngnix_Path="";
Ngx_Build_Script="";


# preparing works(such as mkdir/set some path)
pre_work()
{
	mkdir_if_not_exist ${RES_PRE_Lo}
	mkdir_if_not_exist ${RES_Lo}
	mkdir_if_not_exist ${Build_Lo}

	# setup pre-depends file names in RES_PRE_FILEs
	for k in ${!RES_PRE_URLs[@]}
	do
		val=${RES_PRE_URLs[$k]};
		RES_PRE_FILEs[${k}]=${k}-${val##*/};
		echo $RES_PRE_FILEs[${k}];
	done


	# setup nginx-depends file names in RES_FILEs
	for k in ${!RES_URLs[@]}
	do
		val=${RES_URLs[$k]};
		RES_FILEs[${k}]=${k}-${val##*/};
		echo $RES_FILEs[${k}];
	done
}


# downloading
dl_res_if_not_exist()
{
	for k in ${!RES_PRE_URLs[@]}
	do
		if [ ! -f "${RES_PRE_Lo}/${RES_PRE_FILEs[${k}]}" ]; then
			pr_info "dl $k from ${RES_PRE_URLs[${k}]}:" warn verbose;
			wget -O "${RES_PRE_Lo}/${RES_PRE_FILEs[${k}]}" ${RES_PRE_URLs[${k}]}
			if [ $? -eq 0 ]; then
				pr_info "dl failed: ${RES_PRE_FILEs[${k}]}" error verbose;
				exit -1;
			fi
		fi
	done

	for k in ${!RES_URLs[@]}
	do
		if [ ! -f "${RES_Lo}/${RES_FILEs[${k}]}" ]; then
			pr_info "dl $k from ${RES_URLs[${k}]}:" warn verbose
			wget -O "${RES_Lo}/${RES_FILEs[${k}]}" ${RES_URLs[${k}]}
			if [ $? -eq 0 ]; then
				pr_info "dl failed: ${RES_FILEs[${k}]}" error verbose;
				exit -1; 
			fi
		fi
	done
}

# unzip the res
unzip_res()
{

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

# 
# build_ngx force extra_module_path
build_ngx() 
{
	curr=`pwd`;
	Ngnix_Path=`cd ${WRK_Lo}; pwd`;
	Ngnix_Path+="/nginx";
	
	ngx_log=`cd ${WRK_Lo}; pwd`;
	ngx_log+="/ngx.build_log"

	build_tag=`cd ${WRK_Lo}; pwd`;
	build_tag+="/.ngx_build.tag"	

	if [ ! -d $Ngnix_Path ]; then
		mkdir -p $Ngnix_Path;
	fi
    
    if [ "$1" = "force" ]; then
        rm ${build_tag} 2>/dev/null;
    fi

	if [ -f ${build_tag} ]; then
		return;
	fi

    extra=$2
    if [ "$extra" != "" ]; then
        if [ "${extra:0:1}" != '/' ]; then  #convert to abs path
            extra=`cd "${curr}/${extra}"; pwd`;
        fi
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
    if [ "${extra}" != "" ];then
        run+="--add-module=${extra} ";
    fi

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
    
    if [ "${extra}" != "" ];then
        echo "======== make modules ============" >> ${ngx_log}
        make modules >> ${ngx_log};
        sos=`ls objs/*.so`;
        pr_info "so: ${sos}" info verbose
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
	output="++++++++++++++ Summary for Ngx Env +++++++++++++++++";
	pr_info "${output}" info
	echo "$output" > ./Summary
	
	output="+ working_directory | ${wrk} "
	pr_info "${output}" info
	echo "$output" >> ./Summary
	
	output="+ ngx_dir           | ${Ngnix_Path}"
	pr_info "${output}" info
	echo "$output" >> ./Summary
	
	output="+ ngx_build_script  | "
	pr_info "${output}" info
	echo "$output" >> ./Summary
	
	output="${Ngx_Build_Script} "
	pr_info "${output}" info
	echo "$output" >> ./Summary
}

