-- Theme loader.
-- Load order: defaults -> conf/theme.<profile>.lua -> conf/theme.local.lua.
-- <profile> is CONKY_THEME_PROFILE when set, otherwise the current hostname.

local conky_dir = os.getenv("HOME") .. '/.config/conky'
local theme_dir = conky_dir .. '/conf'

local function file_exists(path)
    local file = io.open(path, 'r')
    if file then
        file:close()
        return true
    end

    return false
end

local function load_theme_file(path, required)
    if not file_exists(path) then
        if required then
            error('Theme file not found: ' .. path)
        end

        return {}
    end

    local values = dofile(path)
    if values == nil then
        return {}
    end

    if type(values) ~= 'table' then
        error('Theme file must return a table: ' .. path)
    end

    return values
end

local function merge_tables(base, override)
    for key, value in pairs(override) do
        if type(value) == 'table' and type(base[key]) == 'table' then
            merge_tables(base[key], value)
        else
            base[key] = value
        end
    end

    return base
end

local function first_line(command)
    local handle = io.popen(command .. ' 2>/dev/null')
    if not handle then
        return nil
    end

    local line = handle:read('*l')
    handle:close()

    if line == '' then
        return nil
    end

    return line
end

local function profile_name()
    local profile = os.getenv('CONKY_THEME_PROFILE') or first_line('hostname')
    if not profile or profile == '' then
        return nil
    end

    return profile:gsub('[^%w_-]', '_')
end

local theme = load_theme_file(theme_dir .. '/theme.defaults.lua', true)
local profile = profile_name()

if profile then
    merge_tables(theme, load_theme_file(theme_dir .. '/theme.' .. profile .. '.lua', false))
end

merge_tables(theme, load_theme_file(theme_dir .. '/theme.local.lua', false))

local function conky_config_font(font)
    return string.format('%s:size=%s', font.family, font.size)
end

local function conky_text_font(font)
    return string.format('${font "%s":size=%s}', font.family, font.size)
end

theme.font.default.spec = conky_config_font(theme.font.default)
theme.font.symbol.spec = conky_config_font(theme.font.symbol)
theme.font.symbol.conky = conky_text_font(theme.font.symbol)

return theme
