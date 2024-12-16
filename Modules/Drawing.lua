-- Services

-- Variables

-- Modules
local DrawingController = {}

-- Functions
local function DrawLocalLineOfSight(Checkpoint: table, Duration: number): Instance
    if not Checkpoint.Direction then
        return
    end

    local AutomationController = _G.Modules.Automation
    local LineOfSight = Instance.new("Part")
    LineOfSight.Name = `LocalLineOfSight`
    LineOfSight.Size = Vector3.new(0.1, 0.1, 100)
    LineOfSight.Anchored = true
    LineOfSight.CanCollide = false
    LineOfSight.Material = Enum.Material.Glass
    LineOfSight.Transparency = 0.5
    LineOfSight.Color = Color3.new(1, 0.35, 0)
    LineOfSight.Parent = workspace.Checkpoints

    local Origin = AutomationController.FetchPosition()
    local Goal = Origin + Checkpoint.Direction * 100
    local Mid = (Origin + Goal) / 2

    LineOfSight:PivotTo(CFrame.lookAt(Mid, Goal))

    task.delay(Duration, function()
        LineOfSight:Destroy()
    end)

    return LineOfSight
end

local function DrawLineOfSight(Index: number, Checkpoint: table): Instance
    local LineOfSight = Instance.new("Part")
    LineOfSight.Name = `LineOfSight {Index}`
    LineOfSight.Size = Vector3.new(0.1, 0.1, 100)
    LineOfSight.Anchored = true
    LineOfSight.CanCollide = false
    LineOfSight.Material = Enum.Material.Glass
    LineOfSight.Transparency = 0.5
    LineOfSight.Color = Color3.new(0.75, 0.75, 1)
    LineOfSight.Parent = workspace.Checkpoints

    return LineOfSight
end

local function DrawBall(Index: number, Checkpoint: table): Instance
    local Ball = Instance.new("Part")
    Ball.Position = Checkpoint.Position + Vector3.new(0, 1, 0)
    Ball.Size = Vector3.one / 3
    Ball.Material = Enum.Material.Glass
    Ball.Transparency = 0
    Ball.Shape = Enum.PartType.Ball
    Ball.Anchored = true
    Ball.CanCollide = false
    Ball.Color = Color3.new(1, 1, 1)
    Ball.Name = `Ball {Index}`
    Ball.Parent = workspace.Checkpoints

    return Ball
end

local function DrawCheckpoint(Index: number, Checkpoint: table, Duration: number, Properties: table): Instance
    -- Create Folder
    local Folder do
        if workspace:FindFirstChild("Checkpoints") then
            Folder = workspace.Checkpoints
        elseif not workspace:FindFirstChild("Checkpoints") then
            Folder = Instance.new("Folder")
            Folder.Name = 'Checkpoints'
            Folder.Parent = workspace
        end
    end

    if not Checkpoint.Position then
        return
    end

    local Origin = Checkpoint.Position
    local Ball = DrawBall(Index, Checkpoint)
    local LineOfSight

    if Checkpoint.Direction then
        LineOfSight = DrawLineOfSight(Index, Checkpoint)
    
        local Goal = Origin + Checkpoint.Direction * 101
        local Mid = (Origin + Goal) / 2
        local Cframe = CFrame.lookAt(Mid, Goal)
    
        LineOfSight:PivotTo(Cframe)
    end

    if Properties then
        for Property, Value in Properties do
            Ball[Property] = Value

            if LineOfSight then
                LineOfSight[Property] = Value
            end
        end
    end

    task.delay(Duration, function()
        Ball:Destroy()

        if LineOfSight then
            LineOfSight:Destroy()
        end
    end)
end

local function DrawCheckpoints(Duration: number): ()
    local SettingsController = _G.Modules.Settings
    local HoleSettings = SettingsController.FetchHoleSettings()

    for Index, Checkpoint in HoleSettings.Checkpoints do
        DrawCheckpoint(Index, Checkpoint, Duration)
    end
end

DrawingController.DrawLocalLineOfSight = DrawLocalLineOfSight
DrawingController.DrawCheckpoint = DrawCheckpoint
DrawingController.DrawCheckpoints = DrawCheckpoints

return DrawingController