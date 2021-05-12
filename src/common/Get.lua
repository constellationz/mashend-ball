-- Get is a customizable loader used to retrieve instances and modules
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Libraries = ReplicatedStorage:WaitForChild("Libraries")

local Get = {
	version = "1.0"
}

-- Recursively explores children to find an instance
function Search(parent, locations)
	local child = parent:FindFirstChild(locations[1])
	if #locations == 1 then
		return child
	elseif child ~= nil then
		table.remove(locations, 1)
		return Search(child, locations)
	end
end

-- Look for an instance and return it.
-- Allows recursive searches with directory slashes.
function GetInstance(parent, location)
	local locations = string.split(location, "/")
	return Search(parent, locations)
end

-- Makes sure a result exists.
function AssertExistence(result, name)
	if result == nil then
		error(string.format("Could not find %s", name), 0)
	end
end

-- Tries to load a module.
function LoadModule(module, name)
	AssertExistence(module, name)
	assert(module:isA("ModuleScript"), string.format(
		"Tried to load %s which is a %s", name, module.ClassName))
		
	return require(module)
end

-- Get.Module looks into libraries and Modules
function Get.Module(name)
	-- looks for an Instance in both Modules and Libraries
	local module = GetInstance(Modules, name)
	local library = GetInstance(Libraries, name)
	
	-- if a module and library exists, warn user
	if module ~= nil and library ~= nil then
		warn(string.format(
			"Found module %s in both Libraries and Modules. Using Module", 
				name))
	end

	-- return module first over library
	return LoadModule(module or library, name)
end

-- Add a Get call. Optionally process result before returning.
-- @param call
-- @param parent
-- @param[opt] process
function ListenFor(call, parent, process)
	Get[call] = function(name)
		local result = GetInstance(parent, name)
		return process ~= nil and process(result, name) or result
	end
end

-- Look into folders different calls.
ListenFor("Asset", Assets, AssertExistence) -- Get.Asset
ListenFor("Remote", Remotes, AssertExistence) -- Get.Remote

-- Server scripts can use Get.Server (ServerScriptService.ServerModules)
if RunService:IsServer() then
	local ServerModules = game:GetService("ServerScriptService")
		:FindFirstChild("ServerModules")

	-- Loads server modules.
	ListenFor("Server", ServerModules, LoadModule)
end

-- When Get(...) is called, it is passed here.
-- By default, evaluates to Get.Module
function RawGet(_, moduleName)
	return Get.Module(moduleName)
end
setmetatable(Get, {__call = RawGet})

return Get
