server {
	listen 5650;	
	location /hello {
		content_by_lua_file ../../lua-ngx-modules/hello-nginx-module/hello_echo.lua;  # path is where nginx exe is
	}

	location /sum {
		content_by_lua_file ../../lua-ngx-modules/sum-nginx-module/sum.lua;
	}

	location /testmod {
		params_op;
	}

	location /testmod2ab {
		params_op_v2;
	}

}
