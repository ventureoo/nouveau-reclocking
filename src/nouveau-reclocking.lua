#!/usr/bin/env lua
--[[
Copyright (C) 2024 Vasiliy Stelmachenok <ventureo@yandex.ru>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--]]

--[[
-- You can find more information about the purpose of this script here:
-- https://forums.debian.net/viewtopic.php?t=146141
-- https://github.com/polkaulfield/nouveau-reclocking-guide
--]]
local version = "1.1"

local aliases = {
    ["-l"] = "--list",
    ["-h"] = "--help",
    ["-v"] = "--version",
    ["-s"] = "--pstate",
    ["-c"] = "--card"
}

local function die(err, ...)
    print(err:format(...))
    os.exit(1)
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

local function nouveau_is_loaded()
    return file_exists("/sys/module/nouveau")
end

-- Hacky, but the only way I could think of
local function is_running_as_root()
    local file, err = io.open("/sys/kernel/debug", "r")
    if err and err:match(".+: Permission denied") then
        return false
    else
        io.close(file)
        return true
    end
end

local function get_device_pstates(devicePath)
    local pstates = {}
    local clocks = {}
    local count = 0
    local pstate_level_pattern = "(..):(.+)"

    local device = io.open(devicePath, "r")

    if not device then
        return nil
    end

    local line = device:read()
    while line do
        local pstate, clock = line:match(pstate_level_pattern)
        -- AC pstate is buggy, so just ignore it
        if pstate and pstate ~= "AC" then
            pstates[#pstates + 1] = pstate
            clocks[#clocks+1] = clock
            count = count + 1
        end
        line = device:read()
    end
    device:close()

    if count == 0 then
        print("No available pstate levels in " .. devicePath)
        return nil
    end

    return pstates, clocks
end

local function write_pstate(path, pstate, slient)
    local file, err = io.open(path, "w+")

    if file then
        local errmsg = file:write(pstate)
        if not errmsg and not slient then
            print(string.format("Successfully applied pstate %s for %s", pstate, path))
        end
        file:close()
    else
        print(string.format("Couldn't write the pstate for %s: %s", path, err))
    end
end

local function change_device_pstate(level, device, savePath)
    local pstates = get_device_pstates(device)

    if not pstates then
        return false
    end

    local pstate = level
    if level == "max" then
        pstate = pstates[#pstates]
    elseif level == "min" then
        pstate = pstates[1]
    end

    write_pstate(device, pstate)

    if savePath then
        local contents = "options nouveau config=NvClkMode=" .. tonumber(pstate, 16)
        write_pstate(savePath, contents, true)
    end

    return true
end

local function find_devices(callback)
    -- Ugly hacks
    for id = 0, 16 do
        local path = "/sys/kernel/debug/dri/" .. id .. "/pstate"
        if file_exists(path) then
            callback(path, id)
        end
    end
end

local function change_for_all_devices(level)
    local success = false
    find_devices(function(path)
        success = success or change_device_pstate(level, path)
    end)
    if not success then
        die("No devices were found that can be relocking :(")
    end
end

local function print_avaliable_pstates()
    find_devices(function(path, id)
        local pstates, clocks = get_device_pstates(path)

        if pstates and clocks then
            print("GPU #" .. id)
            for j = 1, #pstates do
                print(string.format("%s: %s", pstates[j], clocks[j]))
            end
        end
    end)
    os.exit(0)
end

local function get_opts(args)
    local options = {}
    local option_pattern = "-%-?(.+)"

    for i = 1, #args do
        local option = aliases[args[i]] or args[i]
        local match = option:match(option_pattern)

        if match then
            options[match] = i
        end
    end
    return options
end

local function check_on_conflicts(options, ...)
    local conflictsOpts = { ... }
    local lastFound

    for i = 1, #conflictsOpts do
        local option = conflictsOpts[i]
        if options[option] then
            if lastFound ~= nil then
                die("--%s and --%s cannot be specified at the same time", lastFound, option)
            else
                lastFound = option
            end
        end
    end
end

local function print_usage()
    print [[
nouveau-reclocking - a small utility to relock your GPU with nouveau

Options:
  -c --card      Set for a specific card only (numeric ID)
  -s --pstate    Set Pstate value
     --max       Enable the maximum possible value of avaliable Pstate (performance)
     --min       Enable the minimum possible value of avaliable Pstate (powersave)
  --save [path]  Make the pstate level permanent (default is /etc/modprobe.d/90-nouveau.conf)
  -l --list      Print avaliable pstate levels and exit
  -h --help      Show this message
  -v --version   Display program version

WARNING: Reclocking is supported only on GM10x Maxwell, Kepler and Tesla G94-GT218 GPUs.
]]
    os.exit(0)
end

local function get_opt_argument(options, option, default)
    local index = options[option]
    if index ~= nil then
        local option_argument = arg[index + 1]
        if option_argument == nil or options[option_argument:gsub("-%-", "")] then
            if not default then
                die("Missing argument for option %s", option)
            else
                return default
            end
        else
            return option_argument
        end
    end
end

local function main()
    local options = get_opts(arg)

    check_on_conflicts(options, "max", "min", "pstate", "list")

    if options.help or #arg == 0 then
        print_usage()
    end

    if options.version then
        print("nouveau-reclocking v" .. version .. " written by Vasiliy Stelmachenok (ventureo@yandex.ru)")
        os.exit(0)
    end

    if not nouveau_is_loaded() then
        die("Nouveau module is not loaded, exit...")
    end

    if not is_running_as_root() then
        die("This program is should be run as root")
    end

    local card = get_opt_argument(options, "card", nil)
    local level = get_opt_argument(options, "pstate", nil)
    local save = get_opt_argument(options, "save", "/etc/modprobe.d/90-nouveau.conf")

    if options.list then
        print_avaliable_pstates()
    elseif options.max then
        level = "max"
    elseif options.min then
        level = "min"
    end

    if not level then
        die("Please select the pstate level you want to set up with --max, --min or --pstate")
    end

    if card then
        local path = "/sys/kernel/debug/dri/" .. card .. "/pstate"
        if file_exists(path) then
            local res = change_device_pstate(level, path, save)
            if not res then
                die("Could not apply the Pstate to the device %s", path)
            end
        else
            die("Card with index %s is not available or doesn't support pstate", card)
        end
    else
        change_for_all_devices(level)
    end
end

main()
