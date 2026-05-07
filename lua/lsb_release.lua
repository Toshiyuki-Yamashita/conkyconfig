local env = {}
function load_env(path)
    if not io.open(path) then
        return 
    end

    for line in io.lines(path) do
        if not line:match("^%s*#") and not line:match("^%s*$") then
            local key, value =
                line:match("^([%w_]+)%s*=%s*(.-)%s*$")

            if key then
                if value:match('^".*"$') or value:match("^'.*'$") then
                    value = value:sub(2, -2)
                end
                env[key] = value
            end
        end
    end

end

function conky_env_get(key)
    return env[key] or ""
end

-- Populate environment values once when Conky loads this script.
load_env('/etc/lsb-release')
load_env('/etc/os-release')

-- Compatibility fallback for systems that only define PRETTY_NAME.
if env.DISTRIB_DESCRIPTION == nil or env.DISTRIB_DESCRIPTION == "" then
    env.DISTRIB_DESCRIPTION = env.PRETTY_NAME or ""
end
