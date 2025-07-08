if game.PlaceId == 126244816328678 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_DIG.lua"))()
elseif game.PlaceId == 9508940498 then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/SdevSS/azarinehub/refs/heads/main/AzarineHub_CDID.lua"))()
else
	Players.LocalPlayer:Kick("[AzarineHub] Game is not Supported!")
end
