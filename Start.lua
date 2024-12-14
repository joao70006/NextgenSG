local function Load(Path: string, Silent: boolean): ()
    if not Silent then
        warn(`Loading {Path}`)
    end
    
    return loadstring(game:HttpGet(`http://127.0.0.1:5500/{Path}.lua`, true))()
end

_G.Modules = {}

_G.Modules['KeyFunctions'] = Load('Input/KeyFunctions')

-- Require Modules
for _, Path in listfiles("SGMain/Modules") do
    local ModuleName = Path:sub(16, -5)

    _G.Modules[ModuleName] = Load(`Modules/{ModuleName}`)
end

 -- Initiate InputBegan
Load("Input/InputBegan")

_G.Loaded = true