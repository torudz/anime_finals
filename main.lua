local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ═══════════════════════════════════════
--   ĐỔI LINK NÀY THÀNH RAW GITHUB CỦA BẠN
-- ═══════════════════════════════════════
local RAW = "https://raw.githubusercontent.com/torudz/anime_finals/main/"

local function loadModule(file)
    local src = game:HttpGet(RAW .. file)
    local fn, err = loadstring(src)
    if not fn then warn("[Loader] Lỗi load " .. file .. ": " .. tostring(err)) return {} end
    return fn()
end

--// SERVICES
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// WINDOW
local Window = Fluent:CreateWindow({
    Title       = "Toru Hub | Anime Finals",
    SubTitle    = "v2",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 380),
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Options = Fluent.Options

--// MOBILE BUTTON (FIX LỖI 1)
local MobileGui = Instance.new("ScreenGui", game.CoreGui)
MobileGui.Name = "ToruMobileBtn"
MobileGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton", MobileGui)
ToggleButton.Size             = UDim2.new(0, 50, 0, 50)
ToggleButton.Position         = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text             = "⚔"
ToggleButton.TextColor3       = Color3.new(1, 1, 1)
ToggleButton.Font             = Enum.Font.GothamBold
ToggleButton.TextSize         = 14
ToggleButton.Draggable        = true
ToggleButton.BorderSizePixel  = 0
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

-- FIX LỖI 1: Window:Minimize() không tồn tại trong Fluent
-- Dùng cách toggle Enabled của ScreenGui thay thế
local fluentGui = nil
ToggleButton.MouseButton1Click:Connect(function()
    -- Tìm Fluent ScreenGui lần đầu
    if not fluentGui then
        for _, gui in ipairs(game.CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "ToruMobileBtn" and gui:FindFirstChildOfClass("Frame") then
                fluentGui = gui
                break
            end
        end
    end
    if fluentGui then
        fluentGui.Enabled = not fluentGui.Enabled
    end
end)

--// TABS
local Tabs = {
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "sword" }),
    Gacha    = Window:AddTab({ Title = "Gacha",     Icon = "star" }),
    Upgrade  = Window:AddTab({ Title = "Upgrade",   Icon = "arrow-up" }),
    Misc     = Window:AddTab({ Title = "Misc",      Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" }),
}

--// LOAD & BUILD UI TỪNG MODULE
local AutoFarm = loadModule("AutoFarm.lua")
local Gacha    = loadModule("Gacha.lua")
local Upgrade  = loadModule("Upgrade.lua")
local Misc     = loadModule("Misc.lua")

if AutoFarm.BuildUI then AutoFarm.BuildUI(Tabs.AutoFarm, Fluent, Options) end
if Gacha.BuildUI    then Gacha.BuildUI(Tabs.Gacha, Fluent, Options)       end
if Upgrade.BuildUI  then Upgrade.BuildUI(Tabs.Upgrade, Fluent, Options)   end
if Misc.BuildUI     then Misc.BuildUI(Tabs.Misc, Fluent, Options)         end

--// SETTINGS
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("ToruHub")
SaveManager:SetFolder("ToruHub/Game2")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title    = "Toru Hub ",
    Content  = "Loaded!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()