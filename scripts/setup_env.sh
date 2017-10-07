#!/bin/bash
Scr_Lo=$(dirname $0)						# scripts location
RES_Lo=$(dirname "${Scr_Lo}/../resource")		# resource location


declare -A RES_URLs  # resource's URLs
RES_URLs=(
['luajit']='http://luajit.org/download/LuaJIT-2.0.5.tar.gz' 
['ndk']='https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz'
)


source ${Scr_Lo}/common.sh

dl()
{
	pr_key_value "RES_URLs" "Repo" "DL_Address"
}

dl

