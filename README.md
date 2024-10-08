# EventLinker
EventLinker is a Roblox library made to alter client-server communications by replacing it with a more minimal structure.

# Instructions
Place "EventLinker", which should be a ModuleScript, wherever in ServerStorage. Just make sure it is in a place clients cannot access.<br/>
Place "EventLinkerClient", which should again be a ModuleScript, wherever in ReplicatedStorage, someplace the client can easily access.<br/><br/>

Create a Folder called "EventLinkerRemotes" in ReplicatedStorage, where it should contain two RemoteFunctions, "SendToClient" & "SendToServer".

# Functions
## Server Functions (EventLinker)
`:CreateEvent(id : string, enum : string)`<br/>
Creates a new, empty Event. It does not have a linked function, but you can optionally include a function argument to automatically provide one.<br/><br/>
`enum` describes the type of Event it is, which can be the following;
* `EVENT` - A regular event. Cannot return anything.
* `EVENT_ONCE` - Similar to `EVENT`. Automatically delinks function when executed.
* `EVENT_DESTRUCTIVE` - Similar to `EVENT`. Automatically deletes event when executed.
* `RETURN` - An event that is able to return data.
* `RETURN_ONCE` - Similar to `RETURN`. Automatically delinks function when executed.
* `RETURN_DESTRUCTIVE` - Similar to `RETURN`. Automatically deletes event when executed.

Note: No two Events can have the same ID.

`:DestroyEvent(id : string)`<br/>
Destroys the given Event, if found.

`:HasLink(id : string)`<br/>
Returns `true` if the Event has a linked function. Will otherwise return `false`.

`:LinkFunction(id : string, func : function)`<br/>
Links a function to the following Event.

`:DelinkFunction(id : string)`<br/>
Removes the linked function to the given Event.

`:GetType(id : string)`<br/>
Returns the type of the given Event.

`:GetEvent(id : string)`<br/>
Returns the given Event, which has three attributes; `.id`, `.enum`, `.func`.

`:GetEvents()`<br/>
Returns all created Events.

`:Fire(id : string, ...)`<br/>
Fires and executes the given Event.

`:SendToClient(id : string, player : Player, ...)`<br/>
Sends a message to the given Player to run a local Event on their end.

`:SendToClients(id : string, players : table, ...)`<br/>
Sends a message to all Players in the table to run a local Event on their ends.

`:Broadcast(id : string, ...)`<br/>
Sends a message to all Players in the server to run a local Event on their ends.

## Client Functions (EventLinkerClient)
Most functions from <b>Server Functions</b> are present here, with the `:SendToClient()`, `:SendToClients()`, & `:Broadcast()` functions being absent.<br/>
Running Events will be done locally.

`:SendToServer(id : string, ...)`<br/>
Sends a message to the Server to run an Event on its side.

# Examples
## Server-side Event
```lua
EventLinker:CreateEvent('ChangeColor','EVENT',function(ply, color)
  if (not ply) then return end
  assert(typeof(color) == 'Color3', '"color" argument is not a Color3.')
  
  workspace.Baseplate.Color = color
  EventLinker:SendToClient('YouDidIt!',ply)
end)
```

## Client-side Event
```lua
EventLinker:CreateEvent('YouDidIt!','EVENT',function(server)
  if (not server) then return end
  print 'I did it!'
end)

EventLinker:SendToServer('ChangeColor', Color3.new(math.random(),math.random(),math.random()))
```

## Sanity Checks
The `ply` and `server` arguments are provided for Server- and Client-sided Events respectively in order to allow for Sanity Checks, as presented above.
