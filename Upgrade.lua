--// UPGRADE MODULE
local Upgrade = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local Remotes         = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeRemote   = Remotes:WaitForChild("RequestProgressionUpgrade")
local PowerRollRemote = Remotes:WaitForChild("RequestPowerRoll")

-- FIX LỖI 3: mỗi conn dùng biến riêng, không gán nhầm
local hakiConn  = nil
local chakraConn = nil
local fruitConn = nil
local raceConn  = nil   
local bijuConn = nil
local taijutsuConn = nil

--// BUILD UI
function Upgrade.BuildUI(tab, Fluent, Options)
    tab:AddParagraph({
        Title   = "Auto Upgrade",
        Content = "Tự động upgrade Haki và roll Fruit / Race."
    })

    -- Auto Haki
    tab:AddToggle("AutoChakra", {
        Title       = "Auto Chakra Upgrade",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                chakraConn = RunService.Heartbeat:Connect(function()
                    UpgradeRemote:InvokeServer("Chakra")
                    task.wait()
                end)
            else
                if chakraConn then chakraConn:Disconnect() chakraConn = nil end
            end
        end
    })

tab:AddToggle("AutoHaki", {
        Title       = "Auto Haki Upgrade",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                hakiConn = RunService.Heartbeat:Connect(function()
                    UpgradeRemote:InvokeServer("Haki")
                    task.wait()
                end)
            else
                if hakiConn then hakiConn:Disconnect() hakiConn = nil end
            end
        end
    })
tab:AddToggle("AutoTaijutsu", {
        Title       = "Auto Taijutsu Upgrade",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                taijutsuConn = RunService.Heartbeat:Connect(function()
                    UpgradeRemote:InvokeServer("Taijutsu")
                    task.wait()
                end)
            else
                if taijutsuConn then taijutsuConn:Disconnect() taijutsuConn = nil end
            end
        end
    })

    -- Auto Fruit Roll
    tab:AddToggle("AutoFruitRoll", {
        Title       = "Auto Fruit Roll",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                fruitConn = RunService.Heartbeat:Connect(function()  -- ← fruitConn
                    PowerRollRemote:InvokeServer("Fruit")
                    task.wait()
                end)
            else
                if fruitConn then fruitConn:Disconnect() fruitConn = nil end
            end
        end
    })

    -- Auto Race Roll (FIX: dùng raceConn, không phải fruitConn)
    tab:AddToggle("AutoRaceRoll", {
        Title       = "Auto Race Roll",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                raceConn = RunService.Heartbeat:Connect(function()   -- ← raceConn
                    PowerRollRemote:InvokeServer("Race")
                    task.wait()
                end)
            else
                if raceConn then raceConn:Disconnect() raceConn = nil end  -- ← raceConn
            end
        end
    })

tab:AddToggle("AutoBijuRoll", {
        Title       = "Auto biju Roll",
        Description = "",
        Default     = false,
        Callback    = function(val)
            if val then
                bijuConn = RunService.Heartbeat:Connect(function()   
                    PowerRollRemote:InvokeServer("Biju")
                    task.wait()
                end)
            else
                if bijuConn then bijuConn:Disconnect() bijuConn = nil end  
            end
        end
    })
end

return Upgrade