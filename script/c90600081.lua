-- Æthel Nemesis Node - Tera
-- ID: 90600081
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Quy tắc triệu hồi Link: 1 non-Link "Æthel-Nemesis" or "Sky Striker" monster
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)

	-- Hiệu ứng 1: Khi được Special Summon -> Banish 1 Spell "Æthel-Nemesis" hoặc "Sky Striker" từ Deck; Add 1 Spell "Æthel-Nemesis" từ Deck lên tay
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

	-- Hiệu ứng 2: Trong Main Phase của bạn -> Banish lá bài này từ GY; Special Summon 1 quái thú "Æthel-Nemesis" hoặc "Sky Striker" bị banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
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
-- HIỆU ỨNG 1: BANISH SPELL TỪ DECK ĐỂ SEARCH SPELL "ÆTHEL-NEMESIS"
--------------------------------------------------------------------------------
function s.rmcostfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.thfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsSpell() and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_DECK,0,1,1,nil)
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

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: BANISH TỪ GY ĐỂ SPECIAL SUMMON QUÁI BỊ BANISH
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end