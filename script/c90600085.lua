-- Sky Striker Nemesis - Dominator
-- ID: 90600085
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Nguyên liệu Link: 1 "Æthel-Nemesis" or "Sky Striker" non-Link monster
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)

	-- Hiệu ứng: Khi được Special Summon -> Banish 1 Spell "Æthel-Nemesis" từ Deck hoặc GY; Add 1 card "Sky Striker" từ Deck lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- NGUYÊN LIỆU LINK
--------------------------------------------------------------------------------
function s.mfilter(c,lc,sumtype,tp)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS,lc,sumtype,tp) or c:IsSetCard(SET_SKY_STRIKER,lc,sumtype,tp))
		and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG: BANISH SPELL "ÆTHEL-NEMESIS" TỪ DECK/GY ĐỂ SEARCH CARD "SKY STRIKER"
--------------------------------------------------------------------------------
function s.rmcostfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end