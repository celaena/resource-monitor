local module = {};
local moduleName = "ClassConfig";
ResMon[moduleName] = module;

local main = ResMon.Main;

local SOUNDS = {

};

local COLORS = {
	YELLOW = {1,1,0},
	YEL_ORG = {1,0.75,0},
	ORANGE = {1,0.5,0},
	ORG_RED = {1,0.25,0},
	RED = {1,0,0},
	LIGHT_BLUE = {0.25,0.8,1},
	BLUE = {0,0.5,1},
	BLUE_PURP = {0.25,0.25,1},
	LIGHT_PURP = {0.75,0.2,1},
	PURP = {0.5,0,1},
	DARK_PURP = {0.25,0,0.5}
};

local orangeBar = {
	COLORS.YELLOW,
	COLORS.YEL_ORG,
	COLORS.ORANGE,
	COLORS.ORG_RED,
	COLORS.RED
};

local blueBar = {
	COLORS.LIGHT_BLUE,
	COLORS.BLUE,
	COLORS.BLUE_PURP,
	COLORS.PURP,
	COLORS.DARK_PURP
};

local purpleBar = {
	COLORS.LIGHT_PURP,
	COLORS.PURP,
	COLORS.DARK_PURP,
	COLORS.DARK_PURP,
	COLORS.DARK_PURP
};

local threeSounds = {

};

local fiveSounds = {

};

local fiveSoundsPt2 = {

};

module.BAR_CONFIG = {
	["ROGUE"] = {
		POWER_IND = 4,
		DEFAULT = {
			["FIVE_BAR_1"] = {
				BLIP_COLORS = orangeBar,
				BLIP_SOUNDS = fiveSounds
			}
		},
		ANT = {
			["FIVE_BAR_1"] = {
				BLIP_COLORS = orangeBar,
				BLIP_SOUNDS = fiveSounds
			},
			["FIVE_BAR_2"] = {
				BLIP_COLORS = blueBar,
				BLIP_SOUNDS = fiveSoundsPt2
			}
		}
	},
	["PRIEST"] = {
		SHADOW = {
			POWER_IND = 13,
			PRE_PERK = {
				["THREE_BAR"] = {
					BLIP_COLORS = purpleBar,
					BLIP_SOUNDS = threeSounds
				}
			},
			PERK = {
				["FIVE_BAR_1"] = {
					BLIP_COLORS = purpleBar,
					BLIP_SOUNDS = fiveSounds
				}
			}
		}
	}
}

module.GetBarConfig = function()
	local class, classFileName = UnitClass(PLAYER);
	local curSpec = GetSpecialization();
	
	local barConf = {};
	local powerInd = -1;
	if (classFileName == "ROGUE") then
		powerInd = module.BAR_CONFIG["ROGUE"].POWER_IND;
		if (select(2, GetTalentRowSelectionInfo(6)) == 19250) then
			barConf = module.BAR_CONFIG["ROGUE"].ANT;
		else
			barConf = module.BAR_CONFIG["ROGUE"].DEFAULT;
		end
	elseif (classFileName == "PRIEST") then
		powerInd = module.BAR_CONFIG["PRIEST"].SHADOW.POWER_IND;
		if (curSpec == 3) then
			if (select(1, GetSpellInfo("Enhanced Shadow Orbs")) ~= nil) then
				barConf = module.BAR_CONFIG["PRIEST"].SHADOW.PERK;
			else
				barConf = module.BAR_CONFIG["PRIEST"].SHADOW.PRE_PERK;
			end
		end
	end
	return barConf, powerInd;
end