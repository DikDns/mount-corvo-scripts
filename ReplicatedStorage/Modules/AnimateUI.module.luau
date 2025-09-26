--[[
    AnimateUI Module
    Updated by Gemini to include a sound effect parameter for the typewriter function.
]]

local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")

local SOURCE_LOCALE = "en"
local translator = nil

local AnimateUI = {}

function AnimateUI.loadTranslator()
	pcall(function()
		translator = LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
	end)
	if not translator then
		pcall(function()
			translator = LocalizationService:GetTranslatorForLocaleAsync(SOURCE_LOCALE)
		end)
	end
end

-- Updated function to accept a 'typingSound' object
function AnimateUI.typeWrite(guiObject, text, delayBetweenChars, typingSound)
	guiObject.Visible = true
	guiObject.AutoLocalize = false
	local displayText = text

	-- Translate text if possible
	if translator then
		displayText = translator:Translate(guiObject, text)
	end

	-- Replace line break tags so grapheme loop will not miss those characters
	displayText = displayText:gsub("<br%s*/>", "\n")
	-- Remove RichText tags since char-by-char animation will break the tags
	displayText = displayText:gsub("<[^<>]->", "")

	-- Set translated/modified text on parent
	guiObject.Text = displayText

	local index = 0
	for first, last in utf8.graphemes(displayText) do
		index += 1
		guiObject.MaxVisibleGraphemes = index

		-- Play the sound effect if it's provided
		if typingSound and typeof(typingSound) == "Instance" and typingSound:IsA("Sound") then
			typingSound:Play()
		end

		task.wait(delayBetweenChars)
	end
end

return AnimateUI
