if game.PlaceId == 126244816328678 then
	print("Loading AzarineHub DIG Script...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_DIG.lua"))()
elseif game.GameId == 2640407187 then
	print("Loading AzarineHub CDID Script...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_CDID.lua"))()
elseif game.GameId == 6701277882 then
	print("Loading AzarineHub FISH IT Script...")
	loadstring(game:HttpGet('https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_FISHIT.lua'))()
elseif game.GameId == 8384560791 then
	print("Loading AzarineHub MT ATIN Script...")
	loadstring(game:HttpGet('https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_ATIN.lua'))()
elseif game.GameId == 6331902150 then
	print("Loading AzarineHub Forsaken Script...")
	loadstring(game:HttpGet('https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_Forsaken.lua'))()
else
	game.Players.LocalPlayer:Kick("[AzarineHub] Game is not Supported!")
end
