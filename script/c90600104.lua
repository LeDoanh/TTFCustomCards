-- Æthel-Nemesis Defrag System
-- ID: 90600104
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Kích hoạt Continuous Trap
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Hiệu ứng: Target tối đa 3 "Æthel-Nemesis" và/hoặc "Sky Striker" cards bị banish (tối thiểu 1 Spell); 
	-- xáo chúng vào Deck, sau đó rút 1 lá bài.
	-- Nếu bạn điều khiển quái thú "Æthel-Nemesis" Link, bạn có thể add 1 "Æthel Nemesis" card từ Deck thay vì rút bài.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- KIỂM TRA TARGET VÀ ĐIỀU KIỆN KÍCH HOẠT
--------------------------------------------------------------------------------
function s.tdfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsFaceup() and c:IsAbleToDeck()
end

function s.chkfilter(g)
	return g:IsExists(Card.IsSpell,1,nil)
end

function s.thfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsAbleToHand()
end

function s.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsType(TYPE_LINK)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,1,3,s.chkfilter,0)
	end
	
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.chkfilter,1,tp,HINTMSG_TODECK)
	Duel.SetTargetGroup(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	
	local has_link=Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,0,1,nil)
	if has_link then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

--------------------------------------------------------------------------------
-- KÍCH HOẠT VÀ XỬ LÝ
--------------------------------------------------------------------------------
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	
	if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if #og==0 then return end
		
		Duel.BreakEffect()
		local has_link=Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,0,1,nil)
		local can_search=has_link and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local can_draw=Duel.IsPlayerCanDraw(tp,1)
		
		if can_search and (not can_draw or Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1) then
			-- Add 1 "Æthel Nemesis" card từ Deck lên tay
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		elseif can_draw then
			-- Draw 1 card
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end