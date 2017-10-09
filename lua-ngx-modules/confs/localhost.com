server {
	listen 5650;	
	location /hello {
		content_by_lua_file ../../lua-ngx-modules/hello-nginx-module/hello_echo.lua;  # path is where nginx exe is
	}
}
