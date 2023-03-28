local db = {}
local HTTPService = game:GetService("HttpService")

local char_to_hex = function(c)
	return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
	if url == nil then
		return
	end
	url = url:gsub("\n", "\r\n")
	url = url:gsub("([^%w ])", char_to_hex)
	url = url:gsub(" ", "+")
	return url
end

--[=[
	@return String
	Gets a certain value from a key in the database.


	```lua
	db:GetKey("messageoftheday", true) -- returns "HELLO REPL"

	db:GetKey("messageoftheday") -- returns HELLO REPL
	```
]=]

function db:GetKey(key: string, quotes: boolean)
	local resp = HTTPService:RequestAsync({
		Url = self.key .. "/" .. key,
		Method = "GET",
		Headers = nil,
		Body = nil,
	})

	if resp.Success then
		if
			string.sub(resp.Body, 1, 1) == '"'
			and string.sub(resp.Body, #resp.Body, #resp.Body) == '"'
			and not quotes
		then
			return resp.Body:sub(2, #resp.Body - 1)
		end
		return resp.Body
	else
		return nil
	end
end

--[=[
	@return (boolean, any)

	Sets the key in the database to a certain value.

	```lua
		db:SetKey("messageoftheday", "testing!") -- true
	```
]=]

function db:SetKey(key: string, value: string)
	if typeof(value) ~= "string" then
		warn("[REPLDB] Value not a string, try serializing!")
	end

	local resp = HTTPService:RequestAsync({
		Url = self.key .. "/" .. key,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
		Body = urlencode(key) .. "=" .. urlencode(value),
	})

	if resp.Success then
		return true, resp.Body
	else
		return false, resp.Body
	end
end

--[=[
	@return (boolean, any)

	Sets the key in the database to a certain value.

	```lua
		db:DeleteKey("messageoftheday") -- true
	```
]=]

function db:DeleteKey(key: string)
	local resp = HTTPService:RequestAsync({
		Url = self.key .. "/" .. key,
		Method = "DELETE",
	})

	if resp.Success then
		return true, resp.Body
	else
		return false, resp.Body
	end
end

--[=[
	@return nil

	Sets the key in the database to a certain value.

	```lua
		db:DeleteMultipleKeys({"key1", "key2"})
	```
]=]

function db:DeleteMultipleKeys(keys: {})
	for _, v in pairs(keys) do
		self:DeleteKey(v)
	end
end

--[=[
	@return nil

	Sets the key in the database to a certain value.

	```lua
		db:SetMultiple({["key1"] = "dog", ["key2"] = "cat"})
	```
]=]

function db:SetMultipleKeys(keys: {})
	for i, v in pairs(keys) do
		self:SetKey(i, v)
	end
end

local mt = {}
mt.__index = db
function mt.new(key: string)
	local self = {}

	setmetatable(self, mt)
	self.key = key

	return self
end
return mt
