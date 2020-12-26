--[[
	
	bookingHandler
	client side / local script
	
	
--]]

--> variables
local par = game:GetService("Workspace"):WaitForChild("Seatbooking"):WaitForChild("Structures")
local pgui = game:GetService("ReplicatedStorage"):WaitForChild("app")
local rf = par:WaitForChild("Storage"):WaitForChild("bookingRF")
local re = par:WaitForChild("Storage"):WaitForChild("bookingRE")
local key = rf:InvokeServer("getKey")

local sgui = script.Parent
local mainFrame = sgui:WaitForChild("mainFrame")
local adminFrame = mainFrame:WaitForChild("adminFrame")
local bookingFrame = mainFrame:WaitForChild("bookingFrame")
local lastFrame = mainFrame:WaitForChild("lastFrame")
local classList = bookingFrame:WaitForChild("classList")

local plr = game:GetService("Players").LocalPlayer
local bookedClass = nil
local configuration = require(par:WaitForChild("Data"):WaitForChild("Configuration"))
local groupID = configuration.group_id
local adminRankID = configuration.admin_id


--> functions

local function pushNotification(status)
	local new = pgui:Clone()
	new.Parent = plr.PlayerGui
	new:WaitForChild("Container"):WaitForChild("text").Text = status
	new:WaitForChild("Container").Visible = true
	new:WaitForChild("Container"):TweenPosition(UDim2.new(0.005, 0,0.939, 0))
	wait(3)
	new:WaitForChild("Container"):TweenPosition(UDim2.new(-0.3, 0,0.939, 0))
	wait(0.9)
	new:Destroy()
end

local function hideAll(exempt)

	if exempt == "adminFrame" then
		if game:GetService("Players").LocalPlayer:GetRankInGroup(groupID) >= adminRankID then
			for i,instance in pairs(mainFrame:GetDescendants()) do
				if instance:IsA("Frame") then
					if instance.Name ~= exempt and instance.Parent.Name ~= exempt then
						instance.Visible = false
					else
						instance.Visible = true
					end
				end
			end
		end
	else
		local des = mainFrame:GetDescendants()
		for i,instance in pairs(des) do
			if instance:IsA("Frame")  then
				if instance.Name ~= exempt  and instance.Parent.Name ~= exempt then
					instance.Visible = false
				else
					instance.Visible = true
				end
			end
		end
	end
end



--> events
re.OnClientEvent:connect(function(event, ...)
	local args = {...}
	if event == "updateSeats" then
		local ecSeats = args[1]
		local bcSeats = args[2]
		local fcSeats = args[3]
		classList:WaitForChild("EC").seatsAvailable.Text = "Seats Left: "..ecSeats
		classList:WaitForChild("BC").seatsAvailable.Text = "Seats Left: "..bcSeats
		classList:WaitForChild("FC").seatsAvailable.Text = "Seats Left: "..fcSeats
	end
end)


-- button detections
adminFrame:WaitForChild("publicBtn").MouseButton1Down:connect(function()
	hideAll("bookingFrame")
end)

bookingFrame:WaitForChild("adminBtn").MouseButton1Down:connect(function()
	hideAll("adminFrame")
end)

lastFrame:WaitForChild("backBtn").MouseButton1Down:connect(function()
	hideAll("bookingFrame")
end)

-- booking stuff
classList:WaitForChild("EC").bookBtn.MouseButton1Down:connect(function()

	if bookedClass == "EC" then
		-- has booked this class already
		bookedClass = nil
		local result = rf:InvokeServer("unbookClass", key, "EC")
		if result == true then
			lastFrame:WaitForChild("className").Text = "N/A"
			classList:WaitForChild("EC"):WaitForChild("bookBtn").Text = "Book"
			pushNotification("Unbooked Class")
		else
			print("error unbooking")
		end
	else


		if bookedClass == nil then
			local result = rf:InvokeServer("bookClass", key, "EC")
			if result == true and bookedClass == nil and classList:WaitForChild("EC"):WaitForChild("bookBtn").Text == "Book" then
				-- booked successfully
				bookedClass = "EC"
				hideAll("lastFrame")
				lastFrame:WaitForChild("className").Text = bookedClass
				classList:WaitForChild("EC"):WaitForChild("bookBtn").Text = "Unbook"
				pushNotification("Booked Class")
			else
				print("error booking")
			end
		end
	end
end)

classList:WaitForChild("FC").bookBtn.MouseButton1Down:connect(function()

	if bookedClass == "FC" then
		-- has booked this class already
		bookedClass = nil
		local result = rf:InvokeServer("unbookClass", key, "FC")
		if result == true then
			lastFrame:WaitForChild("className").Text = "N/A"
			classList:WaitForChild("FC"):WaitForChild("bookBtn").Text = "Book"
			pushNotification("Unbooked Class")
		else
			print("error unbooking")
		end
	else
		if bookedClass == nil then
			local result = rf:InvokeServer("bookClass", key, "FC")
			if result == true and bookedClass == nil and classList:WaitForChild("FC"):WaitForChild("bookBtn").Text == "Book" then
				-- booked successfully
				bookedClass = "FC"
				hideAll("lastFrame")
				lastFrame:WaitForChild("className").Text = bookedClass
				classList:WaitForChild("FC"):WaitForChild("bookBtn").Text = "Unbook"
				pushNotification("Booked Class")
			else
				print("error booking")
			end
		end
	end
end)

classList:WaitForChild("BC").bookBtn.MouseButton1Down:connect(function()

	if bookedClass == "BC" then
		-- has booked this class already
		bookedClass = nil
		local result = rf:InvokeServer("unbookClass", key, "BC")
		if result == true then
			lastFrame:WaitForChild("className").Text = "N/A"
			classList:WaitForChild("BC"):WaitForChild("bookBtn").Text = "Book"
			pushNotification("Unbooked Class")
		else
			print("error unbooking")
		end
	else
		if bookedClass == nil then
			local result = rf:InvokeServer("bookClass", key, "BC")
			if result == true and bookedClass == nil and classList:WaitForChild("BC"):WaitForChild("bookBtn").Text == "Book" then
				-- booked successfully
				bookedClass = "BC"
				hideAll("lastFrame")
				lastFrame:WaitForChild("className").Text = bookedClass
				classList:WaitForChild("BC"):WaitForChild("bookBtn").Text = "Unbook"
				pushNotification("Booked Class")
			else
				print("error booking")
			end
		end
	end
end)


-- admin panel
adminFrame:WaitForChild("classList").EC.amountBox.Changed:connect(function()
	re:FireServer("updateSeatAmount", key, "EC", adminFrame:WaitForChild("classList").EC.amountBox.Text)
end)

adminFrame:WaitForChild("classList").BC.amountBox.Changed:connect(function()
	re:FireServer("updateSeatAmount", key, "BC", adminFrame:WaitForChild("classList").BC.amountBox.Text)
end)

adminFrame:WaitForChild("classList").FC.amountBox.Changed:connect(function()
	re:FireServer("updateSeatAmount", key, "FC", adminFrame:WaitForChild("classList").FC.amountBox.Text)
end)