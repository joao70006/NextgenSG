-- Services


-- Modules
local SettingsController = {}
local AutomationController = _G.Modules.Automation

-- Variables

-- Functions
local function FetchPath(): string
    local GameController = _G.Modules.Game
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
        return warn('Path not found.')
    end
    
    writefile(Path, Template)

    return loadstring(Template)
end

local function PullHoleSettings(): table
    local Path = FetchPath()
    local IsFile, FileContent = isfile(Path), nil

    task.wait()

    if IsFile then
        FileContent = readfile(Path)
    end

    if not IsFile or IsFile and string.len(FileContent) == 0 then
        CreateHoleSettings()
    
        FileContent = readfile(Path)
    end
    
    local HoleSettings = loadstring(FileContent)()

    return HoleSettings
end

local function PushHoleSettings(AddLastCheckpoint: boolean): ()
    local Path = FetchPath()
    local HoleSettings = PullHoleSettings()
    local Content = 'local HoleSettings = {'
    local LastUsedCheckpoint = AutomationController.LastUsedCheckpoint
    local LastCheckpointAdded = AutomationController.LastCheckpointAdded
    
    if AddLastCheckpoint and LastUsedCheckpoint then
        -- Check if LastUsedCheckpoint differs from LastAddedCheckpoint

        if not LastCheckpointAdded or LastCheckpointAdded and LastCheckpointAdded ~= LastUsedCheckpoint then
            table.insert(HoleSettings.Checkpoints, LastUsedCheckpoint)

            AutomationController.LastCheckpointAdded = LastUsedCheckpoint
        end
    end

    -- Create Content
    for Index, Value in HoleSettings do -- Depth 1
        if type(Value) == 'table' then
            Content = Content..`\n    {Index} = `..'{\n'

            for Index2, Value2 in Value do -- Depth 2
                if type(Value2) == 'table' then
                    Content = Content..`\n      [{Index2}] = `..'{'

                    for Index3, Value3 in Value2 do
                        Content = Content..`\n          {type(Index3) == 'number' and '['..Index3..']' or Index3} = {type(Value3) ~= 'vector' and Value3 or 'Vector3.new('..tostring(Value3)..')'},`
                    end

                    Content = Content..`\n      },\n`
                elseif type(Index2) == 'number' then
                    Content = Content..`\n        [{Index2}] = {Value2},\n`
                elseif type(Index2) == 'string' then
                    Content = Content..`\n        {Index2} = {Value2},\n`
                end
            end

            Content = Content..`\n    },\n`
        elseif type(Value) ~= 'table' then -- Depth 1
            Content = Content..`\n    {Index} = {Value},`
        end
    end

    Content = Content..'\n}\n\nreturn HoleSettings'

    task.wait()

    writefile(Path, Content)
end

local function FetchHoleSettings(): table
    if true then--not SettingsController.CurrentSettings then
        SettingsController.CurrentSettings = PullHoleSettings()
    end

    return SettingsController.CurrentSettings
end

local function FetchIndexOfCheckpoint(Checkpoint: table): number
    local HoleSettings = FetchHoleSettings()

    for Index, IteratedCheckpoint in HoleSettings.Checkpoints do
        if IteratedCheckpoint == Checkpoint then
            return Index
        end
    end
end

local function CreateCheckpoint(): table
    local GameController = _G.Modules.Game
    local Origin = AutomationController.FetchPosition()
    local Direction = AutomationController.FetchDirection()
    local Power = GameController.FetchPower()
    
    if not Origin or not Direction or not Power then
        return warn(`Failed to fetch one piece of data.`, Origin, Direction, Power)
    end

    local NewCheckpoint = {}
    NewCheckpoint.Direction = Direction
    NewCheckpoint.Power = Power
    NewCheckpoint.Position = Origin

    return NewCheckpoint
end

SettingsController.FetchHoleSettings = FetchHoleSettings
SettingsController.PushHoleSettings = PushHoleSettings
SettingsController.PullHoleSettings = PullHoleSettings
SettingsController.CreateHoleSettings = CreateHoleSettings
SettingsController.CreateCheckpoint = CreateCheckpoint
SettingsController.FetchIndexOfCheckpoint = FetchIndexOfCheckpoint

return SettingsController