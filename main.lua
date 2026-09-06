--[[
    Cold War ESP v3 — LinoriaLib UI Edition (With Key System)
    Highlight คลุมทั้งตัวละคร ทะลุกำแพงได้ + Box ESP + Aimbot + Key System
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- =========================================================================
--  🔑 KEY SYSTEM CONFIGURATION
-- =========================================================================
local KeyConfig = {
    -- ลิงก์สำหรับรับ Key (แก้ไขเป็นลิงก์ Linkvertise, Discord, หรือเว็บของคุณได้)
    GetKeyURL = "https://discord.gg/yourserver", 
    KeySaveFile = "ColdWar_SavedKey.txt",
    
    -- รายการคีย์ที่ถูกต้อง (เพิ่ม/แก้ไขได้ที่นี่)
    ValidKeys = {
        ["COLDWAR-OWNER-AONMO-2026-VIP"] = true,  -- ⭐ คีย์ส่วนตัวของคุณโดยเฉพาะ (VIP Owner)
        ["COLDWAR-MASTER-7789-KEY"]    = true,  -- สำรอง
    }
}

-- ฟังก์ชันตรวจสอบว่า Key ถูกต้องหรือไม่
local function VerifyKey(inputKey)
    if not inputKey then return false end
    -- ตัดช่องว่างหัวท้าย
    local trimmed = string.gsub(inputKey, "^%s*(.-)%s*$", "%1")
    return KeyConfig.ValidKeys[trimmed] == true
end

-- ตรวจสอบ Key ที่เซฟไว้ในเครื่อง (ถ้ามีและถูกต้อง จะข้ามหน้า Key ไปเลย)
local savedKeyValid = false
pcall(function()
    if isfile and isfile(KeyConfig.KeySaveFile) then
        local saved = readfile(KeyConfig.KeySaveFile)
        if VerifyKey(saved) then
            savedKeyValid = true
        end
    end
end)

-- ฟังก์ชันรันโปรแกรมหลักหลังจากผ่าน Key แล้ว
local function StartMainScript()
    -- ====== โหลด LinoriaLib (ใช้ repo ที่ถูกต้อง: violin-suzutsuki) ======
    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

    local success, Library = pcall(function()
        return loadstring(game:HttpGet(repo .. 'Library.lua'))()
    end)

    if not success or not Library then
        warn("[Cold War ESP] กำลังลอง repo สำรอง...")
        local fallbackRepo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
        local fbSuccess, fbLib = pcall(function()
            return loadstring(game:HttpGet(fallbackRepo .. 'Library.lua'))()
        end)
        if fbSuccess and fbLib then
            Library = fbLib
            repo = fallbackRepo
        else
            error("[Cold War ESP Error] ล้มเหลวในการดาวน์โหลด LinoriaLib! ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต")
        end
    end

    local ThemeManager, SaveManager
    pcall(function()
        ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    end)
    pcall(function()
        SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
    end)

    -- ====== ตั้งค่าเริ่มต้น (ปิดทั้งหมดให้ผู้ใช้เลือกเปิดเอง) ======
    local Settings = {
        ESP = {
            Enabled = false,
            BoxEnabled = false,
            HighlightEnabled = false,
            TargetFilter = "All",
            TeamColorSelf = Color3.fromRGB(0, 255, 100),
            TeamColorEnemy = Color3.fromRGB(255, 50, 50),
            NameColor = Color3.fromRGB(255, 255, 255),
            DistanceColor = Color3.fromRGB(200, 200, 200),
            MaxDistance = 350,
            ShowName = false,
            ShowDistance = false,
            ShowHP = false,
        },
        Aimbot = {
            Enabled = false,
            Silent = false,
            Smoothness = 0.15,
            FOV = 120,
            AimPart = "Head",
            TriggerbotEnabled = false,
            TriggerbotTeamCheck = true,
            TriggerbotDelay = 0.02,
        },
        Misc = {
            WalkSpeedEnabled = false,
            WalkSpeed = 16,
            NoclipEnabled = false,
            InfiniteJumpEnabled = false,
        },
    }

    -- ฟังก์ชันหา Team
    local function GetPlayerTeam(plr)
        if plr.Team then
            return plr.Team.Name
        end
        local char = plr.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            if humanoid:FindFirstChild("Team") then
                return humanoid.Team.Value
            end
            if humanoid:GetAttribute("Team") then
                return humanoid:GetAttribute("Team")
            end
        end
        return nil
    end

    -- ====== สร้าง LinoriaLib Window ======
    local Window = Library:CreateWindow({
        Title = 'Cold War ESP v3 [BZMEMBER]',
        Center = true,
        AutoShow = true,
    })

    local Tabs = {
        ESP = Window:AddTab('ESP'),
        Aimbot = Window:AddTab('Aimbot'),
        Misc = Window:AddTab('Misc'),
        ['UI Settings'] = Window:AddTab('UI Settings'),
    }

    -- ==========================================
    --  แท็บ ESP
    -- ==========================================
    local ESPLeft = Tabs.ESP:AddLeftGroupbox('ESP Settings')
    local ESPRight = Tabs.ESP:AddRightGroupbox('Display Options')

    ESPLeft:AddToggle('ESPEnabled', {
        Text = 'ESP Enabled',
        Default = false,
        Tooltip = 'เปิด/ปิด ESP ทั้งหมด',
    })

    ESPLeft:AddToggle('BoxEnabled', {
        Text = 'Box ESP',
        Default = false,
        Tooltip = 'แสดงกรอบสี่เหลี่ยมรอบตัวละคร',
    })

    ESPLeft:AddToggle('HighlightEnabled', {
        Text = 'Highlight (Full Body)',
        Default = false,
        Tooltip = 'Highlight คลุมทั้งตัวละคร ทะลุกำแพง',
    })

    ESPLeft:AddDivider()

    ESPLeft:AddDropdown('TargetFilter', {
        Values = { 'All', 'Enemy', 'Team' },
        Default = 1,
        Multi = false,
        Text = 'ESP Target',
        Tooltip = 'เลือกว่าจะแสดง ESP ของฝ่ายไหน',
    })

    ESPLeft:AddSlider('MaxDistance', {
        Text = 'Max Distance',
        Default = 350,
        Min = 50,
        Max = 1000,
        Rounding = 0,
    })

    ESPLeft:AddDivider()

    ESPLeft:AddLabel('Team Color'):AddColorPicker('TeamColorSelf', {
        Default = Color3.fromRGB(0, 255, 100),
        Title = 'สีทีมตัวเอง',
    })

    ESPLeft:AddLabel('Enemy Color'):AddColorPicker('TeamColorEnemy', {
        Default = Color3.fromRGB(255, 50, 50),
        Title = 'สีฝ่ายตรงข้าม',
    })

    ESPRight:AddToggle('ShowName', { Text = 'Show Name', Default = false })
    ESPRight:AddToggle('ShowDistance', { Text = 'Show Distance', Default = false })
    ESPRight:AddToggle('ShowHP', { Text = 'Show HP', Default = false })
    ESPRight:AddDivider()

    ESPRight:AddLabel('Name Color'):AddColorPicker('NameColor', {
        Default = Color3.fromRGB(255, 255, 255),
        Title = 'สีชื่อ',
    })

    ESPRight:AddLabel('Distance Color'):AddColorPicker('DistanceColor', {
        Default = Color3.fromRGB(200, 200, 200),
        Title = 'สีระยะทาง',
    })

    -- ==========================================
    --  แท็บ Aimbot
    -- ==========================================
    local AimLeft = Tabs.Aimbot:AddLeftGroupbox('Aimbot Settings')
    local AimRight = Tabs.Aimbot:AddRightGroupbox('Aim Options')

    AimLeft:AddToggle('AimbotEnabled', { Text = 'Aimbot Enabled', Default = false })
    AimLeft:AddToggle('SilentAim', { Text = 'Smooth Aim', Default = false, Tooltip = 'Smooth aim แทนการ snap ทันที' })
    AimLeft:AddDivider()

    AimLeft:AddDropdown('AimPart', {
        Values = { 'Head', 'Torso' },
        Default = 1,
        Multi = false,
        Text = 'Aim Part',
        Tooltip = 'เลือกตำแหน่งล็อคเป้า',
    })

    AimLeft:AddLabel('Aim Keybind'):AddKeyPicker('AimKeybind', {
        Default = 'Q',
        SyncToggleState = false,
        Mode = 'Hold',
        Text = 'Aim Lock Key',
        NoUI = false,
    })

    AimRight:AddSlider('AimFOV', { Text = 'FOV (px)', Default = 120, Min = 30, Max = 500, Rounding = 0 })
    AimRight:AddSlider('AimSmoothness', { Text = 'Smoothness', Default = 0.15, Min = 0.01, Max = 1, Rounding = 2, Compact = false })

    AimRight:AddDivider()
    AimRight:AddLabel('Triggerbot')

    AimRight:AddToggle('TriggerbotEnabled', {
        Text = 'Enable Triggerbot',
        Default = false,
        Tooltip = 'ยิงอัตโนมัติทันทีเมื่อเป้าเล็งชี้โดนศัตรู',
    })

    AimRight:AddToggle('TriggerbotTeamCheck', {
        Text = 'Team Check',
        Default = true,
        Tooltip = 'ไม่ยิงเพื่อนร่วมทีม',
    })

    AimRight:AddSlider('TriggerbotDelay', {
        Text = 'Shoot Delay (s)',
        Default = 0.02,
        Min = 0,
        Max = 0.5,
        Rounding = 2,
        Compact = false,
    })

    AimRight:AddLabel('Trigger Key'):AddKeyPicker('TriggerKeybind', {
        Default = 'MB2',
        SyncToggleState = false,
        Mode = 'Always',
        Text = 'Triggerbot Key',
        NoUI = false,
    })

    -- ==========================================
    --  แท็บ Misc (Miscellaneous)
    -- ==========================================
    local MiscMovement = Tabs.Misc:AddLeftGroupbox('Movement')
    local MiscCharacter = Tabs.Misc:AddRightGroupbox('Character Mods')

    MiscMovement:AddToggle('WalkSpeedEnabled', {
        Text = 'Enable WalkSpeed',
        Default = false,
        Tooltip = 'เปิด/ปิด ปรับความเร็วการเดิน',
    })

    MiscMovement:AddSlider('WalkSpeedSlider', {
        Text = 'WalkSpeed',
        Default = 16,
        Min = 16,
        Max = 250,
        Rounding = 0,
        Compact = false,
    })

    MiscMovement:AddDivider()

    MiscMovement:AddToggle('InfiniteJump', {
        Text = 'Infinite Jump',
        Default = false,
        Tooltip = 'กระโดดกลางอากาศได้ไม่จำกัด (กด Spacebar ได้ตลอดเวลา)',
    })

    MiscCharacter:AddToggle('Noclip', {
        Text = 'Noclip',
        Default = false,
        Tooltip = 'เดินทะลุกำแพงและสิ่งกีดขวางทั้งหมด',
    })

    -- ==========================================
    --  แท็บ UI Settings
    -- ==========================================
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    MenuGroup:AddButton('Unload Script', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

    Library.ToggleKeybind = Options.MenuKeybind

    -- Event Listeners
    Toggles.ESPEnabled:OnChanged(function() Settings.ESP.Enabled = Toggles.ESPEnabled.Value end)
    Toggles.BoxEnabled:OnChanged(function() Settings.ESP.BoxEnabled = Toggles.BoxEnabled.Value end)
    Toggles.HighlightEnabled:OnChanged(function() Settings.ESP.HighlightEnabled = Toggles.HighlightEnabled.Value end)
    Toggles.ShowName:OnChanged(function() Settings.ESP.ShowName = Toggles.ShowName.Value end)
    Toggles.ShowDistance:OnChanged(function() Settings.ESP.ShowDistance = Toggles.ShowDistance.Value end)
    Toggles.ShowHP:OnChanged(function() Settings.ESP.ShowHP = Toggles.ShowHP.Value end)
    Toggles.AimbotEnabled:OnChanged(function() Settings.Aimbot.Enabled = Toggles.AimbotEnabled.Value end)
    Toggles.SilentAim:OnChanged(function() Settings.Aimbot.Silent = Toggles.SilentAim.Value end)

    Options.TargetFilter:OnChanged(function() Settings.ESP.TargetFilter = Options.TargetFilter.Value end)
    Options.MaxDistance:OnChanged(function() Settings.ESP.MaxDistance = Options.MaxDistance.Value end)
    Options.TeamColorSelf:OnChanged(function() Settings.ESP.TeamColorSelf = Options.TeamColorSelf.Value end)
    Options.TeamColorEnemy:OnChanged(function() Settings.ESP.TeamColorEnemy = Options.TeamColorEnemy.Value end)
    Options.NameColor:OnChanged(function() Settings.ESP.NameColor = Options.NameColor.Value end)
    Options.DistanceColor:OnChanged(function() Settings.ESP.DistanceColor = Options.DistanceColor.Value end)

    Options.AimPart:OnChanged(function()
        Settings.Aimbot.AimPart = (Options.AimPart.Value == "Torso") and "HumanoidRootPart" or "Head"
    end)

    Options.AimFOV:OnChanged(function() Settings.Aimbot.FOV = Options.AimFOV.Value end)
    Options.AimSmoothness:OnChanged(function() Settings.Aimbot.Smoothness = Options.AimSmoothness.Value end)

    Toggles.TriggerbotEnabled:OnChanged(function()
        Settings.Aimbot.TriggerbotEnabled = Toggles.TriggerbotEnabled.Value
    end)

    Toggles.TriggerbotTeamCheck:OnChanged(function()
        Settings.Aimbot.TriggerbotTeamCheck = Toggles.TriggerbotTeamCheck.Value
    end)

    Options.TriggerbotDelay:OnChanged(function()
        Settings.Aimbot.TriggerbotDelay = Options.TriggerbotDelay.Value
    end)

    -- Event Listeners: Misc
    Toggles.WalkSpeedEnabled:OnChanged(function()
        Settings.Misc.WalkSpeedEnabled = Toggles.WalkSpeedEnabled.Value
        if not Settings.Misc.WalkSpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end)

    Options.WalkSpeedSlider:OnChanged(function()
        Settings.Misc.WalkSpeed = Options.WalkSpeedSlider.Value
        if Settings.Misc.WalkSpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Settings.Misc.WalkSpeed end
        end
    end)

    Toggles.InfiniteJump:OnChanged(function()
        Settings.Misc.InfiniteJumpEnabled = Toggles.InfiniteJump.Value
    end)

    Toggles.Noclip:OnChanged(function()
        Settings.Misc.NoclipEnabled = Toggles.Noclip.Value
    end)

    -- Theme & Save Manager
    if ThemeManager then
        pcall(function()
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder('ColdWarESPv3')
            ThemeManager:ApplyToTab(Tabs['UI Settings'])
        end)
    end

    if SaveManager then
        pcall(function()
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
            SaveManager:SetFolder('ColdWarESPv3/config')
            SaveManager:BuildConfigSection(Tabs['UI Settings'])
        end)
    end

    -- ====== ESP + Highlight System ======
    local ESPObjects = {}
    local HighlightObjects = {}

    local function CreateHighlight(plr)
        if HighlightObjects[plr] then return end
        local char = plr.Character
        if not char then return end

        local hl = Instance.new("Highlight")
        hl.Name = "ColdWarESP_HL"
        hl.Adornee = char
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false
        hl.Parent = char

        HighlightObjects[plr] = hl

        char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if HighlightObjects[plr] then
                    pcall(function() HighlightObjects[plr]:Destroy() end)
                    HighlightObjects[plr] = nil
                end
            end
        end)
    end

    local function CreateESPObject(plr)
        if ESPObjects[plr] then return end
        local hasDrawing = pcall(function() return Drawing.new("Square") end)
        if not hasDrawing then return end

        ESPObjects[plr] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HP = Drawing.new("Text"),
        }
        local obj = ESPObjects[plr]
        obj.Box.Thickness = 1.5
        obj.Box.Filled = false
        obj.Name.Center = true
        obj.Name.Outline = true
        obj.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
        obj.Distance.Center = true
        obj.Distance.Outline = true
        obj.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        obj.HP.Center = true
        obj.HP.Outline = true
        obj.HP.OutlineColor = Color3.fromRGB(0, 0, 0)
    end

    local function HideESP(obj, hl)
        if obj then
            if obj.Box then obj.Box.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.Distance then obj.Distance.Visible = false end
            if obj.HP then obj.HP.Visible = false end
        end
        if hl then hl.Enabled = false end
    end

    local function UpdateESP()
        for plr, obj in pairs(ESPObjects) do
            local hl = HighlightObjects[plr]

            if not plr or not plr.Character then
                HideESP(obj, hl)
                continue
            end

            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
                HideESP(obj, hl)
                continue
            end

            if not hl or not hl.Parent then
                CreateHighlight(plr)
                hl = HighlightObjects[plr]
            end

            -- คำนวณขอบเขตตัวละครทั้งตัว (หัวถึงเท้า) รองรับทั้ง R6, R15 และชุดเกราะ/หมวก
            local head = char:FindFirstChild("Head")
            local topPos = head and (head.Position + Vector3.new(0, 1.3, 0)) or (root.Position + Vector3.new(0, 3.2, 0))
            
            local bottomPos
            local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")
            local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
            if leftLeg and rightLeg then
                local lowerLeg = (leftLeg.Position.Y < rightLeg.Position.Y) and leftLeg or rightLeg
                bottomPos = lowerLeg.Position - Vector3.new(0, (lowerLeg.Size.Y / 2) + 0.2, 0)
            else
                local hip = humanoid.HipHeight
                if not hip or hip <= 0.1 then
                    hip = 1.5
                end
                bottomPos = root.Position - Vector3.new(0, hip + 1.6, 0)
            end

            local topScreen, topOn = Camera:WorldToViewportPoint(topPos)
            local bottomScreen, bottomOn = Camera:WorldToViewportPoint(bottomPos)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude

            local playerTeam = GetPlayerTeam(plr)
            local isSelf = (plr == LocalPlayer)
            local isSameTeam = (playerTeam == GetPlayerTeam(LocalPlayer)) and not isSelf
            local isEnemy = not isSelf and not isSameTeam
            local teamColor = isSelf and Settings.ESP.TeamColorSelf or (isSameTeam and Settings.ESP.TeamColorSelf or Settings.ESP.TeamColorEnemy)

            local filter = Settings.ESP.TargetFilter
            local shouldShow = true
            if filter == "Enemy" and not isEnemy then
                shouldShow = false
            elseif filter == "Team" and not (isSameTeam or isSelf) then
                shouldShow = false
            end

            if not shouldShow then
                HideESP(obj, hl)
                continue
            end

            -- Highlight 3D (คลุมทั้งโมเดล 3D ทะลุกำแพง)
            if hl then
                if Settings.ESP.Enabled and Settings.ESP.HighlightEnabled and distance <= Settings.ESP.MaxDistance then
                    hl.FillColor = teamColor
                    hl.OutlineColor = teamColor
                    hl.Adornee = char
                    hl.Enabled = true
                else
                    hl.Enabled = false
                end
            end

            -- 2D Drawing Box, Name, Distance, HP
            -- ตรวจสอบว่าอยู่หน้ากล้องและระยะไม่เกินกำหนด
            if topScreen.Z <= 0 or (not topOn and not bottomOn) or distance > Settings.ESP.MaxDistance then
                obj.Box.Visible = false
                obj.Name.Visible = false
                obj.Distance.Visible = false
                obj.HP.Visible = false
                continue
            end

            local height = math.abs(topScreen.Y - bottomScreen.Y)
            local width = height * 0.55
            local centerX = (topScreen.X + bottomScreen.X) / 2
            local topY = math.min(topScreen.Y, bottomScreen.Y)

            -- Box (กรอบคลุมทั้งตัวละครตั้งแต่หมวกจนถึงเท้า)
            obj.Box.Size = Vector2.new(width, height)
            obj.Box.Position = Vector2.new(centerX - width / 2, topY)
            obj.Box.Color = teamColor
            obj.Box.Visible = Settings.ESP.Enabled and Settings.ESP.BoxEnabled

            -- ชื่อ (อยู่เหนือหมวก)
            obj.Name.Text = plr.DisplayName or plr.Name
            obj.Name.Color = Settings.ESP.NameColor
            obj.Name.Size = 14
            obj.Name.Position = Vector2.new(centerX, topY - 16)
            obj.Name.Visible = Settings.ESP.Enabled and Settings.ESP.ShowName

            -- ระยะ (อยู่ใต้เท้า)
            obj.Distance.Text = tostring(math.floor(distance)) .. "m"
            obj.Distance.Color = Settings.ESP.DistanceColor
            obj.Distance.Size = 12
            obj.Distance.Position = Vector2.new(centerX, topY + height + 3)
            obj.Distance.Visible = Settings.ESP.Enabled and Settings.ESP.ShowDistance

            -- HP (อยู่ใต้ระยะ)
            local hpPercent = humanoid.Health / humanoid.MaxHealth * 100
            obj.HP.Text = string.format("%.0f%%", hpPercent)
            obj.HP.Color = hpPercent > 50 and Color3.fromRGB(0, 255, 0) or (hpPercent > 25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
            obj.HP.Size = 12
            obj.HP.Position = Vector2.new(centerX, topY + height + 17)
            obj.HP.Visible = Settings.ESP.Enabled and Settings.ESP.ShowHP
        end
    end

    -- ====== Aimbot ======
    local function GetClosestTarget()
        local closestDist = math.huge
        local closestTarget = nil
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            local isSameTeam = (GetPlayerTeam(plr) == GetPlayerTeam(LocalPlayer))
            if isSameTeam then continue end

            local targetPart = plr.Character:FindFirstChild(Settings.Aimbot.AimPart) or plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
            if not onScreen then continue end

            local screenPos = Vector2.new(pos.X, pos.Y)
            local dist = (screenPos - center).Magnitude
            if dist > Settings.Aimbot.FOV then continue end

            local worldDist = (Camera.CFrame.Position - targetPart.Position).Magnitude
            if worldDist > Settings.ESP.MaxDistance then continue end

            if dist < closestDist then
                closestDist = dist
                closestTarget = targetPart
            end
        end
        return closestTarget
    end

    local function AimAt(targetPart)
        if not targetPart then return end
        local targetPos = targetPart.Position
        local camCF = Camera.CFrame
        local lookAt = CFrame.lookAt(camCF.Position, targetPos)
        if Settings.Aimbot.Silent then
            Camera.CFrame = camCF:Lerp(lookAt, Settings.Aimbot.Smoothness)
        else
            Camera.CFrame = lookAt
        end
    end

    -- ====== Triggerbot Core ======
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local lastTriggerShot = 0
    local isShooting = false

    local function TriggerClick()
        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        else
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    local function CheckTriggerTarget()
        -- 1. ตรวจสอบผ่าน Mouse.Target
        local target = Mouse.Target
        local model = target and target:FindFirstAncestorOfClass("Model")
        local plr = model and Players:GetPlayerFromCharacter(model)

        -- 2. Raycast จากกึ่งกลางหน้าจอ (สำหรับ First-Person / Shift-Lock)
        if not plr then
            local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
            raycastParams.IgnoreWater = true

            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
                if hitModel then
                    plr = Players:GetPlayerFromCharacter(hitModel)
                    model = hitModel
                end
            end
        end

        if not plr or plr == LocalPlayer or not model then return nil end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end

        if Settings.Aimbot.TriggerbotTeamCheck then
            local playerTeam = GetPlayerTeam(plr)
            local isSameTeam = (playerTeam == GetPlayerTeam(LocalPlayer))
            if isSameTeam then return nil end
        end

        return plr
    end

    local function ProcessTriggerbot()
        if not Settings.Aimbot.TriggerbotEnabled then return end
        if Options.TriggerKeybind and not Options.TriggerKeybind:GetState() then return end
        if isShooting then return end

        local targetPlr = CheckTriggerTarget()
        if targetPlr then
            local now = tick()
            local delayTime = Settings.Aimbot.TriggerbotDelay or 0.02
            if now - lastTriggerShot >= delayTime then
                isShooting = true
                task.spawn(function()
                    if delayTime > 0 then
                        task.wait(delayTime)
                    end
                    TriggerClick()
                    lastTriggerShot = tick()
                    task.wait(0.05)
                    isShooting = false
                end)
            end
        end
    end

    -- Setup Players
    local function SetupPlayer(plr)
        CreateESPObject(plr)
        if plr.Character then CreateHighlight(plr) end
        plr.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart", 10)
            char:WaitForChild("Humanoid", 10)
            if HighlightObjects[plr] then
                pcall(function() HighlightObjects[plr]:Destroy() end)
                HighlightObjects[plr] = nil
            end
            CreateHighlight(plr)
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do SetupPlayer(plr) end
    Players.PlayerAdded:Connect(SetupPlayer)

    Players.PlayerRemoving:Connect(function(plr)
        if ESPObjects[plr] then
            for _, obj in pairs(ESPObjects[plr]) do pcall(function() obj:Remove() end) end
            ESPObjects[plr] = nil
        end
        if HighlightObjects[plr] then
            pcall(function() HighlightObjects[plr]:Destroy() end)
            HighlightObjects[plr] = nil
        end
    end)

    -- Loop
    RunService.RenderStepped:Connect(function()
        if Settings.ESP.Enabled then
            UpdateESP()
        else
            for _, objSet in pairs(ESPObjects) do
                for _, obj in pairs(objSet) do obj.Visible = false end
            end
            for _, hl in pairs(HighlightObjects) do
                if hl then hl.Enabled = false end
            end
        end

        if Settings.Aimbot.Enabled and Options.AimKeybind and Options.AimKeybind:GetState() then
            local target = GetClosestTarget()
            if target then AimAt(target) end
        end

        -- Triggerbot (ยิงอัตโนมัติเมื่อเป้าชี้โดนศัตรู)
        ProcessTriggerbot()

        -- WalkSpeed (อัปเดตความเร็วเดิน)
        if Settings.Misc.WalkSpeedEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= Settings.Misc.WalkSpeed then
                hum.WalkSpeed = Settings.Misc.WalkSpeed
            end
        end
    end)

    -- Noclip (เดินทะลุกำแพง)
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        if Settings.Misc.NoclipEnabled and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- Infinite Jump (กระโดดไม่จำกัด)
    local jumpConnection
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if Settings.Misc.InfiniteJumpEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- รีเซ็ตความเร็วเมื่อตัวละครเกิดใหม่
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if Settings.Misc.WalkSpeedEnabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Settings.Misc.WalkSpeed end
        end
    end)

    -- Cleanup เมื่อ Unload
    Library:OnUnload(function()
        if noclipConnection then noclipConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        for _, objSet in pairs(ESPObjects) do
            for _, obj in pairs(objSet) do pcall(function() obj:Remove() end) end
        end
        for _, hl in pairs(HighlightObjects) do
            pcall(function() hl:Destroy() end)
        end
        Library.Unloaded = true
    end)

    print("[Cold War ESP v3] ทำงานเรียบร้อย! กด End เพื่อเปิด/ปิดเมนู")
end

-- =========================================================================
--  🎨 KEY SYSTEM GUI (หน้าต่างกรอก Key)
-- =========================================================================
if savedKeyValid then
    print("[Cold War ESP] ยืนยัน Key จากแคชเรียบร้อย! ข้ามหน้า Key System...")
    StartMainScript()
else
    -- ป้องกัน UI ซ้ำ
    if LocalPlayer.PlayerGui:FindFirstChild("ColdWarKeySystemUI") then
        LocalPlayer.PlayerGui.ColdWarKeySystemUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ColdWarKeySystemUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ป้องกันกรณี Parent เข้า PlayerGui ล้มเหลว ให้ใช้ CoreGui ถ้า Executor รองรับ
    local pcallParent = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not pcallParent or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local MainCard = Instance.new("Frame")
    MainCard.Name = "MainCard"
    MainCard.Size = UDim2.new(0, 420, 0, 310)
    MainCard.Position = UDim2.new(0.5, -210, 0.5, -155)
    MainCard.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainCard.BorderSizePixel = 0
    MainCard.ClipsDescendants = true
    MainCard.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainCard

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 180, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainCard

    -- แถบหัวข้อ Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainCard

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 10)
    TitleBarCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "COLD WAR ESP v3 — KEY SYSTEM"
    TitleText.TextColor3 = Color3.fromRGB(0, 210, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 15
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local SubText = Instance.new("TextLabel")
    SubText.Size = UDim2.new(1, -40, 0, 25)
    SubText.Position = UDim2.new(0, 20, 0, 58)
    SubText.BackgroundTransparency = 1
    SubText.Text = "กรุณากรอก Key ของคุณเพื่อเริ่มใช้งานสคริปต์"
    SubText.TextColor3 = Color3.fromRGB(180, 180, 190)
    SubText.Font = Enum.Font.Gotham
    SubText.TextSize = 13
    SubText.TextXAlignment = Enum.TextXAlignment.Left
    SubText.Parent = MainCard

    -- กล่องใส่ Key
    local KeyBoxContainer = Instance.new("Frame")
    KeyBoxContainer.Size = UDim2.new(1, -40, 0, 42)
    KeyBoxContainer.Position = UDim2.new(0, 20, 0, 90)
    KeyBoxContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    KeyBoxContainer.BorderSizePixel = 0
    KeyBoxContainer.Parent = MainCard

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 8)
    BoxCorner.Parent = KeyBoxContainer

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(60, 60, 80)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = KeyBoxContainer

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -20, 1, 0)
    KeyInput.Position = UDim2.new(0, 10, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.PlaceholderText = "วาง Key ของคุณที่นี่..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 13
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = KeyBoxContainer

    -- ข้อความสถานะ (Status)
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -40, 0, 20)
    StatusLabel.Position = UDim2.new(0, 20, 0, 138)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainCard

    -- ปุ่ม Submit (ยืนยัน Key)
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(1, -40, 0, 40)
    SubmitBtn.Position = UDim2.new(0, 20, 0, 168)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SubmitBtn.Text = "SUBMIT KEY (ยืนยัน)"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextSize = 14
    SubmitBtn.Parent = MainCard

    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitBtn

    -- ปุ่มแถวล่าง: Get Key & Paste
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.48, -25, 0, 36)
    GetKeyBtn.Position = UDim2.new(0, 20, 0, 220)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    GetKeyBtn.Text = "GET KEY (รับคีย์)"
    GetKeyBtn.TextColor3 = Color3.fromRGB(0, 255, 140)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 13
    GetKeyBtn.Parent = MainCard

    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn

    local PasteBtn = Instance.new("TextButton")
    PasteBtn.Size = UDim2.new(0.48, -25, 0, 36)
    PasteBtn.Position = UDim2.new(0.52, 5, 0, 220)
    PasteBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    PasteBtn.Text = "PASTE KEY (วาง)"
    PasteBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    PasteBtn.Font = Enum.Font.GothamBold
    PasteBtn.TextSize = 13
    PasteBtn.Parent = MainCard

    local PasteCorner = Instance.new("UICorner")
    PasteCorner.CornerRadius = UDim.new(0, 8)
    PasteCorner.Parent = PasteBtn

    -- ฟังก์ชันคัดลอกลง Clipboard
    local function CopyToClipboard(text)
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        end
        return false
    end

    -- Event: กดปุ่ม Get Key
    GetKeyBtn.MouseButton1Click:Connect(function()
        local copied = CopyToClipboard(KeyConfig.GetKeyURL)
        if copied then
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
            StatusLabel.Text = "✓ คัดลอกลิงก์รับ Key ลง Clipboard เรียบร้อยแล้ว!"
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            StatusLabel.Text = "ลิงก์: " .. KeyConfig.GetKeyURL
        end
    end)

    -- Event: กดปุ่ม Paste Key
    PasteBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if getclipboard then
                KeyInput.Text = getclipboard()
                StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
                StatusLabel.Text = "วาง Key จาก Clipboard แล้ว"
            end
        end)
    end)

    -- Event: กดยืนยัน Key
    SubmitBtn.MouseButton1Click:Connect(function()
        local input = KeyInput.Text
        if VerifyKey(input) then
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            StatusLabel.Text = "✓ Key ถูกต้อง! กำลังโหลดสคริปต์..."
            
            -- เซฟ Key เก็บไว้ในเครื่อง จะได้ไม่ต้องกรอกซ้ำ
            pcall(function()
                if writefile then
                    writefile(KeyConfig.KeySaveFile, input)
                end
            end)

            task.wait(0.6)
            ScreenGui:Destroy()
            StartMainScript()
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
            StatusLabel.Text = "✕ Key ไม่ถูกต้อง! กรุณาตรวจสอบอีกครั้ง"
            BoxStroke.Color = Color3.fromRGB(255, 70, 70)
            task.delay(1.5, function()
                BoxStroke.Color = Color3.fromRGB(60, 60, 80)
            end)
        end
    end)

    -- รองรับการกด Enter ในช่อง KeyInput
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SubmitBtn.MouseButton1Click:Fire()
        end
    end)
end
