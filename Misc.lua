--// MISC MODULE
local Misc = {}

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser   = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local noclipConn  = nil
local rankUpConn  = nil

--// BUILD UI
function Misc.BuildUI(tab, Fluent, Options)

    -- Anti AFK
    tab:AddToggle("AntiAFK", {
        Title    = "Anti AFK",
        Default  = true,
        Callback = function(_) end
    })

    LocalPlayer.Idled:Connect(function()
        if Options.AntiAFK and Options.AntiAFK.Value then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)

    -- Walk Speed
    tab:AddSlider("WalkSpeed", {
        Title    = "Walk Speed",
        Default  = 16,
        Min      = 16,
        Max      = 100,
        Rounding = 0,
        Callback = function(val)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    })

    -- Jump Power
    tab:AddSlider("JumpPower", {
        Title    = "Jump Power",
        Default  = 50,
        Min      = 50,
        Max      = 300,
        Rounding = 0,
        Callback = function(val)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    })

    -- Noclip
    tab:AddToggle("Noclip", {
        Title    = "Noclip",
        Default  = false,
        Callback = function(val)
            if val then
                noclipConn = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            end
        end
    })

    -- Auto Rank Up
    tab:AddToggle("AutoRankUp", {
        Title    = "Auto RankUp",
        Default  = false,
        Callback = function(val)
            if val then
                rankUpConn = RunService.Heartbeat:Connect(function()
                    ReplicatedStorage.Remotes.RankUpEvent:FireServer()
                    task.wait(0.1)
                end)
            else
                if rankUpConn then rankUpConn:Disconnect() rankUpConn = nil end
            end
        end
    })
end

return Misc