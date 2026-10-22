-- Æthel Nemesis Dreadnought - Leviathan
-- ID: 90600082
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Quy tắc triệu hồi Link: 1 "Æthel-Nemesis" or "Sky Striker" non-Link monster
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)

	-- Hiệu ứng 1: Khi được Special Summon -> Banish 1 Spell "Æthel-Nemesis" từ Deck; Rút 1 lá
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect trong Main Phase của bạn): Banish lá này từ GY, target 1 Spell "Æthel-Nemesis" hoặc "Sky Striker" bị banish -> Úp lá đó lên sân
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
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
-- HIỆU ỨNG 1: BANISH SPELL TỪ DECK ĐỂ DRAW 1 LÁ
--------------------------------------------------------------------------------
function s.rmfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsSpell() and c:IsAbleToRemove()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: QUICK EFFECT BANISH TỪ GY ĐỂ ÚP SPELL BỊ BANISH LÊN SÂN
--------------------------------------------------------------------------------
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp)
end

function s.setfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsSpell() and c:IsFaceup() and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,tc)
	end
end