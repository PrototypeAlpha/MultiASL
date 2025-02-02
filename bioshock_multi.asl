state("bioshock", "BS1 Steam")
{
	byte  fontainePhase : 0x8BC810, 0x0, 0x20, 0x4C, 0x1108;
	int   lvl           : 0x8D1B38;
	int   loading       : 0x8D666C;
}
state("bioshock", "BS1 GOG")
{
	byte  fontainePhase : 0x9A4668, 0x0, 0x20, 0x4C, 0x1108;
	int   lvl           : 0x9B9990;
	int   loading       : 0x9BE4D4;
}

state("BioshockHD","BS1R Steam")
{
	byte  fontainePhase : 0x1356200, 0x0, 0x14, 0x1C, 0x1148;
	int   lvl           : 0x1386004;
	int   loading       : 0x1356680;
}
state("BioshockHD","BS1R EGS")
{
	byte  fontainePhase : 0x13555DC, 0x0, 0x18, 0x1C, 0x1148;
	int   lvl           : 0x13853E8;
	int   loading       : 0x1355A68;
}
state("BioshockHD","BS1R GOG")
{
	byte  fontainePhase : 0x12D22C4, 0x0, 0x14, 0x1C, 0x1148;
	int   lvl           : 0x130287C;
	int   loading       : 0x12D2730;
}

state("Bioshock2")
{
	bool  isSaving      : 0xF42EE8;
	bool  isLoading     : 0x10B8010, 0x278;
	byte  lvl           : 0x10B8010, 0x258;
}

state("Bioshock2HD")
{
	bool  isSaving      : 0x1A9A680;
	bool  isLoading     : 0x1885120, 0x298;
	byte  lvl           : 0x1885120, 0x278;
}

state("BioshockInfinite")
{
	float isMapLoading  : 0x14154E8, 0x4;
	int   overlaysPtr   : 0x1415A30, 0x124;
	int   overlaysCount : 0x1415A30, 0x128;
	byte  afterLogo     : 0x135697C;
	long  area          : 0x1423D18, 0x124, 0x1A4;
	int   loadingScreen : 0x137CF94, 0x3BC, 0x19C;
}
state("BioshockInfinite", "BSI Steam Current")
{
	float isMapLoading  : 0x0FEC7C8, 0x4;
	int   overlaysPtr   : 0x0FED290, 0x124;
	int   overlaysCount : 0x0FED290, 0x128;
	byte  afterLogo     : 0x0F30854;
	long  area          : 0x1007160, 0x124, 0x1A4;
	int   loadingScreen : 0x0FA2B98, 0x3BC, 0x19C;
}

