--[[
    desc: joo4lua test
    author: Elvin Zeng
    date: 2017-6-1
--]]

oo = require "joo4lua"

local SpeakingAblity = oo.createInterface()
SpeakingAblity:declareMedhod("speak", [[
    --  talk with others.
    function speak(str)
        -- print(str)
    end
]])
local WritingAbility = oo.createInterface()
WritingAbility:declareMedhod("write", [[
    --  write characters to paper or other medias.
    function write(str)
        -- print(str)
    end
]])
local KnowingChinese = oo.createInterface(SpeakingAblity, WritingAbility)
KnowingChinese:declareMedhod("speakChinese", [[
    --  speak Chinese.
    function speakChinese(str)
        -- print(str)
    end
]])
local KnowingEnglish = oo.createInterface(SpeakingAblity, WritingAbility)
KnowingEnglish:declareMedhod("speakEnglish", [[
    --  speak English.
    function speakEnglish(str)
        -- print(str)
    end
]])
local Named = oo.createInterface()
Named:declareMedhod("getName", [[
    --  return name
    function getName()
        return self.name
    end
]])
Named:declareMedhod("setName", [[
    --  set name
    function setName(name)
        self.name = name
    end
]])


local Animal = oo.createClass()
function Animal:run()
    print("running...")
end
local Human = oo.createClass(Animal)
Human = oo.implements(Human, SpeakingAblity, WritingAbility, Named)
function Human:setName(name)
    self.name = name
end
function Human:getName(name)
    return self.name
end
function Human:write(str)
    print("I can write: " .. str)
end
local human = Human:new()
human:setName("Elvin Zeng")
print(human:getName())


local Chinese = oo.createClass(Human)
Chinese = oo.implements(Chinese, KnowingChinese)
function Chinese:speakChinese(str)
    print(str)
end
local chinese = Chinese:new()
chinese:speakChinese("你好！")

local American = oo.createClass(Human)
American = oo.implements(American, KnowingEnglish)

local american = American:new()
american:run()
american:write("write test...")
american:speakEnglish("hello")


