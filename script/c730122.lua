--The Sanctuary of Flower - Bloom
local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as both "Flower Spirit" and "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Biến thành Quick-Play CHỈ TRONG LƯỢT ĐỐI THỦ
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_BECOME_QUICK)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.quickcon)
	c:RegisterEffect(e1)

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.quickcon)
	c:RegisterEffect(e2)

	-- Hiệu ứng kích hoạt chính
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

function s.quickcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xb24) and c:IsAbleToHand()
end

function s.exfilter(c,tp)
	if not (c:IsSetCard(0x702) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()) then return false end
	if c:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
		local lv=c:GetLevel()
		return lv>0 and Duel.IsPlayerCanDraw(tp,lv)
	elseif c:IsType(TYPE_XYZ+TYPE_LINK) then
		return true
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.IsPlayerCanDraw(tp,1)
				and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			if Duel.Draw(tp,1,REASON_EFFECT)>0 then
				local dc=Duel.GetOperatedGroup():GetFirst()
				Duel.ConfirmCards(1-tp,dc)
				if not dc:IsSetCard(0xb24) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					if #dg>0 then
						Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
				Duel.ShuffleHand(tp)
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.BreakEffect()
			if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO) then
				local lv=tc:GetLevel()
				local drawn=Duel.Draw(tp,lv,REASON_EFFECT)
				if drawn>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local tdg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,drawn,drawn,nil)
					if #tdg>0 then
						Duel.SendtoDeck(tdg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					end
				end
			elseif tc:IsType(TYPE_XYZ+TYPE_LINK) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_INACTIVATE)
				e1:SetValue(s.effectfilter)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)

				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetCode(EFFECT_CANNOT_DISEFFECT)
				e2:SetValue(s.effectfilter)
				e2:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end

function s.effectfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_SPELL) and (te:IsHasCategory(CATEGORY_TOHAND) or te:IsHasCategory(CATEGORY_SEARCH) or te:IsHasCategory(CATEGORY_DRAW))
end
