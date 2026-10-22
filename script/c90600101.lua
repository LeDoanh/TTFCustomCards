-- Æthel Nemesis Extraction - Data Mine
-- ID: 90600101
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Kích hoạt: Banish 1 monster từ Deck; add 1 "Æthel Nemesis" card từ Banish Zone (hoặc Deck nếu có >=3 Spells bị banish) về tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN VÀ KÍCH HOẠT
--------------------------------------------------------------------------------
function s.rmcostfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.thfilter_banish(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsFaceup() and c:IsAbleToHand()
end

function s.thfilter_deck(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsAbleToHand()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_spells=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3
	if chk==0 then
		if has_spells then
			return Duel.IsExistingMatchingCard(s.thfilter_deck,tp,LOCATION_DECK,0,1,nil)
				or Duel.IsExistingMatchingCard(s.thfilter_banish,tp,LOCATION_REMOVED,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.thfilter_banish,tp,LOCATION_REMOVED,0,1,nil)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED+LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local has_spells=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3
	local g_banish=Duel.GetMatchingGroup(s.thfilter_banish,tp,LOCATION_REMOVED,0,nil)
	local g_deck=Duel.GetMatchingGroup(s.thfilter_deck,tp,LOCATION_DECK,0,nil)
	
	local loc=0
	if has_spells and #g_deck>0 and #g_banish>0 then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		loc = (opt==0) and LOCATION_REMOVED or LOCATION_DECK
	elseif has_spells and #g_deck>0 then
		loc=LOCATION_DECK
	elseif #g_banish>0 then
		loc=LOCATION_REMOVED
	end

	if loc~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg = (loc==LOCATION_DECK) and g_deck:Select(tp,1,1,nil) or g_banish:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end