-- Sky Striker Special Maneuver - Maintenance
-- ID: 90600023
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Trục xuất các lá bài để xáo trộn vào Deck và trả bài về tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) 
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Tự trục xuất từ Mộ khi có "Sky Striker" Monster được Special Summon để rút 2 lá
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)) 
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

s.listed_series={0x115}

-- ==================================================
-- LOGIC HIỆU ỨNG 1 (Hỗ trợ cả bài Banish Face-down)
-- ==================================================
function s.mfilter(c)
	return (c:IsSetCard(0x115) or c:IsOriginalSetCard(0x115)) 
		and (c:IsMonster() or c:IsOriginalType(TYPE_MONSTER)) 
		and c:IsAbleToDeck()
end

function s.sfilter(c)
	return (c:IsSetCard(0x115) or c:IsOriginalSetCard(0x115)) 
		and (c:IsSpell() or c:IsOriginalType(TYPE_SPELL)) 
		and c:IsAbleToDeck()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then 
		return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_REMOVED,0,1,nil)
			and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_REMOVED,0,1,2,nil) 
	g1:Merge(g2)
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if ct>0 then
			local og=Duel.GetOperatedGroup()
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
				local shuffled_count = og:GetCount()
				local max_return = math.floor(shuffled_count / 3)
				
				if max_return > 0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
					local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max_return,nil)
					if #rg>0 then
						Duel.HintSelection(rg)
						Duel.SendtoHand(rg,nil,REASON_EFFECT)
					end
				end
			end
		end
	end
end

-- ==================================================
-- LOGIC HIỆU ỨNG 2
-- ==================================================
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x115) and c:IsFaceup()
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end