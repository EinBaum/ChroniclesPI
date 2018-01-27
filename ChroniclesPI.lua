local savedName = nil

local function print(text)
	DEFAULT_CHAT_FRAME:AddMessage("[PI] " .. text, 1, 0.3, 0.5)
end

local function cast(name)

	if not name or name == "" then
		name = savedName
	end

	if not name then
		print("Noone has requested PI.")
		return
	end

	local spellName = "Power Infusion"
	local spellID = nil
	for s = 1, 300 do
		n = GetSpellName(s, BOOKTYPE_SPELL)
		if not n then break end
		if (n == spellName) then
			spellID = s
			break
		end
	end

	if not spellID then
		print("Power Infusion spell not found.")
		return
	end

	local CDStart, CDDur = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
	local CDRemain = (CDDur - (GetTime() - CDStart))
	if CDRemain > 0.25 then
		print("Spell is not ready yet.")
		return
	end

	local retarget = false
	if UnitExists("target") then
		retarget = true
	end

	TargetByName(name, true)

	if UnitName("target") == name then
		if buffed("Arcane Power", "target") or buffed("Power Infusion", "target") then
			print("ANOTHER EMPOWERMENT IS UP!")
		else
			CastSpellByName(spellName)
		end

		if retarget then
			TargetLastTarget()
		end
	else
		print("Cannot find player '" .. name .. "'.")
	end
end

local frame = CreateFrame("frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:SetScript("OnEvent", function()
	local text = arg1
	local name = arg2
	if text and name then
		if strfind(text, "POWER INFUSION") then
			if savedName ~= name then
				print("New PI target: " .. name)
				savedName = name
			end
		end
	end
end)

SLASH_CPI1 = "/pi"
SlashCmdList["CPI"] = cast
