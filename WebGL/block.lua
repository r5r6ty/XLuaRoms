-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.



center = { x = 0, y = 0 }
speed = 10
rotate = 0

angleNum = 0
local blockAngle = { 0, 90, 180, 270 }
local isOnGround = false

--  0  1  2  3
--  4  5  6  7
--  8  9 10 11
-- 12 13 14 15
-- 方块的几种样式
local blockPattern = { { pat = { 0, 4, 8, 12 }, cet = 4, ang = { 0, 90 } },
                       { pat = { 1, 5, 9, 8 },  cet = 5, ang = { 0, 90, 180, 270 } },
                       { pat = { 0, 4, 8, 9 },  cet = 4, ang = { 0, 90, 180, 270 } },
                       { pat = { 0, 1, 4, 5 },  cet = 0, ang = { 0 } },
                       { pat = { 0, 1, 5, 6 },  cet = 1, ang = { 0, 90 } },
                       { pat = { 1, 4, 5, 6 },  cet = 5, ang = { 0, 90, 180, 270 } },
                       { pat = { 1, 2, 4, 5 },  cet = 1, ang = { 0, 90 } } }
-- 方块的几种颜色
local colorPattern = { { name = "red",   color = { 1, 0, 0, 1 } },
                       { name = "green", color = { 0, 1, 0, 1 } },
                       { name = "blue",  color = { 0, 0, 1, 1 } } }

myPattern = 0
myAngle = 0
myColor = {}

myBlocks = {}

function start()
    print("lua start...")
end

function update()
end

function fixupdate()

end

function ondestroy()
    print("lua destroy")
end

function move(x, y)
local e1 = {}
local e2 = {}
    for i = 0, self.transform.childCount - 1, 1 do
        local child = self.transform:GetChild(i)
            table.insert(e1, { x = CS.UnityEngine.Mathf.Round(child.position.x), y = CS.UnityEngine.Mathf.Round(child.position.y) })
            table.insert(e2, { x = CS.UnityEngine.Mathf.Round(child.position.x) + x, y = CS.UnityEngine.Mathf.Round(child.position.y) + y })
    end
    return e1, e2
end

function init(pattern)

    myPattern = blockPattern[pattern]

    myAngle = CS.Tools.Instance:RandomRangeInt(1, #myPattern.ang + 1)

    self.transform:Rotate(CS.UnityEngine.Vector3.forward * myPattern.ang[myAngle])
    
    local cx = myPattern.cet % 4
    local cy = myPattern.cet / 4

    center.x = CS.UnityEngine.Mathf.Round(cx)
    center.y = CS.UnityEngine.Mathf.Round(cy)

    for i, v in ipairs(myPattern.pat) do
        local x = v % 4
        local y = v / 4

        -- 实例化Prefab
        local block = CS.UnityEngine.GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Quad)
        block.transform.parent = self.transform

        -- 设置方块位置
        block.transform.localPosition = CS.UnityEngine.Vector3(CS.UnityEngine.Mathf.Floor(x) - CS.UnityEngine.Mathf.Floor(cx), -(CS.UnityEngine.Mathf.Floor(y) - CS.UnityEngine.Mathf.Floor(cy)), block.transform.localPosition.z)

        -- 随机设置方块颜色
        local c = colorPattern[CS.Tools.Instance:RandomRangeInt(1, 4)]
        local mr = block:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
        mr.material = CS.ObjectManager.Instance:GetO("logo")
        mr.material.color = CS.UnityEngine.Color(c.color[1], c.color[2], c.color[3], c.color[4])
        block.name = c.name

        table.insert(myBlocks, block)
    end
end

function GetNextAngle()
    local na = myAngle + 1
    if na > #myPattern.ang then
        return  1
    else
        return  na
    end
end