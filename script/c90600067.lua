-- Sky Striker Maneuver - Eclipse of Judgement
-- ID: 90600067
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Gửi 3 lá bài đầu Deck xuống GY; nếu có "Sky Striker Ace - Deus Ex Machina" trên sân -> Banish toàn bộ GY và gây sát thương (Banished x 200)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Banish lá này từ GY (trừ lượt bị gửi) trong Main Phase -> Target 1 lá "Sky Striker" đang bị banish; lấy lên tay
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_names={90600066} -- Sky Striker Nemesis - Deus Ex Machina
s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: ĐIỀU KIỆN, TARGET & OPERATE
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0 
		or Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsCode(90600061) or c:IsCode(90600003) or c:IsCode(90600024)) end,tp,LOCATION_FZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,90600066),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,3,REASON_EFFECT)>0 then
		-- Kiểm tra xem "Sky Striker Ace - Deus Ex Machina" (ID: 90600066) có trên sân hay không
		local has_deus = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,90600066),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		local g=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
		
		if has_deus and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			if ct>0 then
				Duel.Damage(1-tp,ct*200,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: THU HỒI BÀI BỊ BANISH TRONG MAIN PHASE
--------------------------------------------------------------------------------
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and Duel.IsMainPhase()
end

function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end