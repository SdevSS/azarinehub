if game.PlaceId == 126244816328678 then
	print("Loading AzarineHub CDID Script...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_DIG.lua"))()
elseif game.GameId == 2640407187 then
	print("Loading AzarineHub CDID Script...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_CDID.lua"))()
else
	game.Players.LocalPlayer:Kick("[AzarineHub] Game is not Supported!")
end
