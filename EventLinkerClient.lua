--[[

MIT License

Copyright (c) 2024 blarg!

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

local Remotes = game:GetService('ReplicatedStorage'):WaitForChild('EventLinkerRemotes')

local Enums = {
	['EVENT'] = 1,
	['EVENT_ONCE'] = 2,
	['EVENT_DESTRUCTIVE'] = 3,
	['RETURN'] = 4,
	['RETURN_ONCE'] = 5,
	['RETURN_DESTRUCTIVE'] = 6
}
local Events = {}
local EventLinker = { _VERSION = '1' }

local function findEvent(id : string)
	for key,event in pairs(Events) do -- hehe, get it, "key,events" lol
		if event.id == id then
			return key,event
		end
	end
	return nil
end

function EventLinker:CreateEvent(id : string, enum : string, func)
	assert(Enums[enum], "Enum; \"" .. enum .. "\" is not valid.")
	assert(not findEvent(id), "There is already an Event w/ the ID \"" .. id .. "\".")

	local event = {}

	event.id = id
	event.enum = enum

	event.func = nil
	if (func) then
		assert(type(func) == 'function', '"func" argument is not a function.')
		event.func = func
	end
	table.insert(Events,event)
end

function EventLinker:DestroyEvent(id : string)
	local Key,Event = findEvent(id)
	assert(Key, "Event w/ ID \"" .. id .. "\" could not be found.")

	table.remove(Events,Key)
end

function EventLinker:GetEvent(id : string)
	local _,Event = findEvent(id)
	return Event
end

function EventLinker:GetEvents()
	return Events
end

function EventLinker:HasLink(id : string)
	local _,Event = findEvent(id)
	if Event.func then return true end
	return false
end

function EventLinker:LinkFunction(id : string, func)
	assert(type(func) == 'function', '"func" argument is not a function.')

	local _,Event = findEvent(id)
	assert(not Event.func, "Event \"" .. id .. "\" already has a linked function.")
	Event.func = func
end

function EventLinker:DelinkFunction(id : string)
	local _,Event = findEvent(id)
	assert(Event.func, "Event \"" .. id .. "\" does not have a linked function.")
	Event.func = nil
end

function EventLinker:GetType(id : string)
	local _,Event = findEvent(id)
	return Event.enum
end

local function RunEvent(id, server, ...)
	local Event = EventLinker:GetEvent(id)

	if Event.enum == 'EVENT' then
		Event.func(server,unpack({...}))
	elseif Event.enum == 'EVENT_ONCE' then
		Event.func(server,unpack({...}))
		EventLinker:DelinkFunction(id)
	elseif Event.enum == 'EVENT_DESTRUCTIVE' then
		Event.func(server,unpack({...}))
		EventLinker:DestroyEvent(id)
	elseif Event.enum == 'RETURN' then
		return Event.func(server,unpack({...}))
	elseif Event.enum == 'RETURN_ONCE' then
		local blarg = {Event.func(server,unpack({...}))}
		EventLinker:DelinkFunction(id)
		return unpack(blarg)
	elseif Event.enum == 'RETURN_DESTRUCTIVE' then
		local blarg = {Event.func(server,unpack({...}))}
		EventLinker:DestroyEvent(id)
		return unpack(blarg)
	end
	return nil
end

function EventLinker:Fire(id : string, ...)
	local Event = EventLinker:GetEvent(id)
	assert(Event, "Event \"" .. id .. "\" does not exist.")

	return RunEvent(id, false, ...)
end

function EventLinker:SendToServer(id : string, ...)
	return Remotes.SendToServer:InvokeServer(id, ...)
end

Remotes.SendToClient.OnClientInvoke = function(id : string, ...)
	local Event = EventLinker:GetEvent(id)
	assert(Event, "Event \"" .. id .. "\" does not exist.")
	
	return RunEvent(id, true, ...)
end

return EventLinker
