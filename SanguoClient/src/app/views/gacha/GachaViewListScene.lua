
local GachaViewListScene = class("GachaViewListScene", cc.load("mvc").ViewBase)
GachaViewListScene.NEXTSCENE = "battle/ChapterScene"
local static_model_gachaView = _REQUIRE("model/static/model_gachaView.lua") 
local model_static_library = _REQUIRE("model/static/model_static_library.lua")
local model_monster = _REQUIRE("model/static/model_monster.lua")
--_REQUIRE "src/packages/packet/Packet_Regester"
GachaViewListScene.STOPFRAME = 30
GachaViewListScene.RESOURCE_FILENAME = "Scene/ArenaRankPop.csb"
function GachaViewListScene:onCreate()
    local ArenaRankPop = self:getResourceNode():getChildByName("ArenaRankPop")
    local Panel_C = ArenaRankPop:getChildByName("Panel_C")
    self.Panel_Center = Panel_C:getChildByName("Panel_Center")
    local Panel_Top = ArenaRankPop:getChildByName("Panel_Top")
    local Panel_Bg = ArenaRankPop:getChildByName("Panel_Bg")
    SCREEN_TOP(Panel_Top)
    SCREEN_SCALE_BG(Panel_Bg)
    local gachaType = self.args[1]
    --关闭按钮
--    local  Button_Close=Panel_Top:getChildByName("Button_Close")
--    Button_Close:setVisible(false)
    local  Button_Back=Panel_Top:getChildByName("Button_Back")
    Button_Back:addTouchEventListener(function(sender,eventType)
        if eventType==2 then
            SWITSCENE("gacha/GachaScene")

        end
    end
    )
    local  Button_3=self.Panel_Center:getChildByName("Button_3")
    local  Text_2=self.Panel_Center:getChildByName("Text_2")
    Button_3:setVisible(false)
    Text_2:setVisible(false)
    
    local  Text_1=self.Panel_Center:getChildByName("Text_1")
    Text_1:setString("可能获得")
    self.buttons = {}
    local tabNames ={"英雄 ","进阶材料 ","其他"}
    for i=1,4 do
        local ProjectNode =self.Panel_Center:getChildByName("ProjectNode_"..i)
        ProjectNode:setVisible(false)
        if i<= #tabNames then
            ProjectNode:setVisible(true)
            local btn = ProjectNode:getChildByName("Panel_tab"):getChildByName("Button_Select_1")
            self.buttons[i] = btn
            btn:setTitleText(tabNames[i])
            btn:addTouchEventListener(function(sender,eventType)
                if eventType==2 then
                    self:setIndex(sender:getTag())
                    self:initItem(sender:getTag())
--                    if sender:getTag()==1 then
--                        self:initTreasureItem()
--                    elseif sender:getTag()==2 then
--                        self:initTreasureItemPart()
--                    end
                end

            end)
        end

    end
    self.totalItems = static_model_gachaView:getItemByGachaType(gachaType)
    self:setIndex(1)
    self:initItem(1)
end



function GachaViewListScene:initItem(type)
    self.type = type
    self.scrollView = self.Panel_Center:getChildByName("HeroScrollView_1")
    self.scrollView:removeAllChildren()
    self.items = self.totalItems[self.type]
    if self.items == nil then
    	return
    end
    table.sort(self.items,function(item1,item2)
        if item1.isNew ~= item2.isNew then
            return item1.isNew > item2.isNew
        elseif item1.order ~= item2.order then
            return item1.order > item2.order
        else
            
        end
    end)
    
    self.space = 0
    if self.type ==1 then
        self.col = 3
        self.rowSpace = 0
        self.colSpace = 0
        self.itemScale = 1
    else
        self.col = 5
        self.rowSpace = 50
        self.colSpace = 30
        self.itemScale = 1.13
    end
    
    if self.type == 1 then
        self.node=self:createNode("Node/Node_Cacha_PVW.csb")
        self.item = self.node:getChildByName("Node_Cacha_PVW")
    else
        self.node=self:createNode("Node/Node_Treasure_Bag2.csb")
        self.item = self.node:getChildByName("Panel_Treasure_Icon")
        self.item:setScale(self.itemScale) 
    end
    local size = self.item:getContentSize()
    self.contentSize =cc.size(size.width * self.itemScale,size.height * self.itemScale)


    
    
    local num = #self.items
    self.sSize=cc.size(self.scrollView:getInnerContainerSize().width,math.max(self.scrollView:getContentSize().height,(self.contentSize.height+self.colSpace)*math.ceil(num/self.col)));
    --cclog("sssss"..sSize.width)
    self.scrollView:setInnerContainerSize(self.sSize)
    local count = 5
    self:initNormalItemRange(1,math.min(num,count)) 
    if num-count>0 then
        local timerId = Timer:runOnce(function(dt, data, timerId)
            self:initNormalItemRange(count+1,num)
        end,0.2)
    else

    end
end

function GachaViewListScene:initNormalItemRange(start,endIndex)
    for i=start,endIndex do
        local newItem = self.scrollView:getChildByTag(i)
        if newItem == nil then
            newItem = self.item:clone()
            self.scrollView:addChild(newItem)
        end
        local x,y
        local data =  self.items[i]
        if self.type ==1 then
            x= (self.contentSize.width/2-20) + (self.contentSize.width-25)*((i-1)%self.col);
            y=self.sSize.height-(self.contentSize.height-20)*math.floor((i-1)/self.col)-self.contentSize.height/2
            local star = model_monster:getStar(data.itemId)
            local Panel_Role = newItem:getChildByName("Panel_Role")
            local Panel_R = Panel_Role:getChildByName("Panel_R")
            local Image_2 = Panel_R:getChildByName("Image_2")
            local Panel_Star = Panel_Role:getChildByName("Panel_Star")
            local Text_1 = Panel_Role:getChildByName("Text_1")
            local Image_6 = newItem:getChildByName("Image_6")
            Image_6:setVisible(data.isNew == 1)
            --Text_1:setAnchorPoint(cc.p(0.5,1))
            Text_1:setContentSize(cc.size(60,300))
            Text_1:ignoreContentAdaptWithSize(false)
            Text_1:setString(model_static_library:getName(data.itemId,pbCommon.ObjectType.Monster))
            self:initStar(star,Panel_Star)
            Image_2:loadTexture(model_monster:getHalf(data.itemId))
        else
            x= ((self.contentSize.width/2 + 5 ) + (self.contentSize.width-20 + self.rowSpace)*((i-1)%self.col));
            y=self.sSize.height-(self.contentSize.height + self.colSpace )*math.floor((i-1)/self.col)-self.contentSize.height/2-8
            self:initBag2(data.itemId,data.itemType,newItem)
--            local Image_2 = newItem:getChildByName("Image_2")
--            Image_2:setVisible(data.isNew == 1)
        end
        newItem:setPosition(cc.p(x,y))
        newItem:setTag(i);
        
    end
end



function GachaViewListScene:dlgCallBack(data)

end

function GachaViewListScene:initTreasureItemRange(start,endIndex)
    --cclog("timeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
    for i=start,endIndex do
        local newItem = self.scrollView:getChildByTag(i)
        if newItem == nil then
            newItem = self.item:clone()
            self.scrollView:addChild(newItem)
        end
        local data = self.treasureList[i]
        local index = i-1
        newItem:setTag(i);

        
    end
end

function GachaViewListScene:initUi()
    local panel_Bottom=self:getResourceNode():getChildByName("Panel_Bottom")
    for i=1, 5 do
        local item=panel_Bottom:getChildByName("Node_Item1_"..i)

    end
end
return GachaViewListScene
