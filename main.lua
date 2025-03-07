---@diagnostic disable: param-type-mismatch
LOADER_API = {}

local mod = SMODS.Mods["loader-api"] or SMODS.current_mod
if not mod then
	sendErrorMessage("Error loading loader-api mod.")
	return
end

assert(load(NFS.read(mod.path .. "src/utils.lua")))()
LOADER_API.init(mod.id)
