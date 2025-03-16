# Balatro Loader API

Simple API mod to load mods that follow the convention below

## Convention

Below is the convention definition for mods that can use the Loader API. Wherever you see `{{mod-name}}` or `{{MOD_ID}}` you should replace with variables specific to your mod, along with preferably following the naming convention used.

### Directory Structure

The directory of your mod should be structured as below, with all the files related to the mod contained inside the `src` directory. A different name along with additional directories to load can be configured in the `init` function options.

```
{{mod-name}}
├── assets
│   ├── 1x
│   └── 2x
├── src
├── config.lua
├── main.lua
├── {{mod-name}}.json
└── README.md
```

**NOTE**: files and directories are not loaded in any particular order. They should be considered "independent" of each other. There are a few options if you want to have some shared logic across files.

1. Create a `lib` directory and pass `source_dir = ["lib", "src"]` to `init`. This will load the lib directory before the source.
2. Explicitly call `load_directories` or `load_file` to load the dependents in your script. The paths passed to these functions are relative to the mod id's folder.

### Mod Name

The mod id should be in kebab-case and is preferably also the same as `mod-name` used in the directory structure above.
**E.g** `loader-api`

### {{mod-name}}.json

Below is an example metadata file for configuring your mod. Make sure priority is greater than loader-api's priority of -1.

```json
{
  "id": "{{mod-name}}",
  "name": "{{Mod Name}}",
  "display_name": "{{Mod Name}}",
  "author": ["{{author}}"],
  "description": "{{description}}",
  "prefix": "{{mod_name}}",
  "main_file": "main.lua",
  "version": "1.0.0",
  "dependencies": ["Steamodded (>=1.*)", "Lovely (>=0.6)", "loader-api (>=1.*)"]
}
```

### main.lua

To load your mod directories, use the `LOADER_API.init()`.

```lua
["{{MOD_ID}}"] = {} -- global variable to associate your config and mod functions with.

LOADER_API.init()
```

### config.lua

```lua
["{{MOD_ID}}"].CONFIG = {
    ["enabled"] = true
    ...
}
```

## API Functions

### `LOADER.API.load_file`
The `SMODS.load_file`, just assigned to the `LOADER_API global` for ease

```lua
LOADER_API.load_file = SMODS.load_file
```

### `LOADER_API.load_directory`

Loads a specific directory. Useful you don't want to use the `init` function but do want to load directories. Won't reload already loaded files. By default, it won't recurse into sub directories.

```lua
---loads all the files in a directory
---@param path string the path of the directory to load
---@param id? string  the mod id. Default to `SMODS.current_mod` if not provided.
---@param max_depth? number the max recursion depth. defaults to `3`.
---@param depth? number the current recursion depth
function LOADER_API.load_directory(directory, max_depth, depth)
```

### `LOADER_API.init`

Initializes a mod. To initialize a specific mod instead of the current mod being handled by SMODS, pass the mod id. If you would like to use a different global variable or config variable name, you can define `vars` inside options. If you would like to load a different source directory or multiple directories alongside `src`, you can set `source_dir` in options.

```lua
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
```
