-------------------------------------------
-- Rogue power configurations
-------------------------------------------

local POWER_IND = 4;

local function UpdateBar(blipTextures, blipColors)
	
end

-- Anticipation bar setup
local ANTICIPATION = "Anticipation";

local function UpdateRogueAntBar(blipTextures, blipColors)
	local antStacks = select(4, UnitAura("player", ANTICIPATION, nil, "PLAYER|HELPFUL"));
	for i = 0, antStacks - 1 do 
		local rgb = blipColors[i];
		blipTextures[i]:SetTexture(rgb[0], rgb[1], rgb[2], 1);
		blipTextures[i]:SetAllPoints();
	end
	for i = antStacks - 1, #blipTextures do
		blipTextures[i]:SetTexture(0, 0, 0, 1);
		blipTextures[i]:SetAllPoints();
	end
end