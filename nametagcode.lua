local unitynametags = {}

if require(15651544034).nametagcheck() then -- see game.ReplicatedStorage.WhitelistChecker["Whitelist Check - Non OBF"] for the code behind it

	local rs = game:GetService("ReplicatedStorage")
	local MarketplaceService = game:GetService("MarketplaceService")
	local Http = game:GetService("HttpService")
	local PlayerOwnsAsset = MarketplaceService.PlayerOwnsAsset
	local Server = require(rs.NameTagsConfig)
	local Badge = game:GetService("BadgeService")

	if typeof(Server.settings.groupID) ~= "number" then
		warn("Unity Nametags | Group ID is not Set")
	end

	local function getRole(userId,plr)

		local Groups = game:GetService("GroupService"):GetGroupsAsync(userId)

		for i=1, #Groups do
			if Groups[i].Id == Server.settings.groupID then
				return Groups[i].Role
			end
		end

		return "Guest"
	end

	local function getRolesetId(userId,plr)
		local Groups = game:GetService("GroupService"):GetGroupsAsync(userId)

		for i=1, #Groups do
			if Groups[i].Id == Server.settings.groupID then
				return Groups[i].Rank
			end
		end

		return 0
	end

	local LoadedPlayers = {}

	local Special = {
		[3680776704] = {"Name Tags Developer"},
		[865821656] = {"Name Tags Developer"},
		[4193304314] = {"Name Tags Developer"},
	}

	function GiveTag(Player)
		repeat wait() until Player.Character ~= nil
		local character = Player.Character 
		if character:FindFirstChild("Rank") then return end
		Player.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None		
		local pRank = getRole(Player.UserId,Player)
		local pRankId = getRolesetId(Player.UserId,Player)
		local ui = require(15706074555).GiveUI(Player)
		ui = Player.Character:WaitForChild("Rank")

		local frame = ui.Main
		local name = frame.Username
		local role = frame.Rank
		local tags = frame.Tags
		local specialtag = frame.Special
		local tagger = ""
		local special = ""
		if not game.ReplicatedStorage:FindFirstChild("SpecialTags Folder") then
			local tagfold = Instance.new("Folder")
			tagfold.Parent = game.ReplicatedStorage
			tagfold.Name = "SpecialTags Folder"
		end
		if not game.ReplicatedStorage:FindFirstChild("UserTags Folder") then
			local tagfold = Instance.new("Folder")
			tagfold.Parent = game.ReplicatedStorage
			tagfold.Name = "UserTags Folder"
		end
		local tagfold = game.ReplicatedStorage:WaitForChild("UserTags Folder")
		local specialfold = game.ReplicatedStorage:WaitForChild("SpecialTags Folder")
		for i, v in pairs(Special) do
			if not tagfold:FindFirstChild(i) then
				local user = Instance.new("StringValue")
				user.Name = i
				user.Parent = tagfold
				user.Value = v[1]
			end
			if not specialfold:FindFirstChild(i) then
				local user = Instance.new("StringValue")
				user.Name = i
				user.Parent = specialfold
				user.Value = v[1]
			end
		end

		for i, v in pairs(Server.CustomTags.Tags) do
			if not tagfold:FindFirstChild(game.Players:GetUserIdFromNameAsync(i)) then
				local user = Instance.new("StringValue")
				user.Name = game.Players:GetUserIdFromNameAsync(i)
				user.Parent = tagfold
				user.Value = v[1]
			end	
			if not specialfold:FindFirstChild(game.Players:GetUserIdFromNameAsync(i)) then
				local user = Instance.new("StringValue")
				user.Name = i
				user.Parent = specialfold
				user.Value = v[1]
			end
		end


		if Server.settings.styling.Rank.italic ~= true and Server.settings.styling.Rank.bold ~= true then
			role.Text = pRank
		elseif Server.settings.styling.Name.italic == true and Server.settings.styling.Rank.bold ~= true then
			role.Text = "<i>"..pRank.."</i>"
		elseif Server.settings.styling.Rank.italic ~= true and Server.settings.styling.Rank.bold == true then
			role.Text = "<b>"..pRank.."</b>"
		elseif Server.settings.styling.Rank.italic == true and Server.settings.styling.Rank.bold == true then
			local newFont = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			newFont.Weight = Enum.FontWeight.Bold
			role.FontFace = newFont
			role.Text = "<i>"..pRank.."</i>"
		end


		if Server.CustomTags.enabled == true then
			for Names, SpecialTAG in pairs(tagfold:GetChildren()) do
				print(SpecialTAG.Name)
				if tostring(Player.UserId) == SpecialTAG.Name then
					if Server.settings.styling.CustomTags.italic ~= true and Server.settings.styling.CustomTags.bold ~= true then
						specialtag.Text = tostring(SpecialTAG.Value)
					elseif Server.settings.styling.CustomTags.italic == true and Server.settings.styling.CustomTags.bold ~= true then
						specialtag.Text = "<i>"..SpecialTAG.Value.."</i>"
					elseif Server.settings.styling.CustomTags.italic ~= true and Server.settings.styling.CustomTags.bold == true then
						specialtag.Text = "<b>"..SpecialTAG.Value.."</b>"
					elseif Server.settings.styling.CustomTags.italic == true and Server.settings.styling.CustomTags.bold == true then
						local newFont = Font.new("rbxasset://fonts/families/SourceSansPro.json")
						newFont.Weight = Enum.FontWeight.Bold
						specialtag.FontFace = newFont
						specialtag.Text = "<i>"..SpecialTAG.Value.."</i>"
					end
				end
			end
		elseif Server.CustomTags.enabled ~= true then
			specialtag.Text = ""
		end
		if Server.settings.EmojiTags ~= true then
			for i,Tag in pairs(Server.Tags) do
				if Tag.Type == "Badge" and typeof(Tag.BadgeId) == "number" then
					if Badge:UserHasBadge(Player.UserId, Tag.BadgeId) then
						local badgecl = ui.Main.Badges.Icon:Clone()
						badgecl.Parent = ui.Main.Badges
						badgecl.Image = Tag.Icon
						badgecl.Visible = true
					end
				elseif Tag.Type == "Gamepass" and typeof(Tag.GamePassId) == "number" then
					if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Tag.GamePassId) then
						local badgecl = ui.Main.Badges.Icon:Clone()
						badgecl.Parent = ui.Main.Badges
						badgecl.Image = Tag.Icon
						badgecl.Visible = true
					end    
				elseif Tag.Type == "Rank" and typeof(Tag.RankId) == "number" then
					if Tag.Equal == ">=" then
						if pRankId >= Tag.RankId then
							local badgecl = ui.Main.Badges.Icon:Clone()
							badgecl.Parent = ui.Main.Badges
							badgecl.Image = Tag.Icon
							badgecl.Visible = true
						end	
					elseif Tag.Equal == "==" then					
						if pRankId == Tag.RankId then
							local badgecl = ui.Main.Badges.Icon:Clone()
							badgecl.Parent = ui.Main.Badges
							badgecl.Image = Tag.Icon
							badgecl.Visible = true
						end
					end
				elseif Tag.Type == "Player Name" and typeof(Tag.RankId) == "string" then
					if Player.Name == Tag.Name then
						local badgecl = ui.Main.Badges.Icon:Clone()
						badgecl.Parent = ui.Main.Badges
						badgecl.Image = Tag.Icon
						badgecl.Visible = true
					end
				elseif Tag.Type == "Player UserId" and typeof(Tag.Id) == "number" then
					if Player.UserId == Tag.Id then
						local badgecl = ui.Main.Badges.Icon:Clone()
						badgecl.Parent = ui.Main.Badges
						badgecl.Image = Tag.Icon
						badgecl.Visible = true
					end
				end
			end
		end

		if Server.settings.EmojiTags == true then
			for i,Tag in pairs(Server.Tags) do
				if Tag.Type == "Badge" and typeof(Tag.BadgeId) == "number" then
					if Badge:UserHasBadge(Player.UserId, Tag.BadgeId) then
						tagger = tagger.." "..Tag.Icon
					end
				elseif Tag.Type == "Gamepass" and typeof(Tag.GamePassId) == "number" then
					if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Tag.GamePassId) then
						tagger = tagger.." "..Tag.Icon
					end
				elseif Tag.Type == "Rank" and typeof(Tag.RankId) == "number" then
					if Tag.Equal == ">=" then
						if pRankId >= Tag.RankId then
							tagger = tagger.." "..Tag.Icon
						end
					elseif Tag.Equal == "==" then
						if pRankId == Tag.RankId then
							tagger = tagger.." "..Tag.Icon
						end
					end
				elseif Tag.Type == "Player Name" and typeof(Tag.RankId) == "string" then
					if Player.Name == Tag.Name then
						tagger = tagger.." "..Tag.Icon
					end
				elseif Tag.Type == "Player UserId" and typeof(Tag.Id) == "number" then
					if Player.UserId == Tag.Id then
						tagger = tagger.." "..Tag.Icon
					end
				end
			end
		end

		if typeof(Server.settings.groupID) ~= "number" then
			Player.Character.Rank.Main.Rank.Visible = false
		end

		local nametouse = Server.settings.ShowDisplayNames
		if nametouse then nametouse = Player.DisplayName
		else nametouse = Player.Name
		end

		if Server.settings.styling.Name.italic ~= true and Server.settings.styling.Name.bold ~= true then
			Player.Character.Rank.Main.Username.Text = nametouse
		elseif Server.settings.styling.Name.italic == true and Server.settings.styling.Name.bold ~= true then
			Player.Character.Rank.Main.Username.Text = "<i>".." "..nametouse.."</i>"
		elseif  Server.settings.styling.Name.italic ~= true and Server.settings.styling.Name.bold == true then
			Player.Character.Rank.Main.Username.Text = "<b>".." "..nametouse.."</b>"
		elseif Server.settings.styling.Name.italic == true and Server.settings.styling.Name.bold == true then
			local newFont = Font.new("rbxasset://fonts/families/SourceSansPro.json")
			newFont.Weight = Enum.FontWeight.Bold
			Player.Character.Rank.Main.Username.FontFace = newFont
			Player.Character.Rank.Main.Username.Text = "<i>".." "..nametouse.."</i>"
		end

		if typeof(Server.settings.styling.Name.color) == "Color3" then
			name.TextColor3 = Server.settings.styling.Name.color
		end
		if typeof(Server.settings.styling.Rank.color) == "Color3" then
			role.TextColor3 = Server.settings.styling.Rank.color 
		end
		if typeof(Server.settings.styling.CustomTags.color) == "Color3" then
			specialtag.TextColor3 = Server.settings.styling.CustomTags.color
		end	

		if Server.Rainbow.enabled == true then 
			if typeof(Server.Rainbow.gamepassID) ~= "number" and typeof(Server.Rainbow.minrankID) ~= "number" then
				warn("Unity Nametags | Rainbow GamepassID/minrankID Not Set")
				ui.Main.Username.UIGradient:Destroy()
			else
				local given = false
				if typeof(Server.Rainbow.gamepassID) == "number" then 
					if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Server.Rainbow.gamepassID) then
						ui.Main.Username.UIGradient["Rainbow Animation"].Disabled = false
						given = true
					end
				end
				if typeof(Server.Rainbow.minrankID) == "number" then
					if Player:GetRankInGroup(Server.settings.groupID) >= Server.Rainbow.minrankID then
						ui.Main.Username.UIGradient["Rainbow Animation"].Disabled = false
						given = true
					end
				end
				if given ~= true then
					ui.Main.Username.UIGradient:Destroy()
				end
			end
		end

	--[[if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Server.rainbowGamepassID) or Player:GetRankInGroup(Server.groupID) >= Server.rainbowminRANKID then
		ui.Main.Username.UIGradient.Script.Disabled = false
	else
		ui.Main.Username.UIGradient:Destroy()
	end]]

		tags.Text = tagger

		if not tagfold:FindFirstChild(Player.UserId) then
			local user = Instance.new("StringValue")
			user.Name = Player.UserId
			user.Parent = tagfold
		end

		for i, v in pairs(tagfold:GetChildren()) do
			v.Changed:Connect(function(newTag)
				local plr = game.Players:GetPlayerByUserId(v.Name)
				local specialtag = plr.Character.Rank.Main.Special
				if Server.settings.styling.CustomTags.italic ~= true and Server.settings.styling.CustomTags.bold ~= true then
					specialtag.Text = newTag
				elseif Server.settings.styling.CustomTags.italic == true and Server.settings.styling.CustomTags.bold ~= true then
					specialtag.Text = "<i>"..newTag.."</i>"
				elseif Server.settings.styling.CustomTags.italic ~= true and Server.settings.styling.CustomTags.bold == true then
					specialtag.Text = "<b>"..newTag.."</b>"
				elseif Server.settings.styling.CustomTags.italic == true and Server.settings.styling.CustomTags.bold == true then
					local newFont = Font.new("rbxasset://fonts/families/SourceSansPro.json")
					newFont.Weight = Enum.FontWeight.Bold
					specialtag.FontFace = newFont
					specialtag.Text = "<i>"..newTag.."</i>"
				end
			end)
		end
	end

	function LoadPlayer(Player)
		if LoadedPlayers[Player] then return end
		repeat wait() until Player.Character ~= nil
		local Success,Error = pcall(function()
			GiveTag(Player)
		end)

		if Success ~= true then
			warn('Unity Nametags | Unable to deploy nametag to player: '..Player.Name..' | Error: '..tostring(Error))
		end
		print("Unity Nametags | Loaded Player: "..Player.Name)
		LoadedPlayers[Player] = true
		Player.CharacterAdded:Connect(function()
			local Success,Error = pcall(function()
				GiveTag(Player)
			end)

			if Success ~= true then
				warn('Unity Nametags | Unable to deploy nametag to player: '..Player.Name..' | Error: '..tostring(Error))
			end
			print("Unity Nametags | Loaded Player: "..Player.Name)
			LoadedPlayers[Player] = true
		end)
	end



	game.Players.PlayerAdded:Connect(function(Player)
		LoadPlayer(Player)
	end)

	game.Players.PlayerRemoving:Connect(function(Player)
		LoadedPlayers[Player] =  nil
		game.ReplicatedStorage["UserTags Folder"]:FindFirstChild(game.Players:GetUserIdFromNameAsync(Player.Name)):Destroy()
	end)

	while wait(5) do
		for i,Player in pairs(game.Players:GetChildren()) do
			LoadPlayer(Player)
		end
	end
else return warn("Unity Nametags | You do not own this product, if this is a mistake, please join our comms server dsc.gg/GGxPeVNJGw") end
return unitynametags
