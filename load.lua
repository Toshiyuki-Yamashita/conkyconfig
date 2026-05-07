local dir = os.getenv("HOME") .. "/.config/conky/lua"

local p = io.popen('find "' .. dir .. '" -name "*.lua"')

for file in p:lines() do
    print("loading:", file)
    dofile(file)
end

p:close()