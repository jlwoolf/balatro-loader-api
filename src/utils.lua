---@diagnostic disable: param-type-mismatch

---Table containing files that have already been loaded by the api
---@type table<string, boolean>
LOADED_FILES = {}

---loads all the files in a directory
---@param directory string the path of the directory to load
---@param depth number|nil the depth to recurse through the directory. defaults to 1
function LOADER_API.load_directory(directory, depth)
	depth = depth or 1
	if depth > 3 then
		return
	end

	for _, filename in ipairs(NFS.getDirectoryItems(directory)) do
		local file_path = directory .. "/" .. filename
		local file_info = NFS.getInfo(file_path)
		if file_info.type == "directory" or file_info.type == "symlink" then
			local f = LOADER_API.load_directory(file_path, depth + 1)
			if f then
				return
			end
		elseif file_info.type == "file" and filename:match("^(.+)\\.lua$") then
			-- if we've already loaded the file then skip
			if not LOADED_FILES[file_path] then
				assert(load(NFS.read(file_path)))()
				LOADED_FILES[file_path] = true
			end
		end
	end
end

---@class Options.Vars
---@field config? string the name of the config variable for your mod. Defaults to CONFIG
---@field global? string the name of the global variable containing your mods properties. Defaults to MOD_NAME

---@class Options
---@field depth? number the recursion depth to load directories. Defaults to 3
---@field source_dir? string|string[] the source directory (directories) containing all the .lua files to load. Defaults to 'src'
---@field vars? Options.Vars variable names used by the loader

---initializes a mod
---@param id? string
---@param options? Options
function LOADER_API.init(id, options)
	local mod = SMODS.Mods[id] or SMODS.current_mod

	if id and not mod then
		sendErrorMessage("Error finding mod with id: " .. id)
		return
	end

	if not mod then
		sendErrorMessage("Error finding mod. Is SMODS installed correctly?")
		return
	end

	local vars = options and options.vars or {}

	local global_name = vars.global or mod.id:gsub("-", "_"):upper()
	if not _G[global_name] then
		_G[global_name] = {}
	end

	-- Load the mod configuration
	assert(load(NFS.read(mod.path .. "config.lua")))()

	if not _G[global_name][vars.config or "CONFIG"] then
		_G[global_name][vars.config or "CONFIG"] = SMODS.current_mod.config
	end

	---@type { enabled?: boolean }|nil
	local config = _G[global_name][vars.config or "CONFIG"]
	if not config or not config.enabled then
		return
	end

	local depth = options and options.depth or 3

	if options and type(options.source_dir) == "string" then
		LOADER_API.load_directory(mod.path .. options.source_dir, depth)
	elseif options and type(options.source_dir) == "table" then
		for k, v in pairs(options.source_dir) do
			LOADER_API.load_directory(mod.path .. v, depth)
		end
	else
		LOADER_API.load_directory(mod.path .. "src", depth)
	end

	sendDebugMessage(mod.id .. " loaded")
end
