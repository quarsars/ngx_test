#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>

#include <string.h>
#include <stdio.h>

#define BufSize 256
static char *hello_string = "Hello World!\n";
static char gBuf[BufSize];

static char *ngx_http_hello_world(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
static char *ngx_http_params_opr(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
static char *ngx_http_params_opr_v2(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);

static ngx_command_t  ngx_http_hello_world_commands[] = {
	{
		ngx_string("print_hello_world"),
		NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS,
		ngx_http_hello_world,
		0,
		0,
		NULL
	},
    {
        ngx_string("params_op"),
        NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS,
        ngx_http_params_opr,
        0, 
        0,
        NULL
    },
	{
		ngx_string("params_op_v2"),
		NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS,
		ngx_http_params_opr_v2,
		0,
		0,
		NULL
	},
	ngx_null_command
};

static ngx_http_module_t  ngx_http_hello_world_module_ctx = {
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
};

ngx_module_t sum_ngx_module = {   // var's name must be the same as module's name in config
	NGX_MODULE_V1,
	&ngx_http_hello_world_module_ctx,
	ngx_http_hello_world_commands,
	NGX_HTTP_MODULE,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NGX_MODULE_V1_PADDING
};

static ngx_int_t ngx_http_hello_world_handler(ngx_http_request_t *r)
{
	u_char *ngx_hello_world = (u_char *)hello_string;
	size_t sz = strlen((const char *)ngx_hello_world);

	r->headers_out.content_type.len = sizeof("text/html") - 1;
	r->headers_out.content_type.data = (u_char *) "text/html";
	r->headers_out.status = NGX_HTTP_OK;
	r->headers_out.content_length_n = sz;
	ngx_http_send_header(r);

	ngx_buf_t    *b;
	ngx_chain_t   *out;

	b = ngx_calloc_buf(r->pool);

	out = ngx_alloc_chain_link(r->pool);

	out->buf = b;
	out->next = NULL;

	b->pos = ngx_hello_world;
	b->last = ngx_hello_world + sz;
	b->memory = 1;
	b->last_buf = 1;

	return ngx_http_output_filter(r, out);
}


#define ParamsMax 64
typedef struct para_s{
    ngx_str_t k;
    ngx_str_t v;
    int val;
}para_t;
para_t gParas[ParamsMax];

static int parse_params(ngx_str_t *argsptr)
{
	int params = 0;
    return params;

	while(params < ParamsMax){
               
        

        params++;
	}
    return params;
}

static void setup_return(size_t *sz, int sum)
{
    *sz = sprintf((char *)gBuf, "%d\n", sum);
}

static ngx_int_t ngx_params_handler(ngx_http_request_t *r)
{
	ngx_buf_t *b;
    ngx_chain_t *out;	
	u_char *buffer = (u_char*)gBuf;
	
    size_t sz;
	int sum = 0;
    int valid_paras_num = 0;

    //parse the URL parameters
    valid_paras_num = parse_params(&r->args);
    


    //setup the return data
    setup_return(&sz, sum);

	b = ngx_calloc_buf(r->pool);
    out = ngx_alloc_chain_link(r->pool);
	
	out->buf = b;
	out->next = NULL;
	
	b->pos = buffer;
    b->last = buffer + sz;
    b->memory = 1;
    b->last_buf = 1;

	r->headers_out.content_type.len = sizeof("text/html") - 1;
	r->headers_out.content_type.data = (u_char *) "text/html";
	r->headers_out.status = NGX_HTTP_OK;
	r->headers_out.content_length_n = sz;
	ngx_http_send_header(r);
	

	return ngx_http_output_filter(r, out);
}

static ngx_int_t ngx_params_handler_v2(ngx_http_request_t *r)
{
    ngx_buf_t *b;
    ngx_chain_t *out;
    u_char *buffer = (u_char*)gBuf;

    size_t sz;
    int sum = 0, va, vb;
	ngx_str_t arg_a = ngx_string("a");
	ngx_str_t arg_b = ngx_string("b");
	ngx_str_t val_a = ngx_null_string, val_b = ngx_null_string;
	

    //parse the URL parameters: a=xxx&b=xxx
	if(NGX_OK != ngx_http_arg(r, arg_a.data, arg_a.len, &val_a)){
		ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "get arg_a fail");
	}
    if(NGX_OK != ngx_http_arg(r, arg_b.data, arg_b.len, &val_b)){
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "get arg_b fail");
    }	
	
	va = atoi((const char*)val_a.data);
	vb = atoi((const char*)val_b.data);
	
	sum = va + vb;
	
    //setup the return data
    setup_return(&sz, sum);

    b = ngx_calloc_buf(r->pool);
    out = ngx_alloc_chain_link(r->pool);

    out->buf = b;
    out->next = NULL;

    b->pos = buffer;
    b->last = buffer + sz;
    b->memory = 1;
    b->last_buf = 1;

    r->headers_out.content_type.len = sizeof("text/html") - 1;
    r->headers_out.content_type.data = (u_char *) "text/html";
    r->headers_out.status = NGX_HTTP_OK;
    r->headers_out.content_length_n = sz;
    ngx_http_send_header(r);


    return ngx_http_output_filter(r, out);
}


static char *ngx_http_hello_world(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
	ngx_http_core_loc_conf_t  *clcf;
	clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
	clcf->handler = ngx_http_hello_world_handler;
	return NGX_CONF_OK;
}


static char *ngx_http_params_opr(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;
    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
    clcf->handler = ngx_params_handler;
    return NGX_CONF_OK;
}


static char *ngx_http_params_opr_v2(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;
    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
    clcf->handler = ngx_params_handler_v2;
    return NGX_CONF_OK;
}

