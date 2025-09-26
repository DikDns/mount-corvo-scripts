--[[

MADE BY MAIQ_S

How to setup:
1) Read the READ ME script
2) Place the "LightingScenary" script in ServerScriptService and the LightingClient script in StarterPlayerScripts
3) Place the "Lighting System" folder in ReplicatedStorage
4) Enjoy!

To edit the lighting, simply edit one of the module scripts to your liking.

--]]

local LightingModules = game.ReplicatedStorage["Lighting System"]
local DeleteScriptIfClientSided = false

if not LightingModules["Client Sided"].Value then
	require(LightingModules.Main)
else
	if DeleteScriptIfClientSided then
		script:Destroy()
	end
end
