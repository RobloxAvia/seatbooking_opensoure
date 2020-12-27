math.randomseed(1000000)

--[[
	
	bookingHandler
	server side / server script
	
	
--]]

local httpKey = "key-"..math.random(1, 50000)
local par = script.Parent:WaitForChild("Structures")
local rf = par:WaitForChild("Storage"):WaitForChild("bookingRF")
local re = par:WaitForChild("Storage"):WaitForChild("bookingRE")
local configuration = require(par:WaitForChild("Data"):WaitForChild("Configuration"))
local bookingList = {}
local fcShirtId = configuration.plrFcShirtId
local bcShirtId = configuration.plrBcShirtId

local seats = {
	EC = {
		name = "EC";
		seatsAvailable = 0;
	};
	
	BC = {
		name = "BC";
		seatsAvailable = 0;
	};

	FC = {
		name = "FC";
		seatsAvailable = 0;
	};	
}


local function updateSeats(class, seatAvailable)
	for i,classd in pairs(seats) do
		if classd.name == class then
			classd.seatsAvailable = seatAvailable
		end
	end
end

local function enoughSeats(class)
	for i,classd in pairs(seats) do
		if classd.name == class then
			if tonumber(classd.seatsAvailable) > 0 then
				return true
			else
				return false
			end
		end
	end
end

local function ownsClass(plr, class)
	if class == "FC" then
		if game:GetService("MarketplaceService"):PlayerOwnsAsset(plr, fcShirtId) then
			return true
		else
			return false
		end
	end
	
	if class == "BC" then
		if game:GetService("MarketplaceService"):PlayerOwnsAsset(plr, bcShirtId) then
			return true
		else
			return false
		end
	end

	if class == "EC" then
		return true
	end

end

local function hasBookedClass(plr, class)
	for i,booking in pairs(bookingList) do
		if booking.associatedUser == plr then
			return booking
		end
	end
end

local function nameUser(usr, name)
	repeat wait() until usr.Character -- waits til character has loaded
	for i,part in pairs(usr.Character:GetChildren()) do
		if part:FindFirstChild("NameTag") then
			part:Remove()
			local headPart = usr.Character:WaitForChild("Head")
			headPart.Transparency = 0
		end
	end

	if name.Value ~= "" then -- if username is specified
		local newName = Instance.new("Model", usr.Character)
		newName.Name = name
		if usr.Character:FindFirstChild("Body Colors") then -- fix body colors
			local bodyColors = usr.Character:WaitForChild("Body Colors"):Clone()
			bodyColors.Parent = newName
		end

		local newHead = usr.Character:WaitForChild("Head"):Clone()
		newHead.Parent = newName
		newHead:WaitForChild("face"):Destroy()
		local humanoidPart = Instance.new("Humanoid", newName)
		humanoidPart.Name = "NameTag"
		humanoidPart.MaxHealth = 0
		humanoidPart.Health = 0
		local weld = Instance.new("Weld", newHead)
		weld.Part0 = newHead
		weld.Part1 = usr.Character:WaitForChild("Head")
		usr.Character:WaitForChild("Head").Transparency = 1

	end

end

rf.OnServerInvoke = function(usr, event, key, ...)
	local args = {...}
	
	if event == "getKey" then
		return httpKey
	end

	if key == httpKey then

		if event == "bookClass" then
			local class = args[1]
			if ownsClass(usr, class) then
				if hasBookedClass(usr) then
					return false
				else
					if enoughSeats(class) then 
						local data = {
							associatedUser = usr;
							classBooked = class;
						}
						table.insert(bookingList, data)
						nameUser(usr, usr.Name.." // "..class)
						seats[class].seatsAvailable = seats[class].seatsAvailable-1
						re:FireAllClients("updateSeats", seats.EC.seatsAvailable, seats.BC.seatsAvailable, seats.FC.seatsAvailable)
						return true
					else
						return false
					end
				end
			else
				return false
			end
		end

		if event == "unbookClass" then
			local class = args[1]
			for i,booking in pairs(bookingList) do
				if booking.associatedUser == usr and booking.classBooked == args[1] then
					table.remove(bookingList, i)
					nameUser(usr, usr.Name) -- unname the user
					seats[class].seatsAvailable = seats[class].seatsAvailable+1
					re:FireAllClients("updateSeats", seats.EC.seatsAvailable, seats.BC.seatsAvailable, seats.FC.seatsAvailable)
					return true
				end
			end
		end

	else
		usr:Kick("http")
	end
end

re.OnServerEvent:connect(function(usr, event, key, ...)
	local args = {...}
	if key == httpKey then

		if event == "updateSeatAmount" then
			local classToUpdate = args[1]
			local seatsToUpdate = args[2]
			updateSeats(classToUpdate, seatsToUpdate)
			wait()
			re:FireAllClients("updateSeats", seats.EC.seatsAvailable, seats.BC.seatsAvailable, seats.FC.seatsAvailable) -- update seat values
		end
	else
		usr:Kick("http")
	end
end)


game:GetService("Players").PlayerRemoving:connect(function(plr)
	local bookedClass = hasBookedClass(plr, "")
	if bookedClass then
		local class = bookedClass.classBooked
		for i,booking in pairs(bookingList) do
			if booking.associatedUser == plr and booking.classBooked == class then
				table.remove(bookingList, i)
				seats[class].seatsAvailable = seats[class].seatsAvailable+1
				re:FireAllClients("updateSeats", seats.EC.seatsAvailable, seats.BC.seatsAvailable, seats.FC.seatsAvailable) -- update seat values
			end
		end
	end

end)
