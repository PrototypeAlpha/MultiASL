//By PsychoManiac and Kotti
state("Penumbra")
{
	int 		loading			: 0x24ee78, 24, 8;
	string32 	map				: 0x240f54, 332, 216, 0;
	byte 		player_active	: 0x240f54, 340, 456;
	double 		gameTime		: 0x240f54, 40, 20, 0;
}
//By DrTChops and Kotti
state("Penumbra","BP")
{
    float 		gameTime		: 0x2DCAF0, 0x188, 0x4C, 0x1C;
}
//By Kotti
state("Requiem")
{
	int 		loading			: 0x2DECD8, 0x15C, 0x368;
}
//By Tarados and JDev
state("Amnesia")
{
	int 		First_loading 	: 0x781320, 0x84, 0x7C, 0x04;
	int 		Second_loading 	: 0x781320, 0x84, 0x7C;	
	int 		Dialogue		: 0x768C54, 0x58, 0x3C, 0x54, 0x10;
	int 		menu			: 0x768C54, 0x80, 0x130;
	bool 		loading			: 0xC7BE2;
}
//By Sychotixx
state("aamfp")
{
	float 		gameTime		: 0x74CA04, 0x84, 0x2D0, 0x60;
	string9 	map				: 0x74CA04, 0x5C, 0x60, 0x38;
}
//By Trigger
state("soma")
{
    bool 		loading			: 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 	map				: 0x0077EBB0, 0x118, 0x168, 0x0;
}
state("soma_nosteam")
{
    bool 		loading			: 0x00784840, 0xB20, 0x27D8, 0x60;
    string50	map				: 0x0077EBB0, 0x118, 0x168, 0x0;
}
state("soma", "GOG 1.00")
{
    bool 		loading			: 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 	map				: 0x0077EBB0, 0x118, 0x168, 0x0;
}
state("soma", "Steam 1.00")
{
    bool 		loading			: 0x00802A00, 0xB20, 0x27D8, 0x60;
    string50 	map				: 0x007FCD80, 0x118, 0x168, 0x0;
}
state("soma_nosteam", "NoSteam 1.00")
{
    bool 		loading			: 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 	map				: 0x0077EBB0, 0x118, 0x168, 0x0;
}
state("soma", "GOG 1.51")
{
    bool 		loading			: 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 	map				: 0x0078D560, 0x130, 0x168, 0x0;
}
state("soma", "Steam 1.51")
{
    bool 		loading			: 0x0080D740, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 	map				: 0x0080D740, 0x130, 0x168, 0x0;
}
state("soma", "Discord 1.51")
{
    bool 		loading			: 0x0078D560, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 	map				: 0x0078D560, 0x130, 0x168, 0x0;
}
state("soma_nosteam", "NoSteam 1.51")
{
    bool 		loading			: 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 	map				: 0x0078D560, 0x130, 0x168, 0x0;
}

init
{
	
	version="";
	
	if(game.ProcessName == "Penumbra"){
		if(Directory.Exists(modules.First().FileName.TrimEnd("penumbra.exe".ToCharArray())+"gui"))
			version="BP";
		print("Penumbra "+version);
	}
	
	if(game.ProcessName == "Penumbra" && version!="BP"){
		vars.psycho_loading_active = false;
		vars.psycho_loading_time = 0.0;
	}
	else if((game.ProcessName == "Penumbra" && version=="BP") || game.ProcessName == "aamfp"){
		// Stores previous game time for RTA runs
		vars.loadedTime = 0; 
		// Stores previous map for RTA runs
		vars.lastValidMap = " ";
	}
	else if(game.ProcessName == "Amnesia"){
		game.Suspend();
		
		int UNUSED_BYTE_OFFSET = 0xC7BE2;
		
		byte[] addrBytes = BitConverter.GetBytes((int)modules.First().BaseAddress+UNUSED_BYTE_OFFSET);
		print("[AmnesiaASL] addrBytes: "+BitConverter.ToString(addrBytes).Replace("-"," "));

		game.WriteBytes(modules.First().BaseAddress+UNUSED_BYTE_OFFSET, new byte[] {0});
		
		game.VirtualProtect((IntPtr) modules.First().BaseAddress+UNUSED_BYTE_OFFSET, 1, MemPageProtect.PAGE_EXECUTE_READWRITE);
		
		var payload1 = new List<byte>(new byte[] { 0xC6, 0x05 });
		payload1.AddRange(addrBytes);
		payload1.AddRange(new byte[] { 0x01, 0x90, 0xEB });
		print("[AmnesiaASL] payload1: "+BitConverter.ToString(payload1.ToArray()).Replace("-"," "));
		game.WriteBytes(modules.First().BaseAddress+0xC7884, payload1.ToArray());
		
		var payload2 = new List<byte>(new byte[] { 0x05 });
		payload2.AddRange(addrBytes);
		payload2.AddRange(new byte[] { 0x00, 0x90, 0x90 });
		print("[AmnesiaASL] payload2: "+BitConverter.ToString(payload2.ToArray()).Replace("-"," "));
		game.WriteBytes(modules.First().BaseAddress+0xC7A6E, payload2.ToArray());
		
		game.Resume();
	}
	else if(game.ProcessName.StartsWith("Soma")){
		var name = modules.First().ModuleName.ToLower();
		var size = modules.First().ModuleMemorySize;
		
		print("[SOMA] Module Size: " + size);
		
		switch(size)
		{
			case 8679424:
				version = name == "soma.exe" ? "GOG 1.00" : "NoSteam 1.00";
				break;
			case 8871936:
				version = name == "soma.exe" ? "GOG 1.51" : "NoSteam 1.51";
				break;
			case 8876032:
				version = "Discord 1.51";
				break;
			case 9383936:
				version = "Steam 1.51";
				break;
			default:
				break;
		}
	}
	
}

