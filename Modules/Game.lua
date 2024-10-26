-- Services
local Players = game:GetService("Players")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local MainFrame = PlayerGui:WaitForChild("MainGui").MainFrame

-- Modules
local GameController = {}

-- Functions
local function FetchBallVisual(): Instance
    local GolfBallsFolder = workspace:WaitForChild("GolfBalls")
    local GolfBallsHighlightedFolder = workspace:WaitForChild("GolfBallsHighlighted")

    local function FindBallInFolder(Folder: Folder): ()
        for _, Ball in Folder:GetChildren() do
            if Ball.Name ~= 'BallVisual' then
                continue
            end
    
            local Nametag = Ball.Anchor.Primary.Nametag
            local NametagContent = Nametag.TextLabel.Text
    
            if NametagContent == 'YOU' then
                return Ball
            end
        end
    end

    local BallVisual = FindBallInFolder(GolfBallsFolder) or FindBallInFolder(GolfBallsHighlightedFolder)

    if not BallVisual then
        return warn('LocalBallVisual not found | 01')
    end

    return BallVisual
end

local function FetchLocalBall()
    local BallVisual = FetchBallVisual()

    if not BallVisual then
        return
    end

    local Origin = BallVisual:GetPivot().Position * Vector3.new(1, 0, 1)
    local NearestDistance, NearestBall = math.huge, nil

    for _, Ball in workspace:GetChildren() do
        if Ball.Name ~= '+GolfBall' then
            continue
        end

        local CurrentBallPosition = Ball:GetPivot().Position * Vector3.new(1, 0, 1)
        local DistanceFromOrigin = (CurrentBallPosition - Origin).Magnitude
    
        if DistanceFromOrigin < NearestDistance then
            NearestDistance = DistanceFromOrigin
            NearestBall = Ball
        end
    end

    if not NearestBall then
        return warn('LocalBall not found | 02')
    end

    return NearestBall
end

local function FetchPower(): (number, boolean)
    local Bar = MainFrame.Mechanics.Power.Container.Bar
    local PowerValue = tonumber(Bar.Value.Text)
    local IsActive = MainFrame.Mechanics.Power.Visible

    return PowerValue, IsActive
end

local function FetchMap(): string
    local Scoreboard = MainFrame.Playing.Scoreboard
    local Map = Scoreboard.Container.BottomBar.Map.Text

    return Map
end

local function FetchHole(): string
    local Scoreboard = MainFrame.Playing.Scoreboard
    
    for _, Hole in Scoreboard.Container.TopBar.Holes:GetChildren() do
        if Hole.Title.TextColor3.R == 1 then
            return Hole.Title.Text
        end
    end
end

GameController.FetchMap = FetchMap
GameController.FetchHole = FetchHole
GameController.FetchLocalBall = FetchLocalBall
GameController.FetchCurrentPower = FetchPower

return GameController