--[[ 
    FE2 TAS UI Library 
    Upload this to a raw link (e.g. GitHub/Pastebin)
]]

local TAS_UI = {}

function TAS_UI.Create()
    local CoreGui = game:GetService("CoreGui")
    
    -- Main ScreenGui
    local HUD = Instance.new("ScreenGui")
    HUD.Name = "TAS_HUD"
    HUD.Parent = CoreGui
    HUD.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    HUD.ResetOnSpawn = false

    -- Container Frame (to replicate the original positioning)
    local HUDFrame = Instance.new("Frame")
    HUDFrame.Name = "HUD"
    HUDFrame.Parent = HUD
    HUDFrame.AnchorPoint = Vector2.new(0.5, 0)
    HUDFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    HUDFrame.BackgroundTransparency = 1.000
    HUDFrame.Position = UDim2.new(0.5, 0, 0.89, 0)
    HUDFrame.Size = UDim2.new(1, 0, 0.0825, 0)
    HUDFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = HUDFrame
    Main.BackgroundTransparency = 1.000
    Main.Size = UDim2.new(1, 0, 1, 0)

    -- Game Stats Container
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = Main
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.Position = UDim2.new(0.33, 0, 0.178, 0)
    GameStats.Size = UDim2.new(0, 348, 0, 73)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = GameStats

    -- Time Display
    local TimeText = Instance.new("TextLabel")
    TimeText.Name = "TimeText"
    TimeText.Parent = GameStats
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.017, 0, 0.162, 0)
    TimeText.Size = UDim2.new(0.5, 0, 0.7, 0)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00.000"
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeText.TextScaled = true
    TimeText.TextWrapped = true

    -- Savestates Counter
    local SavestatesCount = Instance.new("TextLabel")
    SavestatesCount.Name = "SavestatesCount"
    SavestatesCount.Parent = GameStats
    SavestatesCount.BackgroundTransparency = 1.000
    SavestatesCount.Position = UDim2.new(0, 190, 0, 0)
    SavestatesCount.Size = UDim2.new(0, 149, 0, 33)
    SavestatesCount.Font = Enum.Font.Highway
    SavestatesCount.Text = "Savestates 0"
    SavestatesCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavestatesCount.TextScaled = true

    -- Frames Counter
    local FrameCount = Instance.new("TextLabel")
    FrameCount.Name = "FrameCount"
    FrameCount.Parent = GameStats
    FrameCount.BackgroundTransparency = 1.000
    FrameCount.Position = UDim2.new(0, 190, 0, 20)
    FrameCount.Size = UDim2.new(0, 149, 0, 33)
    FrameCount.Font = Enum.Font.Highway
    FrameCount.Text = "Frames 0"
    FrameCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    FrameCount.TextScaled = true

    -- Keybind Toggle Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindToggle"
    KeybindButton.Parent = GameStats
    KeybindButton.BackgroundTransparency = 1.000
    KeybindButton.Position = UDim2.new(0, 190, 0, 42)
    KeybindButton.Size = UDim2.new(0, 149, 0, 33)
    KeybindButton.Font = Enum.Font.Highway
    KeybindButton.Text = "Show Keybinds"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 20.000

    -- Keybind Information Frame (Hidden by default)
    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBindFrame"
    KeyBindFrame.Parent = Main
    KeyBindFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    KeyBindFrame.BackgroundTransparency = 0.2
    KeyBindFrame.Position = UDim2.new(0.55, 0, -2.4, 0)
    KeyBindFrame.Size = UDim2.new(0, 278, 3.5, 0)
    KeyBindFrame.Visible = false

    local KeyListLayout = Instance.new("UIListLayout")
    KeyListLayout.Parent = KeyBindFrame
    KeyListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    KeyListLayout.Padding = UDim.new(0, -4)

    -- Helper function to create info labels
    local function CreateInfoLabel(text)
        local Label = Instance.new("TextLabel")
        Label.Parent = KeyBindFrame
        Label.BackgroundTransparency = 1.000
        Label.Size = UDim2.new(1, 0, 0.113, 0)
        Label.Font = Enum.Font.Highway
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextScaled = true
        return Label
    end

    local CapLockStatus = CreateInfoLabel("CapsLock : Unpaused")
    CreateInfoLabel("One : Add a Savestate")
    CreateInfoLabel("Two : Remove a Savestate")
    CreateInfoLabel("Three : Go To Last SaveState")
    CreateInfoLabel("Four : Go Back a Frame")
    CreateInfoLabel("Five : Go a Frame Forward")
    CreateInfoLabel("Six : SaveRun")
    CreateInfoLabel("C : CanCollide Toggle")
    CreateInfoLabel("Delete: Stop Creating")
    CreateInfoLabel("Zero: View TAS")

    -- Map Event Info
    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Parent = HUD
    MapEventInfo.BackgroundTransparency = 1
    MapEventInfo.Position = UDim2.new(0.5, 0, 0.1, 0)
    MapEventInfo.Size = UDim2.new(0, 200, 0, 50)
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255,255,255)
    MapEventInfo.Font = Enum.Font.Highway
    MapEventInfo.TextSize = 24

    -- Toggle Logic
    KeybindButton.Activated:Connect(function()
        KeyBindFrame.Visible = not KeyBindFrame.Visible
        if KeyBindFrame.Visible then
            KeybindButton.Text = "Hide Keybinds"
        else
            KeybindButton.Text = "Show Keybinds"
        end
    end)

    -- Return table of objects the script needs to control
    return {
        ScreenGui = HUD,
        TimeText = TimeText,
        SavestatesCount = SavestatesCount,
        FrameCount = FrameCount,
        KeybindButton = KeybindButton,
        StatusText = CapLockStatus,
        MapEventInfo = MapEventInfo
    }
end

return TAS_UI
