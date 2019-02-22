-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

--local cs_coroutine = (require 'cs_coroutine')

local timecounter = 10
local speed = 1

local block = {}
local blockStack = {}

local tile = { width = 1, height = 1 }
local filed = { width = tile.width * 10, height = tile.height * 20 }

local coordinate = {}

local input = { up = 0, down = 0, left = 0, right = 0, space = 0 }

local colorPattern = { "red", "green", "blue" }

--local eliminateProcess = function()
--    while true do
--        coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
--    end
--end

local audioPlayer = nil

function eliminateProcess()
--	for i,v in ipairs(colorPattern) do
--	    for i,v in ipairs(blockStack) do
--        end
--    end
end

function start()
	print("lua start...")
	print("injected object", LCamera)
	print("injected object", LLight)
	print("injected object", LCanvas)

    GameInitialize()

    audioPlayer = self.gameObject:AddComponent(typeof(CS.UnityEngine.AudioSource));
    audioPlayer.clip = CS.ObjectManager.Instance:GetO("bomb")
end

function update()
    if CS.UnityEngine.Input.GetKeyDown(CS.UnityEngine.KeyCode.Escape) then
        CS.UnityEngine.SceneManagement.SceneManager.LoadScene("SampleScene")
    end
end

function fixupdate()

    if block.go == nil or block.lua.isOnGround then
        if block.go ~= nil then
            local last = DestroyBlock(block.go)
            --local result = cs_coroutine.start(eliminateProcess)
            --eliminateProcess()

--            for t, h in ipairs(last) do
--                local temp = {}
--                table.insert(temp, h)

--	            for i = 1, filed.width, 1 do
--    	            for j = -1, -filed.height, -1 do
--                        if coordinate[i][j] ~= nil and coordinate[i][j] ~= h then
--                            if coordinate[i + 1][j] == h and coordinate[i][j].name == h.name then
--                                table.insert(temp, coordinate[i][j])
--                            elseif coordinate[i - 1][j] == h and coordinate[i][j].name == h.name then
--                                table.insert(temp, coordinate[i][j])
--                            end
----                            if coordinate[i][j] ~= nil then
----                                print(coordinate[i][j].name)
----                            end
--                        end
--                    end
--                end

--                if #temp >= 3 then
--                    for i, v in ipairs(temp) do
--                        local x = CS.UnityEngine.Mathf.Round(v.transform.position.x)
--                        local y = CS.UnityEngine.Mathf.Round(v.transform.position.y)
--                        coordinate[x][y] = nil
--                        CS.UnityEngine.Object.Destroy(v)
--                    end
--                end
--            end
            for j = -1, -filed.height, -1 do
                local g = {}
                for i = 1, filed.width, 1 do
                    if coordinate[i][j] ~= nil then
                        table.insert(g, { go = coordinate[i][j], x = i, y = j })
                    end
                end
                if #g >= filed.width then
                    for i, v in ipairs(g) do
                        CS.UnityEngine.Object.Destroy(v.go)
                        coordinate[v.x][v.y] = nil
                    end
                    for l = -filed.height, -1, 1 do
	                    for k = 1, filed.width, 1 do
                            if coordinate[k][l] ~= nil and l > j then
                                local temp = coordinate[k][l]
                                coordinate[k][l] = nil
                                temp.transform.position = CS.UnityEngine.Vector3(temp.transform.position.x, temp.transform.position.y - 1, temp.transform.position.z)
                                coordinate[k][l - 1] = temp
                            end
                        end
                    end
                end
            end
        end
        timecounter = 0
		generateBlock(CS.Tools.Instance:RandomRangeInt(1, 8))
    end

    inputController()

	if timecounter >= speed then

        if input.down == 0 then
            local dy = movePosition(block.go, 0, -1)
            if not dy then
                block.lua.isOnGround = true
            end
        end

		timecounter = 0
	else
		timecounter = timecounter + CS.UnityEngine.Time.deltaTime
	end
end

function ondestroy()
	print("lua destroy")
end

