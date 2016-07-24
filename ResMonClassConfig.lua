local module = {};
local moduleName = "ClassConfig";
ResMon[moduleName] = module;

local ROGUE = "ROGUE";
local PALADIN = "PALADIN";
local PRIEST = "PRIEST";
local WARLOCK = "WARLOCK";

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
	DARK_PURP = {0.25,0,0.5},
	LIGHT_PINK = {0.95,0.8,0.9},
	LIGHT_MID_PINK = {0.95,0.65,0.8},
	PINK = {0.95,0.5,0.7},
	DARK_MID_PINK = {0.95,0.35,0.6},
	DARK_PINK = {0.95,0.2,0.5}
};

local orangeBar = {
	COLORS.YELLOW,
	COLORS.YEL_ORG,
	COLORS.ORANGE,
	COLORS.ORG_RED,
	COLORS.RED,
	COLORS.PURP,
	COLORS.BLUE_PURP,
	COLORS.BLUE
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

local pinkBar = {
	COLORS.LIGHT_PINK,
	COLORS.LIGHT_MID_PINK,
	COLORS.PINK,
	COLORS.DARK_MID_PINK,
	COLORS.DARK_PINK
};

local threeSounds = {

};

local fiveSounds = {

};

local fiveSoundsPt2 = {

};

module.BAR_CONFIG = {
	[ROGUE] = {
		POWER_IND = 4,
		BLIP_COLORS = orangeBar,
		BLIP_SOUNDS = fiveSounds
	},
	[PRIEST] = {
		SHADOW = {
			POWER_IND = 13,
			BLIP_COLORS = purpleBar,
			BLIP_SOUNDS = fiveSounds
		}
	},
	[PALADIN] = {
		POWER_IND = 9,
		BLIP_COLORS = pinkBar,
		BLIP_SOUNDS = fiveSounds
	},
	[WARLOCK] = {
		POWER_IND = 7,
		BLIP_COLORS = purpleBar,
		BLIP_SOUNDS = fiveSounds
	}
}

module.GetBarConfig = function()
	local class, classFileName = UnitClass(PLAYER);
	local curSpec = GetSpecialization();
	
	local barConf = {};
	if (classFileName == ROGUE) then
		barConf = module.BAR_CONFIG[ROGUE];
	elseif (classFileName == PRIEST) then
		powerInd = module.BAR_CONFIG[PRIEST].SHADOW.POWER_IND;
		if (curSpec == 3) then
			if (select(1, GetSpellInfo("Enhanced Shadow Orbs")) ~= nil) then
				barConf = module.BAR_CONFIG[PRIEST].SHADOW.PERK;
			else
				barConf = module.BAR_CONFIG[PRIEST].SHADOW.PRE_PERK;
			end
		end
	elseif (classFileName == PALADIN) then
		barConf = module.BAR_CONFIG[PALADIN];	
	elseif (classFileName == WARLOCK) then
		barConf = module.BAR_CONFIG[WARLOCK];	
	end
	return barConf;
end