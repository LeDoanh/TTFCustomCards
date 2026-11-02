-- ============================================================
-- Card Name: Nightbloom – Dawn After the Long Night
-- Passcode : 730124
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Flower Spirit" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- Effect 1: Cannot be Set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Kích hoạt từ tay CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Effect 2: Your turn — Normal Spell activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- Effect 3: Opponent's turn — Negate targeting card/effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

-- ============================================================
-- Khóa Deck: Chỉ cho phép dùng Spell
-- ============================================================
function s.lock_deck(c,tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re)
		local loc=re:GetActivateLocation()
		return loc==LOCATION_DECK and not re:IsActiveType(TYPE_SPELL)
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,tc) return tc:IsLocation(LOCATION_DECK) end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,tc,p)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK) and tc:IsControler(e:GetHandlerPlayer()) and not tc:IsType(TYPE_SPELL)
	end)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

-- ============================================================
-- Lượt của bạn
-- ============================================================
function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
end

function s.gyfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end

function s.rmfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsFaceup() and c:IsAbleToHand()
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	if not tc1 or not g:IsContains(tc1) then return end
	local tc2=g:Filter(function(c,tc) return c~=tc end,nil,tc1):GetFirst()
	if not tc2 then return end

	-- Trả target 1 về đáy Deck
	if Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_DECK) then
		-- Và nếu làm được điều đó, add target 2 lên tay
		Duel.BreakEffect()
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc2)
	end
end

-- ============================================================
-- Lượt của đối thủ
-- ============================================================
function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp or rp~=1-tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	-- Đối thủ có thể banish 1 Spell trên tay để negate lá này
	local b_group=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_SPELL) and c:IsAbleToRemove() end,1-tp,LOCATION_HAND,0,nil)
	if #b_group>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=b_group:Select(1-tp,1,1,nil)
		if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
			return
		end
	end

	-- Nếu đối thủ không banish hoặc không thể, phủ nhận hiệu ứng đang kích hoạt
	Duel.NegateEffect(ev)
end