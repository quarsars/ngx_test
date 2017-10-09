local args = ngx.req.get_uri_args();
local result = "";
-- iterate the args
result = result.."======Debug info========\n";
result = result.."type of args: "..type(args).."\n";

local tab = {};
local size = 0;

for k,v in pairs(args) do
	local numv = tonumber(v);
	result = result.."key:"..k..",value(2number):"..tostring(numv).."\n"; -- numv should be nil if
	if(numv) then
		size = size + 1;
		tab[size] = numv;
	end
end
result = result.."have "..size.." valid numbers.\n";

ngx.print(result);


local libsum = require("libsum");
local sum = libsum.sum(tab, size);

ngx.print(sum.."\n");

