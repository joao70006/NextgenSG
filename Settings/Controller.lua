-- Services

-- Variables
local Camera = workspace.CurrentCamera

-- Modules
local CacheCheckpoints = {}
local SettingsController = {}
local GameController = _G.Require("Modules/Game")
local MathController = _G.Require("Modules/Math")

-- Functions
local function FetchPath(): string
    local Map = GameController.FetchMap()
    local Hole = GameController.FetchHole()

    if not Map then
        return warn('Map not found.')
    end

    if not Hole then
        return warn('Hole not found.')
    end

    local Path = `SGMain/Settings/{Map}/{Hole}.lua`

    return Path
end

local function CreateHoleSettings(): table
    local Template = `local HoleSettings = \{}`
    Template = Template..'\n\nHoleSettings.Checkpoints = {}'
    Template = Template..'\n\nHoleSettings.AnchorPoints = {}'
    Template = Template..'\n\nreturn HoleSettings'

    local Path = FetchPath()

    if not Path then
        return
    end
    
    delfile(Path)
    writefile(Path, Template)

    return loadstring(Template)
end

local function FetchHoleSettings(): table
    local Map = GameController.FetchMap()
    local Hole = GameController.FetchHole()
    local Path = `SGMain/Settings/{Map}/{Hole}.lua`

    if not isfile(Path) then
        return CreateHoleSettings()
    end
    
    local FileContent = readfile(Path)
    
    if string.len(FileContent) == 0 then
        return CreateHoleSettings()
    end

    local HoleSettings = loadstring(FileContent)()

    return HoleSettings
end

local function PushHoleSettings(): ()
    local Path = FetchPath()
    local HoleSettings = FetchHoleSettings()
    local Content = 'local HoleSettings = {'

    for Index, Value in HoleSettings do -- Depth 0
        if type(Value) == 'table' then -- Depth 1
            Content = Content..`\n    {Index} = `..'{'

            for Index2, Value2 in Value do
                if type(Index2) == 'number' then
                    Content = Content..`\n        [{Index2}] = {Value2},\n`
                elseif type(Index2) == 'string' then
                    Content = Content..`\n        {Index2} = {Value2},\n`
                end
            end

            Content = Content..`\n    },`
        elseif type(Value) ~= 'table' then -- Depth 1
            Content = Content..``
        end
    end

    Content = Content..'\n}\n\nreturn HoleSettings'

    task.wait()

    writefile(Path, Content)
end

local function CreateCheckpoint(): ()
    local LocalBall = GameController.FetchLocalBall()

    if not LocalBall then
        return
    end

    local Origin = LocalBall:GetPivot().Position
    local NewCheckpoint = {}
    NewCheckpoint.Direction = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    NewCheckpoint.Power = GameController.FetchPower()
    NewCheckpoint.Position = Origin

    return NewCheckpoint
end

local function SaveCheckpoint(Checkpoint: table): ()
    table.insert(CacheCheckpoints, Checkpoint)
end

SettingsController.PushHoleSettings = PushHoleSettings
SettingsController.FetchHoleSettings = FetchHoleSettings
SettingsController.CreateHoleSettings = CreateHoleSettings
SettingsController.CreateCheckpoint = CreateCheckpoint
SettingsController.SaveCheckpoint = SaveCheckpoint

return SettingsController