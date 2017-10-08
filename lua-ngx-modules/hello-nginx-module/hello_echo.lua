
local libechohello = require('libhello');
local str=libechohello.pr_hello();
ngx.print(str.."\n");