startup
{
	vars.startPos1 = new Vector3f(502f, 1184f, 73f);
	
	vars.GetHash = (Func<string, string>)((f) =>
	{
		byte[] bytes = new byte[0];
		using (var md5 = System.Security.Cryptography.MD5.Create())
		{
			using (var file = File.Open(f, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
				bytes = md5.ComputeHash(file);
		}
		return bytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	});
	
	settings.Add("start", true, "Enable Auto-Start");
	settings.Add("start1", true, "BioShock 1", "start");
	settings.Add("start2", true, "BioShock 2", "start");
	//settings.Add("start2.1", true, "BioShock 2: Minerva's Den", "start");
	settings.Add("start3", true, "BioShock Infinite", "start");
	/*
	settings.Add("start3.1", true, "BioShock Infinite: Burial at Sea 1", "start");
	settings.Add("start3.2", true, "BioShock Infinite: Burial at Sea 2", "start");
	/*
	settings.Add("split", true, "Enable Auto-Split");
	settings.Add("split1", true, "BioShock 1", "split");
	settings.Add("split2", true, "BioShock 2", "split");
	settings.Add("split2.1", true, "BioShock 2: Minerva's Den", "split");
	settings.Add("split3", true, "BioShock Infinite", "split");
	settings.Add("split3.1", true, "BioShock Infinite: Burial at Sea 1", "split");
	settings.Add("split3.2", true, "BioShock Infinite: Burial at Sea 2", "split");
	*/
	settings.Add("setup", true, "Enable \"setup\" splits game time pausing");
	settings.Add("newloads", true, "Use new load removal method");
}

init
{
	DeepPointer posPtr = new DeepPointer(IntPtr.Zero);
	string gamehash = vars.GetHash(modules.First().FileName);
	
	switch (gamehash)
	{
		// BioShock 1
		case "998B06F3D9CDA63B79C6FE631075FE94":
			version = "BS1 Steam";
			posPtr = new DeepPointer(0x8BC80C, 0x0, 0x10, 0x414, 0x1C0);
			break;
		case "AD3B163231E873EDA6050A203470393A":
			version = "BS1 GOG";
			posPtr = new DeepPointer(0x9A4664, 0x0, 0x10, 0x414, 0x1C0);
			break;
		
		// BioShock 1 Remastered
		case "B4DB411AB3E5994B6CD39F8DD91FD990":
			version = "BS1R Steam";
			posPtr = new DeepPointer(0x13561FC, 0x0, 0x10, 0x450, 0x1D8);
			break;
		case "7390450839A4699C1E890A4E22A2E80B":
			version = "BS1R EGS";
			posPtr = new DeepPointer(0x13555D8, 0x0, 0x10, 0x450, 0x1D8);
			break;
		case "63315D12EC2673CEAD8D87BE9C7EC3EE":
			version = "BS1R GOG";
			posPtr = new DeepPointer(0x12D22C0, 0x0, 0x10, 0x450, 0x1D8);
			break;
		
		// BioShock 2
		case "01182B9B2FA7B9232D3862D2E6F1E05A":
			version = "BS2 GOG";
			break;
		case "7BE7454335543349786D1CDF7D4EB87D":
			version = "BS2 Steam";
			break;
		
		// BioShock 2 Remastered
		case "8F99CED534067A5BC2E1324BBF49E75C":
			version = "BS2R Steam";
			break;
		case "99D42C155482BFA69092DE65F60D20DD":
			version = "BS2R EGS";
			break;
		case "E6EA6475C7FBEDD63FE579BECD035111":
			version = "BS2R GOG";
			break;
		
		// BioShock Infinite
		case "0056FB3A4A0D13F103CFA980BFD834D2":
			version = "BSI GOG";
			//posPtr = new DeepPointer(0x14278E8, 0x0, 0x6C, 0x44);
			break;
		case "0FA06E3FF5C7C132227262D121BCB6BD":
		case "5E71CFDB25D72790EC821514159B667D":
			version = "BSI Steam Downpatch";
			//posPtr = new DeepPointer(0x14278E8, 0x0, 0x6C, 0x44);
			break;
		case "FD5FDE5D93628E1434C20E662B5D8C2D":
			version = "BSI Steam Current";
			//posPtr = new DeepPointer(0x100B278, 0x0, 0x6C, 0x44);
			break;
		
		// Unknown game version
		default:
			version = "Unknown";
			break;
	}
	
	vars.Position = new MemoryWatcher<Vector3f>(posPtr);
	vars.Position.Enabled = (version != "Unknown" && version.Contains("BS1")) ? true : false;
	
	timer.IsGameTimePaused = false;
}

start
{
	switch(game.ProcessName.ToLower())
	{
		case "bioshock":
		case "bioshockhd":
			if(!settings["start1"])
				return;
			
			if(current.loading != 0 || (game.ProcessName.ToLower() == "bioshock" && current.lvl != 239) || !vars.Position.Enabled || vars.Position.Current.Z < vars.startPos1.Z)
				return;
			
			if(game.ProcessName.ToLower() == "bioshockhd" && current.lvl != 1555)
				return;
			
			if(old.loading != 0 && current.loading == 0)
				return vars.Position.Current.DistanceXY(vars.startPos1) < 2f;
			
			return (vars.Position.Old.DistanceXY(vars.startPos1) < 2f && vars.Position.Current.DistanceXY(vars.startPos1) > 2f) || vars.Position.Current.Z < vars.Position.Old.Z;
		
		case "bioshock2":
		case "bioshock2hd":
			return settings["start2"] && current.lvl == 7 && !current.isLoading && old.isLoading;
		
		case "bioshockinfinite":
			return settings["start3"] && current.area == 17179869188 && current.afterLogo == 1 && old.afterLogo == 0;
		
		default:
			break;
	}
}

isLoading
{
	if(settings["setup"] && timer.CurrentSplit.Name.ToLower().Contains("setup"))
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
			
			if (settings["newloads"] && current.loadingScreen > 0)
				return true;
			
			var count = current.overlaysCount;
			if (count < 0 || count > 8)
				return false;
				
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

update{vars.Position.Update(game);}
