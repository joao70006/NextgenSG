-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Camera = workspace.CurrentCamera

-- Modules
local AutomationController = {}

-- Functions
local function FetchMovementNeeded(TargetDirection: Vector3): ()
    local GameController = _G.Modules.Game
    local LocalBall = GameController.FetchLocalBall()
    
    if not LocalBall then
        return warn('LocalBall not found | 03')
    end

    local Origin = LocalBall:GetPivot().Position
    local TargetPosition = Origin + TargetDirection * 2000
    local Vector, OnScreen = Camera:WorldToScreenPoint(TargetPosition)
    local ScreenPoint = Vector2.new(Vector.X, Vector.Y)
    local MidPoint = Camera.ViewportSize / 2
    local MovementNeeded = (ScreenPoint - MidPoint)

    return MovementNeeded, OnScreen
end

local function InsertPower(TargetPower: number): ()
    local GameController = _G.Modules.Game
    local SettingsController = _G.Modules.Settings
    local HoleSettings = SettingsController.FetchHoleSettings()
    local CurrentPower, IsActive = GameController.FetchPower()
    local LastDifference
    local Distance = 100

    if not IsActive then
        mouse1click()
    end

    while RunService.RenderStepped:Wait() do
        if UserInputService:IsMouseButtonPressed("MouseButton2") or (LastDifference and math.abs(LastDifference) <= 0.01) then
            break
        end

        if UserInputService:IsKeyDown("L") then
            UserInputService.MouseDeltaSensitivity = 1
            
            return
        end

        CurrentPower = GameController.FetchPower()
        Distance = (TargetPower - CurrentPower)
        Distance = math.ceil(Distance)
        
        if Distance < 1 and Distance > -1 then
            if Distance > 0 then
                Distance = 1
            elseif Distance <= 0 then
                Distance = -1
            end
        end

        local Difference = (TargetPower - CurrentPower)
        
        UserInputService.MouseDeltaSensitivity = math.abs(Difference) <= 3 and Difference * 5 + 0.001 or 3

        LastDifference = Difference
        mousemoverel(math.ceil(Distance), 0)
    end

    UserInputService.MouseDeltaSensitivity = 1

    if HoleSettings.HoldToRelease then
        repeat
            task.wait()
        until
            not UserInputService:IsKeyDown("Q") and not UserInputService:IsKeyDown("X")
    end

    mouse1click()
end

local function AlignAim(TargetDirection: Vector3): ()    
    local MovementNeeded, OnScreen = FetchMovementNeeded(TargetDirection)

    if not MovementNeeded then
        return
    end

    while RunService.RenderStepped:Wait() do
        if UserInputService:IsKeyDown("L") then
            break
        end

        MovementNeeded, OnScreen = FetchMovementNeeded(TargetDirection)

        if not OnScreen then
            continue
        end

        if math.abs(MovementNeeded.X) <= 0.6 then
            break
        end

        MovementNeeded = math.abs(MovementNeeded.X) >= 5 and MovementNeeded.X / 3 or MovementNeeded.X

        mousemoverel(math.round(MovementNeeded), 0)
    end
end

local function FetchDirection(ShouldCopy: boolean): Vector3
    local Direction = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)

    if ShouldCopy then
        setclipboard(`Vector3.new({Direction})`)
    end

    return Direction
end

local function FetchPosition(ShouldCopy: boolean): ()
    local GameController = _G.Modules.Game
    local LocalBall = GameController.FetchLocalBall()
    
    if not LocalBall then
        return warn('LocalBall not found | 05')
    end
    
    local Position = LocalBall:GetPivot().Position
    
    if ShouldCopy then
        setclipboard(`Vector3.new({Position})`)    
    end

    return Position
end

local function FetchNearestCheckpoint(): (table, number)
    local SettingsController = _G.Modules.Settings
    local GameController = _G.Modules.Game
    local HoleSettings = SettingsController.FetchHoleSettings()
    local LocalBall = GameController.FetchLocalBall()
    local Checkpoints = HoleSettings.Checkpoints and HoleSettings.Checkpoints or {}

    if not HoleSettings or HoleSettings and #Checkpoints < 1 then
        return
    end 

    if not LocalBall then
        return
    end

    local Origin = LocalBall:GetPivot().Position
    local SmallestDistance, NearestCheckpoint = math.huge, nil

    for _, Checkpoint in Checkpoints do
        local Position = Checkpoint.Position
        local Distance = (Position - Origin).Magnitude

        if Distance < SmallestDistance then
            SmallestDistance = Distance
            NearestCheckpoint = Checkpoint
        end
    end

    return NearestCheckpoint, SmallestDistance
end

AutomationController.FetchNearestCheckpoint = FetchNearestCheckpoint
AutomationController.FetchDirection = FetchDirection
AutomationController.FetchPosition = FetchPosition
AutomationController.AlignAim = AlignAim
AutomationController.InsertPower = InsertPower

return AutomationController