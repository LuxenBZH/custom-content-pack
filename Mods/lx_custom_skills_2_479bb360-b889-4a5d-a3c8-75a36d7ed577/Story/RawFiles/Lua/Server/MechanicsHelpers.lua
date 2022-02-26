function CheckEsvCharacter(character)
    if type(character) == "string" then
        return Ext.GetCharacter(character)
    else
        return character
    end
end


-------- Turn listeners (delay check)
local TurnListeners = {
    Start = {},
    End = {}
}

Ext.RegisterOsirisListener("CharacterGuarded", 1, "before", function(character)
    ObjectSetFlag(character, "HasDelayed")
end)

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "before", function(character)
    if ObjectGetFlag(character, "HasDelayed") == 0 then
        for i, listener in pairs(TurnListeners.End) do
            listener.Handle(character)
        end
    end
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", function(character)
    if ObjectGetFlag(character, "HasDelayed") == 1 then
        ObjectClearFlag(character, "HasDelayed")
    else
        for i, listener in pairs(TurnListeners.Start) do
            listener.Handle(character)
        end
    end
end)

function RegisterTurnTrueStartListener(func)
    table.insert(TurnListeners.Start, {
        Name = "",
        Handle = func
    })
end

function RegisterTurnTrueEndListener(func)
    table.insert(TurnListeners.End, {
        Name = "",
        Handle = func
    })
end

--- @class Queue 
Queue = {}

function Queue.new ()
    return {first = 1, last = 0}
end

function Queue.pushright (Queue, value)
    local last = Queue.last + 1
    Queue.last = last
    Queue[last] = value
end

function Queue.popright (Queue)
    local last = Queue.last
    if Queue.first > last then return nil end
    local value = Queue[last]
    Queue[last] = nil         -- to allow garbage collection
    Queue.last = last - 1
    return value
end

--- @class AnimationChains
AnimationChains = {}

function RegisterAnimationChain(chain)

end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", function(character, event)
    if AnimationChains[event] then
        PlayAnimation(character, AnimationChains[event][AnimationChains[event].last])
        Queue.popright(AnimationChains[event])
        if AnimationChains[event].last == 0 then
            AnimationChains[event] = nil
        end
    end
end)

function ChainAnimations(character, ...)
    local animations = {...}
    local id = "LX_AnimationChain_"..tostring(math.random(1, 9999999999))
    AnimationChains[id] = Queue.new()
    for i,anim in pairs(animations) do
        Queue.pushright(AnimationChains[id], anim)
    end
    PlayAnimation(character, animations[1], id)
end