-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Camera = workspace.CurrentCamera
local AutomationsController = {}
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
    local Distance = 100

    if not IsActive then
        mouse1click()
    end

    while Distance > 0.01 and not UserInputService:IsMouseButtonPressed("MouseButton2") and RunService.RenderStepped:Wait() do
        CurrentPower = GameController.FetchCurrentPower()
        Distance = math.ceil((TargetPower - CurrentPower))

        if Distance <= 2 then
            UserInputService.MouseDeltaSensitivity = 0.25
        end

        mousemoverel(Distance, 0)
    end

    UserInputService.MouseDeltaSensitivity = 1

    mouse1click()
end

local function AlignAim(TargetDirection: Vector3): ()    
    local MovementNeeded, OnScreen = FetchMovementNeeded(TargetDirection)

    if not MovementNeeded then
        return
    end

    while not UserInputService:IsKeyDown("L") and RunService.RenderStepped:Wait() do
        MovementNeeded, OnScreen = FetchMovementNeeded(TargetDirection)

        if math.abs(MovementNeeded.X) <= 1 and OnScreen then
            break
        elseif math.abs(MovementNeeded.X) <= 1 and not OnScreen then
            mousemoverel(Camera.ViewportSize.X * 2, 0)

            continue
        end

        mousemoverel(MovementNeeded.X, 0)
    end
end

local function CopyDirection(): ()
    local Direction = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    setclipboard(`Vector3.new({Direction})`)
end

AutomationsController.CopyDirection = CopyDirection
AutomationsController.AlignAim = AlignAim
AutomationsController.InsertPower = InsertPower

return AutomationsController