---@diagnostic disable: param-type-mismatch
LOADER_API = {}

SMODS.INIT.LOADER_API = function()
	local mod = SMODS.findModByID("loader-api")
	assert(load(NFS.read(mod.path .. "src/utils.lua")))()

	LOADER_API.init(mod.id)
end
