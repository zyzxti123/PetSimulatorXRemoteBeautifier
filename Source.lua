local functions = {
    ["hookfunction"] = hookfunction,
    ["getupvalue"] = debug.getupvalue or getupvalue,
}

for key: string, value: (...any) -> (...any) in pairs(functions) do
    if not value then
        return game.Players.LocalPlayer:Kick(`[Z-Ware]: Unsupported Exploit: {key}`)
    end
end

local network = require(game.ReplicatedStorage.Library.Client.Network)
local _getName = debug.getupvalue(debug.getupvalue(network.Fire, 2), 2)
local _remote = debug.getupvalue(debug.getupvalue(network.Fire, 2), 1)
local _check = debug.getupvalue(network.Fire, 1)

local remoteReversedNamesHashedStorage = {{}, {}}
local remoteHashedNamesStorage = debug.getupvalue(_getName, 1)
for remoteType: number, remoteStorage: {[number]: {[string]: string}} in next, remoteHashedNamesStorage do
    for remoteName: string, remoteHashedName: string in next, remoteStorage do
        remoteReversedNamesHashedStorage[remoteType][remoteHashedName] = remoteName
        remoteHashedNamesStorage[remoteType][remoteName] = remoteName
    end
end

local remotesInstanceStorage = debug.getupvalue(_remote, 1)
for remoteType: number, remoteStorage: {[number]: {[string]: RemoteFunction | RemoteEvent}} in next, remotesInstanceStorage do
    for remoteHashedName: string, remoteInstance: RemoteFunction | RemoteEvent in next, remoteStorage do
        if remoteReversedNamesHashedStorage[remoteType] and remoteReversedNamesHashedStorage[remoteType][remoteHashedName] then
            local remoteName = remoteReversedNamesHashedStorage[remoteType][remoteHashedName]
            remoteInstance.Name = remoteName

            warn(`[Z-Ware]: Dehashed: {remoteHashedName} → {remoteName}`)
        else    
            warn(`[Z-Ware]: Failed To Dehash: {remoteHashedName}!`)
        end
    end
end

local _orginalGetName; _orginalGetName = hookfunction(_getName, function(remoteType: number, remoteName: string): string
    return remoteName
end)

local _orginalRemote; _orginalRemote = hookfunction(_remote, function(remoteType: number, remoteName: string): RemoteFunction | RemoteEvent
    local remoteHashedName = _orginalGetName(remoteType, remoteName)
    local remoteInstanceStorage = remotesInstanceStorage[remoteType]
    local remoteInstance = remoteInstanceStorage[remoteHashedName] or remoteInstanceStorage[remoteName]

    if not remoteInstance then
        remoteInstance = game.ReplicatedStorage:FindFirstChild(remoteHashedName)

        if not remoteInstance then
            return nil
        end

        remoteInstance.Name = remoteName
        remoteInstanceStorage[remoteName] = remoteInstance
        debug.getupvalue(_orginalRemote, 4)(remoteName, remoteInstance) --// remote handler or smthing

        warn(`[Z-Ware]: Dehashed In Real-Time: {remoteHashedName} → {remoteName}`)
    elseif remoteInstance.Name ~= remoteName then
        remoteInstance.Name = remoteName
        remoteInstanceStorage[remoteName] = remoteInstance

        warn(`[Z-Ware]: Dehashed In Real-Time: {remoteHashedName} → {remoteName}`)
    end

    return remoteInstance
end)

local _orginalCheck; _orginalCheck = hookfunction(_check, function(remoteName: string): boolean
    return true
end)
