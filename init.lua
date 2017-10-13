noobs = {}
releaseCoords = {x = 60, y = -2, z = 267}
reformationCoords = {x = -191, y = -3000, z = 326}
respawnCoords = {x = -133, y = -2994, z = 367}
local noobDataPath = minetest.get_worldpath() .. "/"

function loadNoobs(path)
	local file = io.open(path .. "noobs.txt", "r")
	if not file then return false end
	noobs = minetest.deserialize(file:read("*all"))
	file:close()
	return noobs
end

function saveNoobs(path)
	local file = io.open(path .. "noobs.txt", "w")
	if not file then return false end
	file:write(minetest.serialize(noobs))
	file:close()
	return true
end

function releaseNoobs()
	for _, noob in ipairs(noobs) do
		local player = minetest.get_player_by_name(noob)
		local pPrivs = minetest.get_player_privs(noob)
		pPrivs.wasnoob = true
		if player then
			player:setpos(releaseCoords)
			pPrivs.wasnoob = nil
		end
		pPrivs.noob = nil
		pPrivs.home = true
		minetest.set_player_privs(noob, pPrivs)
	end
	saveNoobs(noobDataPath)
end

local function releaseOfflineNoobs(player)
	local pPrivs = minetest.get_player_privs(player:get_player_name())
	if pPrivs.wasnoob then
		player:setpos(releaseCoords)
		pPrivs.wasnoob = nil
		minetest.set_player_privs(player:get_player_name(), pPrivs)
		saveNoobs(noobDataPath)
	end
end

local function respawnNoob(player)
	local pPrivs = minetest.get_player_privs(player:get_player_name())
	if pPrivs.noob then
		player:setpos(respawnCoords)
		return true
	end
end

minetest.register_on_joinplayer(releaseOfflineNoobs)

minetest.register_chatcommand("ttr", {
params = "<player>",
description = "Teleport To Reformation. Teleport <player> to the reformation center",
privs = {server = true},
func = function(name, pName)
	local player = minetest.get_player_by_name(pName)
	if player then
		local pPrivs = minetest.get_player_privs(pName)
		pPrivs.noob = true
		pPrivs.wasnoob = nil
		pPrivs.home = nil
		minetest.set_player_privs(pName, pPrivs)
		player:setpos(reformationCoords)
		table.insert(noobs, pName)
		saveNoobs(noobDataPath)
		minetest.chat_send_player(name, pName .. " has been sent to the reformation center.")
	else
		minetest.chat_send_player(name, "Error: There is no player by the name of " .. pName .. " connected.")
	end
end
})

minetest.register_on_respawnplayer(respawnNoob)

loadNoobs(noobDataPath)
