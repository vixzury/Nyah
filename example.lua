-- Wait for the game to load if we are in auto-execute
repeat task.wait() until game:IsLoaded()

-- Try to load the library from our local file for testing purposes
-- Normally this would be a loadstring(game:HttpGet("YOUR_LINK.lua"))()
local NyahLib = assert(loadfile("C:/Users/omarj/Desktop/roblox/loader/NyahLib.lua"))()

-- Create the Main Window
local Window = NyahLib:CreateWindow({
    Title = "NyahLib Example",
    SubTitle = "premium mentoring script hub",
})

-- Create some Tabs (We use icons similar to the Mentality design)
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "⚙" })
local VisualsTab = Window:CreateTab({ Name = "Automobiles", Icon = "🚙" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "⚙" })

-- ==============================================
-- COMBAT TAB EXAMPLES
-- ==============================================

local AimbotSection = CombatTab:CreateSection({ Name = "Aimbot Settings" })

AimbotSection:CreateToggle({
    Name = "Enabled",
    Default = false,
    Callback = function(state)
        print("Aimbot Enabled:", state)
    end
})

AimbotSection:CreateToggle({
    Name = "Show FOV",
    Default = true,
    Callback = function(state)
        print("FOV Circle:", state)
    end
})

local SilentAimSection = CombatTab:CreateSection({ Name = "Silent Aim" })
SilentAimSection:CreateToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(state)
        print("Wallbang:", state)
    end
})

-- Adding a bunch of toggles to show how the multi-column layout balances itself!
for i = 1, 5 do
    AimbotSection:CreateToggle({ Name = "Extra Option "..i })
end


-- ==============================================
-- VISUALS TAB EXAMPLES
-- ==============================================

local ESPSection = VisualsTab:CreateSection({ Name = "ESP Main" })

ESPSection:CreateToggle({
    Name = "Boxes",
    Default = false,
    Callback = function(state)
        print("ESP Boxes:", state)
    end
})

ESPSection:CreateToggle({
    Name = "Names",
    Default = true
})

ESPSection:CreateToggle({
    Name = "Healthbar",
    Default = true
})

local ChamsSection = VisualsTab:CreateSection({ Name = "Chams" })

ChamsSection:CreateToggle({ Name = "Enable Chams" })
ChamsSection:CreateToggle({ Name = "Through Walls" })


-- ==============================================
-- SETTINGS TAB EXAMPLES
-- ==============================================

local UIDesign = SettingsTab:CreateSection({ Name = "UI Design" })

UIDesign:CreateToggle({
    Name = "Watermark",
    Default = true
})

UIDesign:CreateToggle({
    Name = "Keybinds List",
    Default = false
})

print("NyahLib loaded successfully!")
