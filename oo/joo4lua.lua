--[[
    desc: Java style object-oriented helper functions for Lua
    author: Elvin Zeng
    date: 2017-6-1
--]]


local P = {} --  package
if _REQUIREDNAME == nil then
    joo4lua = P
else
    _G[_REQUIREDNAME] = P
end
--  setmetatable(P, {__index = _G})
--  setfenv(1, P)


local SUPER_CLASS_FIELD_NAME = "__joo4lua_superClass"
local INTERFACES_FIELD_NAME = "__joo4lua_baseInterfaces"
local CLASS_OBJECT_FLAG_FIELD_NAME = "__joo4lua_isClass"
local INTERFACE_OBJECT_FLAG_FIELD_NAME = "__joo4lua_isInterface"


--  find member from super classes
local function findMember(member, superClasses)
    if not superClasses then
        return nil
    end

    for _, parentClass in ipairs(superClasses) do
        local v = parentClass[member]
        if v then return v end
    end
end

--  create a interface with specified super interfaces.
--  if number of parameters is zero, it will extends from {}.
function P.createInterface(...)
    local derivedInterface = {}
    derivedInterface[INTERFACES_FIELD_NAME] = {... }
    derivedInterface[INTERFACE_OBJECT_FLAG_FIELD_NAME] = true

    function derivedInterface:declareMedhod(methodName, methodDesc)
        if not methodName then
            error("First parameter 'method name' can not be nil.", 2)
        end
        if not methodDesc then
            error("Second parameter 'method description' can not be nil.", 2)
        end
        rawset(self, methodName, function()
            error("Method '" .. methodName .. "' is not still implemented. Method description:\n"
                    .. methodDesc, 2)
        end)
    end

    setmetatable(derivedInterface, {
        __index = function(table, key)
            return findMember(key, arg)
        end,
        __newindex = function (t, k, v)
            error("Can not add member to a interface. Use 'declareMedhod' to declare a method to interface.", 2)
        end
    })

    return derivedInterface
end

--  create class from specified super classes
local function createClass(...)
    local derivedClass = {}

    setmetatable(derivedClass, {
        __index = function(table, key)
            return findMember(key, arg)
        end
    })

    derivedClass[CLASS_OBJECT_FLAG_FIELD_NAME] = true
    function derivedClass:new(o)
        if self[CLASS_OBJECT_FLAG_FIELD_NAME] then
            local objWrapper = {}
            setmetatable(objWrapper, derivedClass)
            derivedClass.__index = derivedClass
            objWrapper[CLASS_OBJECT_FLAG_FIELD_NAME] = false

            o = o or {}
            setmetatable(o, objWrapper)
            objWrapper.__index = objWrapper
            return o
        else
            error("Only Class object can be instantiate, this object is an instance.", 2)
        end
    end

    return derivedClass
end

--  create a class with specified super class.
--  just single inheritance.
--  if number of parameters is zero, derived class will extends from {}.
function P.createClass(...)
    local superClass = {};
    if #arg > 1 then
        error("Java style object-oriented programming just support single inheritance.", 2)
    elseif 1 == #arg then
        superClass = arg[1]
    end
    local derivedClass = createClass(superClass)
    derivedClass[SUPER_CLASS_FIELD_NAME] = superClass

    return derivedClass
end

--  implements interfaces
function P.implements(...)
    local arg = {...}
    if not arg or #arg < 1 then
        error("First parameter 'class' can not be nil.", 2)
    end
    if not arg or #arg < 2 then
        error("Please specify interfaces to implements.", 2)
    end
    local class = arg[1]
    local baseInterfaces = {}
    for i = 2, #arg do
        if rawget(arg[i], INTERFACE_OBJECT_FLAG_FIELD_NAME) then
            table.insert(baseInterfaces, arg[i])
        else
            error("Parameter Type error, only interface can be implements.", 2)
        end
    end

    local extendedClass = createClass(...)
    extendedClass[INTERFACES_FIELD_NAME] = baseInterfaces
    extendedClass[SUPER_CLASS_FIELD_NAME] = class[SUPER_CLASS_FIELD_NAME]
    return extendedClass
end


return P