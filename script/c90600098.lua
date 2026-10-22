-- Æthel Nemesis Archive - Defrag
-- ID: 90600098
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Hiệu ứng 1: Target 1 "Æthel Nemesis" monster trong Banish Zone -> Add vào tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu lá bài này bị banish bởi card effect -> Add 1 "Æthel-Nemesis" card từ Deck lên tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.srchcon)
	e2:SetTarget(s.srchtg)
	e2:SetOperation(s.srchop)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: ADD QUÁI TỪ BANISH ZONE VỀ TAY
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsMonster() and c:IsFaceup() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: SEARCH CARD TỪ DECK KHI BỊ BANISH BỞI CARD EFFECT
--------------------------------------------------------------------------------
function s.srchcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.srchfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsAbleToHand()
end

function s.srchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.srchfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.srchop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.srchfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end