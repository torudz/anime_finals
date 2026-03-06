```lua
--// AUTO FARM MODULE
local AutoFarm = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local camera      = workspace.CurrentCamera
local HitRemote   = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AttackEvent")

local Config = {
    AutoFarm      = false,
    SelectedMob   = "Nemo",
    SelectedWorld = "World 1",
}

local WorldList = { "World 1", "World 2", "World 3", "World 4", "World 5" }

-- Lấy danh sách mob trong Enemies
local function getMobNames()
    local names, seen = {}, {}
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not seen[mob.Name] then
                seen[mob.Name] = true
                table.insert(names, mob.Name)
            end
        end
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "(Chưa có mob)")
    end
    return names
end

-- Tìm mob gần nhất
local function findNearestMob()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, nearestDist = nil, math.huge
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end

    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name == Config.SelectedMob then
            local root = mob:FindFirstChild("HumanoidRootPart")
                      or mob:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest     = root
                end
            end
        end
    end
    return nearest
end

-- Đánh mob
local function attackMob(mobPart)
    if not mobPart or not mobPart.Parent then return end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.CFrame = CFrame.new(mobPart.Position + Vector3.new(0, 0, 2.5))
    task.wait()

    local screenPos, onScreen = camera:WorldToScreenPoint(mobPart.Position)
    if onScreen then
        VirtualUser:ClickButton1(Vector2.new(screenPos.X, screenPos.Y), camera.CFrame)
    end

    HitRemote:FireServer()
end

-- Farm loop
RunService.Heartbeat:Connect(function()
    if not Config.AutoFarm then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local mob = findNearestMob()
    if mob then attackMob(mob) end
end)

-- Build UI
function AutoFarm.BuildUI(tab, Fluent, Options)

    local function refreshMobDropdown()
        local names = getMobNames()
        if Options.MobSelect then
            Options.MobSelect:SetValues(names)
            Options.MobSelect:SetValue(names[1] or "")
            Config.SelectedMob = names[1] or "Nemo"
        end
        return #names
    end

    tab:AddParagraph({
        Title   = "Auto Farm",
        Content = "Chọn World → Chọn Mob → Bật farm."
    })

    tab:AddDropdown("WorldSelect", {
        Title    = "Chọn World",
        Values   = WorldList,
        Default  = Config.SelectedWorld,
        Callback = function(val)
            Config.SelectedWorld = val
            Config.AutoFarm      = false

            Fluent:Notify({
                Title   = "⏳ Đổi sang " .. val,
                Content = "Đang chờ map load...",
                Duration = 3
            })

            task.delay(3, function()
                local count = refreshMobDropdown()
                Fluent:Notify({
                    Title   = "✅ " .. val,
                    Content = count .. " mob tìm thấy",
                    Duration = 3
                })
            end)
        end
    })

    tab:AddDropdown("MobSelect", {
        Title    = "Chọn Mob",
        Values   = getMobNames(),
        Default  = Config.SelectedMob,
        Callback = function(val)
            Config.SelectedMob = val
        end
    })

    tab:AddToggle("AutoFarmToggle", {
        Title    = "Auto Farm",
        Default  = false,
        Callback = function(val)
            Config.AutoFarm = val
            Fluent:Notify({
                Title    = val and "⚔️ Auto Farm BẬT" or "🛑 Auto Farm TẮT",
                Content  = val and (Config.SelectedMob .. " @ " .. Config.SelectedWorld) or "Đã dừng.",
                Duration = 2
            })
        end
    })

    tab:AddButton({
        Title       = "🔄 Refresh Mob List",
        Description = "Cập nhật lại danh sách mob trong map",
        Callback    = function()
            local count = refreshMobDropdown()
            Fluent:Notify({
                Title   = "🔄 Đã refresh!",
                Content = count .. " mob tìm thấy",
                Duration = 2
            })
        end
    })
end

return AutoFarm
```