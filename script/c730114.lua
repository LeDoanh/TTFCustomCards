-- ============================================================
-- Card Name: Nightbloom - Moonlight Princess
-- Passcode : 730114
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================
-- Effect 0: Always treated as a "Flower Spirit" card.
-- Effect 1: Cannot be Set. You can activate this card from your
--           hand during your opponent's turn.
-- Effect 2: If this card is activated during your turn: Draw 1 card,
--           then apply 1 of these effects in sequence, based on the
--           type of the card drawn.
--           ● "Nightbloom": Draw 1 additional card.
--           ● "Flower Spirit": Add 1 card from your GY or banishment
--             to your hand.
--           ● Neither: Place 1 card from your hand on the bottom
--             of the Deck.
-- Effect 3: If this card is activated during your opponent's turn:
--           When a monster effect is activated: The activated effect
--           becomes "Both players draw 1 card, then discard 1 card."
-- Oath    : You can only activate 1 "Nightbloom - Moonlight Princess" per turn.
-- Restriction: You cannot use cards in your Deck, except Spell Cards.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- ============================================================
	-- Effect 0 — Always treated as a "Flower Spirit" card
	-- ============================================================
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	-- ============================================================
	-- Effect 1 — Cannot be Set
	-- ============================================================
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- ============================================================
	-- Effect 1b — Activate from hand during opponent's turn
	-- ============================================================
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_HAND)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	c:RegisterEffect(e3)

	-- ============================================================
	-- Effect 2 — Your turn: Normal Spell activation
	-- ============================================================
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.selfcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.selftg)
	e4:SetOperation(s.selfop)
	c:RegisterEffect(e4)

	-- ============================================================
	-- Effect 3 — Opponent's turn: Activation when monster effect is activated
	-- ============================================================
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.oppcon)
	e5:SetCost(s.cost)
	e5:SetTarget(s.opptg)
	e5:SetOperation(s.oppop)
	c:RegisterEffect(e5)
end

-- ============================================================
-- Deck Restriction: Lock Deck cards except Spell Cards
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
-- Effect 2: Your Turn Logic
-- ============================================================
function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.thfilter(c)
	return c:IsAbleToHand() and not c:IsCode(id)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)

	local is_nb=tc:IsSetCard(0xb24)
	local is_fs=tc:IsSetCard(0x702)

	Duel.BreakEffect()
	if is_nb and not is_fs then
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif is_fs and not is_nb then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	elseif is_nb and is_fs then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},
			{Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil),aux.Stringid(id,1)})
		if op==1 then
			Duel.Draw(tp,1,REASON_EFFECT)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	else
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
	Duel.ShuffleHand(tp)
end

-- ============================================================
-- Effect 3: Opponent's Turn Logic
-- ============================================================
function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local h1=Duel.Draw(0,1,REASON_EFFECT)
	local h2=Duel.Draw(1,1,REASON_EFFECT)
	if h1>0 or h2>0 then
		Duel.BreakEffect()
		if h1>0 then Duel.DiscardHand(0,nil,1,1,REASON_EFFECT+REASON_DISCARD) end
		if h2>0 then Duel.DiscardHand(1,nil,1,1,REASON_EFFECT+REASON_DISCARD) end
	end
end