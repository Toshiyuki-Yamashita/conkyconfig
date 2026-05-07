-- Function to dynamically return the value of an environment variable
function conky_get_env(key)
    return os.getenv(key) or ""
end