function GameInitialize()
	for i = 1, filed.width, 1 do
            coordinate[i] = {}
    	for j = 2, -filed.height, -1 do
            coordinate[i][j] = nil
        end
    end

    LCamera.transform.position = CS.UnityEngine.Vector3(filed.width / 2 + 0.5, -filed.height / 2 - 0.5, LCamera.transform.position.z)

    local bg2 = CS.UnityEngine.GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Quad)
    bg2.transform.localScale = CS.UnityEngine.Vector3(filed.width + 1, filed.height + 1, 1)
    bg2.transform.position = CS.UnityEngine.Vector3(filed.width / 2 + 0.5, -filed.height / 2 - 0.5, bg2.transform.position.z + 2)

    local mr2 = bg2:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    mr2.material = CS.ObjectManager.Instance:GetO("logo")
    mr2.material.color = CS.UnityEngine.Color.white

    local bg1 = CS.UnityEngine.GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Quad)
    bg1.transform.localScale = CS.UnityEngine.Vector3(filed.width, filed.height, 1)
    local  mr1 = bg1:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    mr1.material = CS.ObjectManager.Instance:GetO("logo")
    mr1.material.color = CS.UnityEngine.Color.black
    bg1.transform.position = CS.UnityEngine.Vector3(filed.width / 2 + 0.5, -filed.height / 2 - 0.5, bg1.transform.position.z + 1)

    block = { go = nil, lua = nil }
end

-- 生成方块函数
function generateBlock(pt)


--    local pattern = blockPattern[num]

    local parent = CS.UnityEngine.GameObject("block")

    -- 设置方块位置
    parent.transform.position = CS.UnityEngine.Vector3(5, 1, parent.transform.position.z)
--    parent.transform.eulerAngles = CS.UnityEngine.Vector3(0, 0, blockAngle[anum])

    -- 挂上lua脚本
	local script = parent:AddComponent(typeof(CS.LuaTestScript))

    -- 通过拿到scriptEnv来获取对象lua脚本的table，可以访问到其中的内容了
    local t = script.scriptEnv
    t.speed = 0
    t.init(pt)

    block.go = parent
    block.lua = t

    local isDead = registerPosition(parent)
    if isDead == false then
        for j = 2, -filed.height, -1 do
            for i = 1, filed.width, 1 do
                if coordinate[i][j] ~= nil then
                    CS.UnityEngine.Object.Destroy(coordinate[i][j])
                end
            end
        end
	    for i = 1, filed.width, 1 do
                coordinate[i] = {}
    	    for j = 2, -filed.height, -1 do
                coordinate[i][j] = nil
            end
        end
    end
end

function registerPosition(go)
    local canRegister = true
    for i = 0, go.transform.childCount - 1, 1 do
        local child = go.transform:GetChild(i)
        local x = CS.UnityEngine.Mathf.Round(child.position.x)
        local y = CS.UnityEngine.Mathf.Round(child.position.y)
        if coordinate[x][y] ~= nil then
            canRegister = false
        end
    end

    if (canRegister == true) then
        for i = 0, go.transform.childCount - 1, 1 do
            local child = go.transform:GetChild(i)
            local x = CS.UnityEngine.Mathf.Round(child.position.x)
            local y = CS.UnityEngine.Mathf.Round(child.position.y)
            coordinate[x][y] = child.gameObject
        end
    end
    return canRegister
end

function clearPosition(go)
    for i = 0, go.transform.childCount - 1, 1 do
        local child = go.transform:GetChild(i)
        local x = CS.UnityEngine.Mathf.Round(child.position.x)
        local y = CS.UnityEngine.Mathf.Round(child.position.y)
        coordinate[x][y] = nil
    end
end

function detectivePosition(go, tx, ty)
    for i = 0, go.transform.childCount - 1, 1 do
        local child = go.transform:GetChild(i)
        local x = CS.UnityEngine.Mathf.Round(child.position.x + tx)
        local y = CS.UnityEngine.Mathf.Round(child.position.y + ty)

        if detectiveRim(x, y) then
            if coordinate[x][y] ~= nil and coordinate[x][y].transform.parent ~= go.transform then
                return false
            end
        else
            return false
        end
    end
    return true