isLoading
{
	
	if(timer.CurrentSplit.Name.ToLower().Contains("setup")) return true;
	
	else if(game.ProcessName == "Penumbra" && version!="BP"){
		if(old.loading == 0 && current.loading != 0)
		{
			vars.psycho_loading_active = true;
			vars.psycho_loading_time = current.gameTime;
		}
		
		if(vars.psycho_loading_active && vars.psycho_loading_time < current.gameTime)
			vars.psycho_loading_active = false;
		
		return (current.loading == 0) || vars.psycho_loading_active;
	}
	
	else if ((game.ProcessName == "Penumbra" && version=="BP") || game.ProcessName == "aamfp")
		return current.gameTime == old.gameTime;
	
	else if(game.ProcessName == "Requiem") return current.loading == 0;
	
	else if(game.ProcessName == "Amnesia" || game.ProcessName.StartsWith("Soma")) return current.loading;
	
}

start
{
	
	if(game.ProcessName == "Penumbra" && version!="BP") return current.map != old.map && current.map == "level00_01_boat_cabin";
	
	else if(game.ProcessName == "Penumbra" && version=="BP") return current.gameTime > 0 && old.gameTime == 0;
	
	else if(game.ProcessName == "Requiem") return current.loading == 8 && old.loading == 0;
	
	else if(game.ProcessName == "Amnesia") return current.Dialogue == 88 && old.Dialogue != 88;
	
	else if(game.ProcessName == "aamfp"){
		// Reset the variables while not in a run
		vars.loadedTime = 0;
		vars.lastValidMap = " ";
		return current.gameTime >= 76.00 && old.gameTime < 76.00 && current.map == "Mansion01";
	}
	
	else if(game.ProcessName.StartsWith("Soma"))
		return old.map != "00_01_apartment.hpm" && current.map == "00_01_apartment.hpm";
	
}

update
{
	
	if(timer.CurrentPhase==TimerPhase.NotRunning) return;
	//if(game.ProcessName == "Penumbra" && version!="BP" && old.map != current.map){
	//	print("[Penumbra] Map: "+current.map+" (from "+old.map+")");
	//}
	else if ((game.ProcessName == "Penumbra" && version=="BP") || game.ProcessName == "aamfp"){
		// We are currently ingame for at least one tick
		if (old.gameTime > 0)
		{
			// Store the last valid map for RTA/Splitting
			if (game.ProcessName == "aamfp" && old.map != null && old.map != "")
				vars.lastValidMap = old.map;
		
			// We just came from the menu, save the old times for RTA
			if (current.gameTime == 0)
				vars.loadedTime += old.gameTime;
				
			//if (game.ProcessName == "aamfp" && old.map != current.map)
			//	print("[AAMFP] Map: "+current.map+" (from "+vars.lastValidMap+")");
		}
	}
	else if(game.ProcessName.StartsWith("Soma") && old.map != current.map)
		print("[SOMA] Map: "+current.map+" (from "+old.map+")");
	
}

split
{
	
	if(game.ProcessName == "Penumbra" && version!="BP"){
	
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return current.map != old.map && current.map == "level00_01_boat_cabin";
		
		if(current.map != "" && old.map != "" && current.map != old.map){
		
			if(current.map == "level01_20_base_entrance")
				return old.player_active == 1 && current.player_active == 0;
			
			else return current.map != old.map;
			
		}
		
	}
	else if(game.ProcessName == "Penumbra" && version=="BP"){
		
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return current.gameTime > 0;
		
	}
	else if(game.ProcessName == "Requiem"){
	
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return old.loading == 0 && current.loading == 8;
		
	}
	else if(game.ProcessName == "Amnesia"){
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return current.Dialogue == 88 && old.Dialogue != 88;
		
		return current.Dialogue == 13 && old.Dialogue != 13;
		
	}
	else if(game.ProcessName == "aamfp"){
	
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return current.gameTime >= 76.00 && old.gameTime < 76.00 && current.map == "Mansion01";
		
		return current.map != null && current.map != "" && vars.lastValidMap != current.map;
		
	}
	else if(game.ProcessName.StartsWith("Soma")){
	
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return old.map != "00_01_apartment.hpm" && current.map == "00_01_apartment.hpm";
		
		return old.map != "main_menu.hpm" && current.map != "main_menu.hpm" &&
			current.map != "00_00_intro" && old.map != current.map;
		
	}
	
}
