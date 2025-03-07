---@diagnostic disable: param-type-mismatch
LOADER_API = {}

function SMODS.INIT.LOADER_API()
	local mod = SMODS.findModByID("loader-api")
	assert(load(NFS.read(mod.path .. "src/utils.lua")))()

	LOADER_API.init(mod.id)
end
