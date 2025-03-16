---@diagnostic disable: param-type-mismatch

---Table containing files that have already been loaded by the api
---@type table<string, boolean>
LOADED_FILES = {}

---gets the mod for a provided id. Throws an error if the mod cannot be found
---@param id? string the mod id. Default to `SMODS.current_mod` if not provided.
---@return table|Mod
local function get_mod(id)
	local mod
	if not id then
		if not SMODS.current_mod then
			error("No ID was provided! Usage without an ID is only available when file is first loaded.")
		end
		mod = SMODS.current_mod
	else
		mod = SMODS.Mods[id]
	end

	if not mod then
		error("Mod not found. Ensure you are passing the correct ID.")
	end

	return mod
end

LOADER_API.load_file = SMODS.load_file

---loads all the files in a directory
---@param path string the path of the directory to load
---@param id? string  the mod id. Default to `SMODS.current_mod` if not provided.
---@param max_depth? number the max recursion depth. defaults to `3`.
---@param depth? number the current recursion depth
function LOADER_API.load_directory(path, id, max_depth, depth)
	depth = depth or 1
	if depth > (max_depth or 3) then
		return
	end
	if not path or path == "" then
		error("No path was provided to load.")
	end

	local mod = get_mod(id)
	local full_dir_path = mod.path .. path

	local dir_info = NFS.getInfo(full_dir_path)
	if dir_info.type ~= "directory" then
		error("Provided path is not a directory.")
	end

	for _, filename in ipairs(NFS.getDirectoryItems(full_dir_path)) do
		local file_path = path .. "/" .. filename
		local full_file_path = mod.path .. file_path
		local file_info = NFS.getInfo(full_file_path)
		if file_info.type == "directory" or file_info.type == "symlink" then
			LOADER_API.load_directory(file_path, id, max_depth, depth + 1)
		elseif file_info.type == "file" and filename:match("%.lua$") then
			-- if we've already loaded the file then skip
			if not LOADED_FILES[full_file_path] then
				assert(load(NFS.read(full_file_path)))()
				LOADED_FILES[full_file_path] = true
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
	local mod = get_mod(id)

	local vars = options and options.vars or {}

	local global_name = vars.global or mod.id:gsub("-", "_"):upper()
	if not _G[global_name] then
		_G[global_name] = {}
	end

	-- Load the mod configuration
	assert(LOADER_API.load_file("config.lua", mod.id))()

	if not _G[global_name][vars.config or "CONFIG"] then
		_G[global_name][vars.config or "CONFIG"] = SMODS.current_mod.config
	end

	---@type { enabled?: boolean }|nil
	local config = _G[global_name][vars.config or "CONFIG"]
	if not config or not config.enabled then
		return
	end

	local source_dir = options and options.source_dir or "src"
	if type(source_dir) == "string" then
		source_dir = { source_dir }
	end

	local depth = options and options.depth or 3
	for _, v in pairs(source_dir) do
		LOADER_API.load_directory(v, mod.id, depth)
	end

	sendDebugMessage(mod.id .. " loaded", "loader-api")
end