end

function detectiveRim(x, y)
    if x > filed.width or x < 1 or y < -filed.height then
        return false
    else
        return true
    end
end

function movePosition(go, x, y)
    local canMoveX = x ~= 0 and detectivePosition(go, x, 0)
    if canMoveX then
        clearPosition(go)
        go.transform.position = CS.UnityEngine.Vector3(go.transform.position.x + x, go.transform.position.y + 0, go.transform.position.z)
    end
    local canMoveY = y ~= 0 and detectivePosition(go, 0, y)
    if canMoveY then
        clearPosition(go)
        go.transform.position = CS.UnityEngine.Vector3(go.transform.position.x + 0, go.transform.position.y + y, go.transform.position.z)
    end
    if canMoveX or canMoveY then
        registerPosition(go)
    end
    return canMoveY
end

function detectiveRotation(go, lua)
    local ap = lua.GetNextAngle()
    local angle = lua.myPattern.ang[ap]
    local canRotate = true

    local cx = go.transform.position.x
    local cy = go.transform.position.y
    for i = 0, go.transform.childCount - 1, 1 do
        local child = go.transform:GetChild(i)

        local vector = CS.UnityEngine.Quaternion.AngleAxis(go.transform.eulerAngles.z - angle, CS.UnityEngine.Vector3.forward) * (child.position - go.transform.position)
        local x = CS.UnityEngine.Mathf.Round(vector.x + cx)
        local y = CS.UnityEngine.Mathf.Round(vector.y + cy)

        if detectiveRim(x, y) then
            if coordinate[x][y] ~= nil and coordinate[x][y].transform.parent ~= go.transform then
                canRotate = false
                break
            end
        else
            canRotate = false
            break
        end
    end

    if canRotate then
        clearPosition(go)
        go.transform.eulerAngles = CS.UnityEngine.Vector3(go.transform.eulerAngles.x, go.transform.eulerAngles.y, angle)
        registerPosition(go)
        lua.myAngle = ap
    end
end

function inputController()
    if CS.UnityEngine.Input.GetKey(CS.UnityEngine.KeyCode.W) then
        input.up  = input.up + 1
    else
        input.up  = 0
    end
    if CS.UnityEngine.Input.GetKey(CS.UnityEngine.KeyCode.S) then
        input.down  = input.down + 1
    else
        input.down  = 0
    end
    if CS.UnityEngine.Input.GetKey(CS.UnityEngine.KeyCode.A) then
        input.left  = input.left + 1
    else
        input.left  = 0
    end
    if CS.UnityEngine.Input.GetKey(CS.UnityEngine.KeyCode.D) then
        input.right  = input.right + 1
    else
        input.right  = 0
    end
    if CS.UnityEngine.Input.GetKey(CS.UnityEngine.KeyCode.Space) then
        input.space  = input.space + 1
    else
        input.space  = 0
    end

    if block.go and block.lua then
        if input.left == 1 or (input.left > 10 and input.left % 2 == 0) then
            movePosition(block.go, -1, 0)
        elseif input.right == 1 or (input.right > 10 and input.right % 2 == 0) then
            movePosition(block.go, 1, 0)
        end

        if input.up == 1 then
            detectiveRotation(block.go, block.lua)
        end

        if input.down > 0 and input.down % 2 == 0 then
            local dy = movePosition(block.go, 0, -1)
            if not dy then
                block.lua.isOnGround = true
            end
        end

        if input.space == 1 then
            while movePosition(block.go, 0, -1) do
            end
            block.lua.isOnGround = true
        end
    end
end

function DestroyBlock(go)
    audioPlayer:Play()
    local last = {}
    while go.transform.childCount > 0 do
        local child = go.transform:GetChild(0)
        child.parent = nil
        table.insert(blockStack, child.gameObject)
        table.insert(last, child.gameObject)
    end
    CS.UnityEngine.Object.Destroy(go)
    return last
end