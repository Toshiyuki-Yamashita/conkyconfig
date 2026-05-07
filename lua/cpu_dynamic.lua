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

function conky_cpu_usage_lines()
    local max_cpu = get_logical_cpu_count()
    local lines = {}
    local i = 1

    while i <= max_cpu do
        local left = string.format(
            '${color grey}%d:${cpu cpu%d}%%${cpugraph cpu%d 20,130 000000 ffffff}',
            i,
            i,
            i
        )

        local right = ''
        if i + 1 <= max_cpu then
            right = string.format(
                ' ${color grey}%d:${cpu cpu%d}%%${cpugraph cpu%d 20,130 000000 ffffff}',
                i + 1,
                i + 1,
                i + 1
            )
        end

        table.insert(lines, ' ' .. left .. right)
        i = i + 2
    end

    return table.concat(lines, '\n')
end

function conky_core_temp_lines()
    local core_indices = get_core_indices_from_sensors()

    if #core_indices == 0 then
        local fallback_cores = math.max(1, math.floor(get_logical_cpu_count() / 2))
        for i = 0, fallback_cores - 1 do
            table.insert(core_indices, i)
        end
    end

    local lines = {}
    for _, core_index in ipairs(core_indices) do
        local cpu_index = core_index + 1
        local line = string.format(
            " ${color grey}Core %d: ${freq_g %d}GHz ${execi 5 sensors | grep 'Core %d' | cut -c16-20}${font \"IBM Plex Sans JP\":size=8}C $font",
            core_index,
            cpu_index,
            core_index
        )
        table.insert(lines, line)
    end

    return table.concat(lines, '\n')
end
