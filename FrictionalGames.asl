//By DrTChops and Kotti
state("Penumbra")
{
    float gameTime: 0x2DCAF0, 0x188, 0x4C, 0x1C;
}
//By Tarados
state("Amnesia")
{
	int Dialogue: 0x768C54, 0x58, 0x3C, 0x54, 0x10;
}
//By Sychotixx
state("aamfp")
{
	float gameTime: 0x74CA04, 0x84, 0x2D0, 0x60;
	string9 mapName: 0x74CA04, 0x5C, 0x60, 0x38;
}
//By Trigger
state("soma")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma_nosteam")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "GOG 1.00")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "Steam 1.00")
{
    bool loading : 0x00802A00, 0xB20, 0x27D8, 0x60;
    string50 map : 0x007FCD80, 0x118, 0x168, 0x0;
}

state("soma_nosteam", "NoSteam 1.00")
{
    bool loading : 0x00784840, 0xB20, 0x27D8, 0x60;
    string50 map : 0x0077EBB0, 0x118, 0x168, 0x0;
}

state("soma", "GOG 1.51")
{
    bool loading : 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

state("soma", "Steam 1.51")
{
    bool loading : 0x0080D740, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 map : 0x0080D740, 0x130, 0x168, 0x0;
}

state("soma", "Discord 1.51")
{
    bool loading : 0x0078D560, 0x890, 0x0, 0xE0, 0x120, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

state("soma_nosteam", "NoSteam 1.51")
{
    bool loading : 0x00792DD0, 0xC48, 0x3E8, 0x1D8, 0x1D0, 0x190, 0x38, 0x60;
    string50 map : 0x0078D560, 0x130, 0x168, 0x0;
}

init
{
	if(game.ProcessName == "Penumbra"){
		vars.bp = false;
		if(Directory.Exists(modules.First().FileName.TrimEnd("penumbra.exe".ToCharArray())+"gui"))
			vars.bp = true;
		print("Black Plague: "+vars.bp);
	}
	if ((game.ProcessName == "Penumbra" && vars.bp) || game.ProcessName == "aamfp"){
		// Stores previous game time for RTA runs
		vars.loadedTime = 0; 
		// Stores previous map for RTA runs
		vars.lastValidMap = " ";
	}
	if(game.ProcessName.StartsWith("Soma")){
		var name = modules.First().ModuleName.ToLower();
		var size = modules.First().ModuleMemorySize;
		
		print("Module Size: " + size);
		
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
	if(game.ProcessName == "Penumbra" && !vars.bp) return false;
	else if (timer.CurrentSplit.Name.ToLower().Contains("setup") || (game.ProcessName == "Penumbra" && vars.bp) || game.ProcessName == "aamfp")
        return true;
	else if(game.ProcessName.StartsWith("Soma")) return current.loading;
}


start
{
	if(timer.CurrentPhase!=TimerPhase.NotRunning) return;
	else if(game.ProcessName == "Penumbra" && vars.bp) return current.gameTime > 0 && old.gameTime == 0;
	else if(game.ProcessName == "Amnesia")return current.Dialogue == 88;
	else if(game.ProcessName == "aamfp"){
		// Reset the variables while not in a run
		vars.loadedTime = 0;
		vars.lastValidMap = " ";
		return current.gameTime >= 76 && old.gameTime <= 76 && current.mapName == "Mansion01";
	}
	else if(game.ProcessName.StartsWith("Soma"))
		return old.map != "00_01_apartment.hpm" && current.map == "00_01_apartment.hpm";
}

update 
{
	if(timer.CurrentPhase==TimerPhase.NotRunning) return;
	
	if ((game.ProcessName == "Penumbra" && vars.bp) || game.ProcessName == "aamfp"){
		// We are currently ingame for at least one tick
		if (old.gameTime > 0)
		{
			// Store the last valid map for RTA/Splitting
			if (game.ProcessName == "aamfp" && old.mapName != null && old.mapName != "")
				vars.lastValidMap = old.mapName;
		
			// We just came from the menu, save the old times for RTA
			if (current.gameTime == 0)
				vars.loadedTime += old.gameTime;
				
			if (game.ProcessName == "aamfp" && old.mapName != current.mapName)
				print("[AAMFP] Map: "+current.mapName);
		}
	}
	if(game.ProcessName.StartsWith("Soma") && old.map != current.map)
		print("[SOMA] Map: "+current.map);
}

gameTime
{
	if (timer.CurrentPhase!=TimerPhase.NotRunning && !timer.CurrentSplit.Name.ToLower().Contains("setup")){
		if(game.ProcessName == "Penumbra" && vars.bp){return TimeSpan.FromSeconds(current.gameTime+vars.loadedTime);}
		else if(game.ProcessName == "aamfp"){return TimeSpan.FromSeconds(current.gameTime+vars.loadedTime-76);}
	}
}

split
{
	if(game.ProcessName == "Amnesia" && timer.CurrentPhase!=TimerPhase.NotRunning){
		if(timer.CurrentSplit.Name.ToLower().Contains("setup")){
			return current.Dialogue != old.Dialogue && current.Dialogue == 88;
		}
		else{return current.Dialogue != old.Dialogue && current.Dialogue == 13;}
	}
	if(game.ProcessName == "aamfp"){
		if(timer.CurrentPhase!=TimerPhase.NotRunning && timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return current.gameTime >= 76 && old.gameTime <= 76 && current.mapName == "Mansion01";
		
		if (current.mapName != null && current.mapName != "" && vars.lastValidMap != current.mapName)
			print("CURRENT: "+current.mapName+" VALID: "+vars.lastValidMap);
		
		return current.mapName != null && current.mapName != "" &&
			vars.lastValidMap != current.mapName;
	}
	if(game.ProcessName.StartsWith("Soma")){
		if(timer.CurrentSplit.Name.ToLower().Contains("setup"))
			return old.map != "00_01_apartment.hpm" && current.map == "00_01_apartment.hpm";
		
		return old.map != "main_menu.hpm" &&
        current.map != "main_menu.hpm" &&
        current.map != "00_00_intro" &&
        old.map != current.map;
	}
}


