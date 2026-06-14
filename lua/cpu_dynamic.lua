local conky_dir = os.getenv("HOME") .. "/.config/conky"
local theme = dofile(conky_dir .. "/theme.lua")

local function get_logical_cpu_count()
    local count = 0
    for line in io.lines('/proc/stat') do
        if line:match('^cpu%d+%s') then
            count = count + 1
        end
    end

    if count < 1 then
        return 1
    end

    return count
end

local function get_core_indices_from_sensors()
    local p = io.popen('sensors 2>/dev/null')
    if not p then
        return {}
    end

    local found = {}
    for line in p:lines() do
        local index = line:match('Core%s+(%d+):')
        if index then
            found[tonumber(index)] = true
        end
    end
    p:close()

    local indices = {}
    for index, _ in pairs(found) do
        table.insert(indices, index)
    end
    table.sort(indices)

    return indices
end

local function cpu_graph(index)
    return string.format(
        '${color %s}%d:${cpu cpu%d}%%${cpugraph cpu%d %d,%d %s %s}',
        theme.colors.label,
        index,
        index,
        index,
        theme.layout.graph_height,
        theme.layout.cpu_graph_width,
        theme.colors.graph_background,
        theme.colors.graph_foreground
    )
end

function conky_cpu_usage_lines()
    local max_cpu = get_logical_cpu_count()
    local lines = {}
    local i = 1

    while i <= max_cpu do
        local left = cpu_graph(i)

        local right = ''
        if i + 1 <= max_cpu then
            right = ' ' .. cpu_graph(i + 1)
        end

        table.insert(lines, ' ' .. left .. right)
        i = i + 2
    end

    return table.concat(lines, '\n')
end

function conky_core_temp_lines()
    local core_indices = get_core_indices_from_sensors()
    local logical_cpu_count = get_logical_cpu_count()

    if #core_indices == 0 then
        local fallback_cores = math.max(1, math.floor(logical_cpu_count / 2))
        for i = 0, fallback_cores - 1 do
            table.insert(core_indices, i)
        end
    end

    local lines = {}
    for sensor_position, sensor_core_index in ipairs(core_indices) do
        local display_core_index = sensor_position - 1
        local cpu_index = math.min(sensor_position, logical_cpu_count)
        local line = string.format(
            " ${color %s}Core %d: ${freq_g %d}GHz ${execi 5 sensors | awk '/Core[[:space:]]+%d:/{print substr($0,16,5); exit}'}%s%s $font",
            theme.colors.label,
            display_core_index,
            cpu_index,
            sensor_core_index,
            theme.font.symbol.conky,
            theme.text.cpu_temperature_unit
        )
        table.insert(lines, line)
    end

    return table.concat(lines, '\n')
end
