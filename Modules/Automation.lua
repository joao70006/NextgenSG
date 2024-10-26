-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Camera = workspace.CurrentCamera

-- Modules
local AutomationController = {}
local GameController = _G.Require("Modules/Game")

-- Functions
local function FetchMovementNeeded(TargetDirection: Vector3): ()
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
    local CurrentPower, IsActive = GameController.FetchCurrentPower()
    local LastDistance
    local Distance = 100

    if not IsActive then
        mouse1click()
    end

    while RunService.RenderStepped:Wait() do
        if UserInputService:IsMouseButtonPressed("MouseButton2") or (LastDistance and math.abs(LastDistance) <= 0.001) then
            break
        end

        CurrentPower = GameController.FetchCurrentPower()
        Distance = (TargetPower - CurrentPower)
        
        UserInputService.MouseDeltaSensitivity = math.abs(Distance) <= 0.3 and math.abs(Distance) + 0.01 or 2 

        LastDistance = Distance
        mousemoverel(math.ceil(Distance), 0)
    end

    UserInputService.MouseDeltaSensitivity = 1

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

local function CopyDirection(): ()
    local Direction = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)

    setclipboard(`Vector3.new({Direction})`)
end

local function CopyPosition(): ()
    local LocalBall = GameController.FetchLocalBall()
    
    if not LocalBall then
        return warn('LocalBall not found | 05')
    end

    local Position = LocalBall:GetPivot().Position
    setclipboard(`Vector3.new({Position})`)
end

AutomationController.CopyDirection = CopyDirection
AutomationController.CopyPosition = CopyPosition
AutomationController.AlignAim = AlignAim
AutomationController.InsertPower = InsertPower

return AutomationController