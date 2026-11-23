-- Velvetect Oaths – Eclipse Fates
local s,id=GetID()
function s.initial_effect(c)
	-- Counter Trap: Negate activation, shuffle into Deck, attach this card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Material Effect: Opponent cannot activate monster effects during Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function() return Duel.IsBattlePhase() end)
	e2:SetValue(function(e,re,tp) return re:IsActiveType(TYPE_MONSTER) end)
	c:RegisterEffect(e2)

	-- Detach Effect: Add 1 Velvetect or Purrfect card from GY to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0x786,0x777}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsSetCard(0x786) or c:IsSetCard(0x777)) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	tc:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
		ec:CancelToGrave()
		if Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and ec:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			if not c:IsRelateToEffect(e) then return end
			local xyzg=Duel.GetMatchingGroup(function(card) return card:IsFaceup() and card:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,nil)
			if #xyzg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local tc=xyzg:Select(tp,1,1,nil):GetFirst()
				if tc and not tc:IsImmuneToEffect(e) then
					c:CancelToGrave()
					Duel.Overlay(tc,c)
				end
			end
		end
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end
function s.thfilter(c)
	return (c:IsSetCard(0x786) or c:IsSetCard(0x777)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
