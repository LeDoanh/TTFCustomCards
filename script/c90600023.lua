-- Sky Striker Special Maneuver - Maintenance
-- ID: 90600023
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Trục xuất các lá bài để xáo trộn vào Deck và trả bài về tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))[cite: 17]
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
	e2:SetDescription(aux.Stringid(id,1))[cite: 17]
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

s.listed_series={0x115}[cite: 17]

-- ==================================================
-- LOGIC HIỆU ỨNG 1 (Hỗ trợ cả bài Banish Face-down)
-- ==================================================
function s.mfilter(c)
	return (c:IsSetCard(0x115) or c:IsOriginalSetCard(0x115)) 
		and (c:IsMonster() or c:IsOriginalType(TYPE_MONSTER)) 
		and c:IsAbleToDeck()[cite: 17]
end

function s.sfilter(c)
	return (c:IsSetCard(0x115) or c:IsOriginalSetCard(0x115)) 
		and (c:IsSpell() or c:IsOriginalType(TYPE_SPELL)) 
		and c:IsAbleToDeck()[cite: 17]
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end[cite: 17]
	if chk==0 then [cite: 17]
		return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_REMOVED,0,1,nil)[cite: 17]
			and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_REMOVED,0,1,nil)[cite: 17]
	end[cite: 17]
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)[cite: 17]
	local g1=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_REMOVED,0,1,1,nil)[cite: 17]
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)[cite: 17]
	local g2=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_REMOVED,0,1,2,nil) [cite: 17]
	g1:Merge(g2)[cite: 17]
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,tp,LOCATION_REMOVED)[cite: 17]
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)[cite: 17]
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)[cite: 17]
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)[cite: 17]
	if #tg>0 then[cite: 17]
		local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)[cite: 17]
		if ct>0 then[cite: 17]
			local og=Duel.GetOperatedGroup()[cite: 17]
			if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then[cite: 17]
				local shuffled_count = og:GetCount()[cite: 17]
				local max_return = math.floor(shuffled_count / 3)[cite: 17]
				
				if max_return > 0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) [cite: 17]
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then[cite: 17]
					
					Duel.BreakEffect()[cite: 17]
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)[cite: 17]
					local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,max_return,nil)[cite: 17]
					if #rg>0 then[cite: 17]
						Duel.HintSelection(rg)[cite: 17]
						Duel.SendtoHand(rg,nil,REASON_EFFECT)[cite: 17]
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
	return c:IsControler(tp) and c:IsSetCard(0x115) and c:IsFaceup()[cite: 17]
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)[cite: 17]
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end[cite: 17]
	Duel.SetTargetPlayer(tp)[cite: 17]
	Duel.SetTargetParam(2)[cite: 17]
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)[cite: 17]
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- Sửa lại CHAININFO_TARGET_PARAM chính xác thay vì PARM
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)[cite: 17]
end