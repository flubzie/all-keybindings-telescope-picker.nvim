1. copy the contents inside of all-keybindings-telescope-picker.lua and add it to your init.lua
2. you can add common_keybindings.lua into your `lua/` folder under your nvim config dir, or to get a (possibly) more updated version you can run the following commands to parse `:h index" yourself
- open nvim in whatever directory you want to create an `index.txt` in: `nvim .`
- run `:h index` to open the help window followed by `:w! index.txt` to write the current buffer to `index.txt`
- run `python3 index_txt_parser.py` to compile a new `common_keybindings.lua`
- perform step 1 (adding the the picker code to your init.lua) and step 2 (adding the new common_keybindings.lua to your nvim config lua/ folder)


__Note: some keybindings might be missing, but hopefully not any very common ones. I think the parser has some issues parsing lines that don't have a tag, which i might fix someday.__
