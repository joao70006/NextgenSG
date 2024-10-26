local function Load(Path: string, Silent: boolean): ()
    if not Silent then
        warn(`Loading {Path}`)
    end
    
    return loadstring(game:HttpGet(`http://127.0.0.1:5500/{Path}.lua`, true))()
end

local function Require(Path: string): ()
    local Module = Load(Path, true)

    return Module
end

_G.Require = Require

Load("InputBegan")

_G.Loaded = true