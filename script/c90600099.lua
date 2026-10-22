-- Æthel Nemesis Patch - Emergency Reboot
-- ID: 90600099
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Kích hoạt Continuous Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Target 1 "Æthel Nemesis" card bị banish -> Shuffle vào Deck, sau đó draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu lá bài này bị banish bởi card effect -> Activate 1 "Æthel Nemesis" Field Spell trực tiếp từ Deck hoặc GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: SHUFFLE 1 BANISHED CARD VÀO DECK & DRAW 1
--------------------------------------------------------------------------------
function s.tdfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsFaceup() and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: KÍCH HOẠT FIELD SPELL TỪ DECK HOẶC GY KHI BỊ BANISH
--------------------------------------------------------------------------------
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)