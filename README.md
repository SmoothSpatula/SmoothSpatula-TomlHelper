# SmoothSpatula-TomlHelper

Helper mod for saving and loading Toml config files for SmoothSpatula mods.

### Usage example




Initializing and loading the config
```
mods["SmoothSpatula-TomlHelper"].auto()
params = {
    max_number = 4,
    enabled = true
}
params = Toml.config_update(_ENV["!guid"], params, {drop_empty_tables = true}) -- Load and Save (merge)

-- or

params = Toml.config_update(_ENV["!guid"], params) -- this will create plugin_name/cfg.toml

-- or if you want to make multiple configs

Toml.config_update({plugin = _ENV["!guid"], config = "myconfig"} , params) -- this will create plugin_name/myconfig.toml

```
The drop_empty_tables flag enables recursive elimination of empty tables inside of the cfg file.

* Saving the config
```
Toml.save_cfg(_ENV["!guid"], params)

-- or if you have multiple config files

Toml.save_cfg({plugin = _ENV["!guid"], config = "myconfig"}, params)
```

* Resetting config to default
```
params = Toml.reset_default(_ENV["!guid"])

-- or 

params = Toml.reset_default({plugin = _ENV["!guid"], config = "myconfig"})
```

* 


* DEPRECATED (still works) Initializing and loading the config
```
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        max_number = 4,
        enabled = true
    }
    params = Toml.config_update(_ENV["!guid"], params) -- Load Save
end)
```