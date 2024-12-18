-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local NotificationsController = {}

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
_G.Notifications = {}

-- Delete leftovers
if PlayerGui:FindFirstChild("RVHGUI") then
    local RVHGUI = PlayerGui.RVHGUI:Destroy()
end

-- ScreenGui
local RVHGUI = Instance.new("ScreenGui", PlayerGui)
RVHGUI.ResetOnSpawn = false
RVHGUI.DisplayOrder = 200
RVHGUI.Name = 'RVHGUI'

local function CreateNotification(TitleText, Content, IconId)
    if not Content and not IconId then
        Content = ''
        IconId = ''
    end

    local NotificationGUI = PlayerGui:FindFirstChild("NotificationGUI") or Instance.new("ScreenGui", PlayerGui)
    local Notification = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Header = Instance.new("Frame")
    local UICorner1 = Instance.new("UICorner")
    local Bottom = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
    local Icon = Instance.new("ImageLabel")
    local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    local Description = Instance.new("TextLabel")
    local UITextSizeConstraint1 = Instance.new("UITextSizeConstraint")

    NotificationGUI.Name = 'NotificationGUI'

    Notification.AnchorPoint = Vector2.new(0.5, 0.5)
    Notification.BackgroundColor3 = Color3.fromRGB(30, 31, 37)
    Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Notification.BorderSizePixel = 0
    Notification.Position = UDim2.new(2, 0, 0.75, 0)
    Notification.Size = UDim2.new(0.25, 0, 0.11, 0)
    Notification.Name = "Notification"
    Notification.Parent = NotificationGUI

    UICorner.Parent = Notification

    Header.AnchorPoint = Vector2.new(0.5, 0)
    Header.BackgroundColor3 = Color3.fromRGB(23, 24, 29)
    Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Header.BorderSizePixel = 0
    Header.Position = UDim2.new(0.5, 0, 0, 0)
    Header.Size = UDim2.new(1, 0, 0.2, 0)
    Header.Name = "Header"
    Header.Parent = Notification

    UICorner1.Parent = Header

    Bottom.AnchorPoint = Vector2.new(0.5, 1)
    Bottom.BackgroundColor3 = Color3.fromRGB(23, 24, 29)
    Bottom.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Bottom.BorderSizePixel = 0
    Bottom.Position = UDim2.new(0.5, 0, 1, 0)
    Bottom.Size = UDim2.new(1, 0, 0.5, 0)
    Bottom.Name = "Bottom"
    Bottom.Parent = Header

    Title.Font = Enum.Font.FredokaOne
    Title.Text = TitleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 34
    Title.TextWrapped = true
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.582916796, 0, 0.373000115, 0)
    Title.Size = UDim2.new(0.649999976, 0, 0.400000006, 0)
    Title.Name = "Title"
    Title.Parent = Notification

    UITextSizeConstraint.MaxTextSize = 24
    UITextSizeConstraint.MinTextSize = 12
    UITextSizeConstraint.Parent = Title

    Icon.Image = IconId
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.BackgroundTransparency = 1
    Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Icon.BorderSizePixel = 0
    Icon.Position = UDim2.new(0.0250000004, 0, 0.600000024, 0)
    Icon.Size = UDim2.new(0.375, 0, 0.625, 0)
    Icon.Name = "Icon"
    Icon.Parent = Notification

    UIAspectRatioConstraint.Parent = Icon

    Description.Font = Enum.Font.FredokaOne
    Description.Text = Content
    Description.TextColor3 = Color3.fromRGB(175.00000476837158, 175.00000476837158, 175.00000476837158)
    Description.TextSize = 6
    Description.TextWrapped = true
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.AnchorPoint = Vector2.new(0.5, 0.5)
    Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Description.BackgroundTransparency = 1
    Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Description.BorderSizePixel = 0
    Description.Position = UDim2.new(0.61013478, 0, 0.75698185, 0)
    Description.Size = UDim2.new(0.75, 0, 0.469000012, 0)
    Description.Name = "Description"
    Description.Parent = Notification

    UITextSizeConstraint1.MaxTextSize = 24
    UITextSizeConstraint1.MinTextSize = 14
    UITextSizeConstraint1.Parent = Description

    return Notification
end

local function Notify(TitleText, Content, IconId)
    task.spawn(function()
        if not IconId then
            IconId = ''
        end

        local NewNotification = CreateNotification(TitleText, Content, IconId)
        table.insert(_G.Notifications, NewNotification)

        TweenService:Create(NewNotification, TweenInfo.new(1/3), {Position = UDim2.fromScale(0.862, NewNotification.Position.Y.Scale - (#_G.Notifications - 1) * 0.14)}):Play()
        
        task.wait(1.5)

        table.remove(_G.Notifications, table.find(_G.Notifications, NewNotification))

        TweenService:Create(NewNotification, TweenInfo.new(1), {Position = UDim2.fromScale(2, NewNotification.Position.Y.Scale)}):Play() 
        
        task.delay(1, function()            
            NewNotification:Destroy()
        end)
    end)
end

NotificationsController.Notify = Notify

return NotificationsController