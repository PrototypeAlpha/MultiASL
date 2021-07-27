state("bioshock")
{
	bool  inGame		: 0x827610, 0x1C, 0x9C, 0x10, 0x4C, 0x2E8, 0x60;
	byte  fontainePhase	: 0x8BC810, 0x0, 0x20, 0x4C, 0x1108;
	int	  lvl			: 0x8D1B38;
	int	  loading		: 0x8D666C;
}

state("BioshockHD")
{
	bool  inGame		: 0x12D270C, 0x214, 0x6E8, 0x38;
	byte  fontainePhase	: 0x12D22C4, 0x0, 0x14, 0x1C, 0x1148;
	int   lvl			: 0x130287C;
	int   loading		: 0x12D2730;
}

state("Bioshock2")
{
	bool  isSaving		: 0xF42EE8;
	bool  isLoading		: 0x10B8010, 0x278;
	byte  lvl			: 0x10B8010, 0x258;
}

state("Bioshock2HD")
{
	bool  isSaving		: 0x1A9A680;
	bool  isLoading		: 0x1885120, 0x298;
	byte  lvl			: 0x1885120, 0x278;
}

state("BioshockInfinite")
{
	float isMapLoading  : 0x14154E8, 0x4;
	int   overlaysPtr	: 0x1415A30, 0x124;
	int   overlaysCount	: 0x1415A30, 0x128;
	int   afterLogo		: 0x135697C;
	byte  anyKey		: 0x13D2AA2;
}

start
{
	switch(game.ProcessName.ToLower())
	{
		case "bioshock":
			return current.lvl == 239 && current.inGame && !old.inGame;
		case "bioshockhd":
			return current.lvl == 1555 && current.inGame && !old.inGame;
		case "bioshock2":
		case "bioshock2hd":
			return current.lvl == 7 && !current.isLoading && old.isLoading;
		case "bioshockinfinite":
			return current.anyKey > 0 && current.afterLogo == 1 && old.afterLogo == 0;
		default:
			break;
	}
}

isLoading
{
    if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
		return true;
	
	switch(game.ProcessName.ToLower())
	{
		case "bioshock":
		case "bioshockhd":
			return current.loading != 0;
		case "bioshock2":
		case "bioshock2hd":
			return current.isSaving || current.isLoading;
		case "bioshockinfinite":
			if (current.isMapLoading != -1)
				return true;
			
			var count = current.overlaysCount;
			if (count < 0 || count > 8)
				return false;
				
			//Look for the load screen overlay.
			
			for(var i = 0; i < count; i++) {    
				var overlayPtr = memory.ReadValue<int>(new IntPtr(current.overlaysPtr+(i*4)));
				
				var namePtr = memory.ReadValue<int>(new IntPtr(overlayPtr));
				var nameLen = memory.ReadValue<int>(new IntPtr(overlayPtr + 0x4)) - 1;
				
				if (nameLen != 0x36)
					continue;            
				
				var name = memory.ReadString(new IntPtr(namePtr), nameLen*2);
				if (name == "GFXScriptReferenced.GameThreadLoadingScreen_Data_Oct22")
					return true;
				
			}
			return false;
		default:
			break;
	}
}

exit{timer.IsGameTimePaused = true;}
