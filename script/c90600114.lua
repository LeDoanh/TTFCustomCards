-- Crimson Oracle - Lightning Priestess
-- ID: 90600114
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
	-- (1) Draw 2 and discard 1 when sent to GY as material, Tribute, or cost for a Divine-Beast
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e1_tr=e1:Clone()
	e1_tr:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e1_tr)
	local e1_mat=e1:Clone()
	e1_mat:SetCode(EVENT_BE_MATERIAL)
	c:RegisterEffect(e1_mat)

	-- Register Tribute Summon flag for Tribute Summon of Divine-Beast (e.g. Slifer)
	local e1_reg=Effect.CreateEffect(c)
	e1_reg:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1_reg:SetCode(EVENT_RELEASE)
	e1_reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1_reg:SetCondition(s.regcon)
	e1_reg:SetOperation(s.regop)
	c:RegisterEffect(e1_reg)
	local e1_reg2=e1_reg:Clone()
	e1_reg2:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e1_reg2)

	-- Fallback for Tribute Summon of Divine-Beast monsters (which block effect activations on summon)
	local e1_god=Effect.CreateEffect(c)
	e1_god:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1_god:SetCode(EVENT_SUMMON_SUCCESS)
	e1_god:SetRange(LOCATION_GRAVE)
	e1_god:SetCondition(s.godcon)
	e1_god:SetOperation(s.godop)
	c:RegisterEffect(e1_god)

	-- (2) Banish from GY: shuffle 1 Divine-Beast/Dragon into Deck, add 1 Slifer S/T
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_names={10000020, 10000022, 90600112}
s.listed_series={SET_CRIMSON}

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) or Duel.GetFlagEffect(tp,id)>0 then return false end
	local rc=c:GetReasonCard()
	local is_divine = (rc and (rc:IsRace(RACE_DIVINE) or rc:IsCode(10000020,10000022,90600112)))
		or (re and re:GetHandler() and (re:GetHandler():IsRace(RACE_DIVINE) or re:GetHandler():IsCode(10000020,10000022,90600112)))
	local is_reason = c:IsReason(REASON_MATERIAL|REASON_RELEASE|REASON_COST)
		or (r&(REASON_MATERIAL|REASON_SUMMON|REASON_RELEASE|REASON_COST)~=0)
	return is_divine and is_reason
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and (c:IsReason(REASON_SUMMON|REASON_RELEASE|REASON_MATERIAL) or (r&(REASON_SUMMON|REASON_RELEASE|REASON_MATERIAL)~=0))
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.godcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsLocation(LOCATION_GRAVE) and c:GetFlagEffect(id)>0 and Duel.GetFlagEffect(tp,id)==0) then return false end
	local rc=c:GetReasonCard()
	local is_divine = (rc and (rc:IsRace(RACE_DIVINE) or rc:IsCode(10000020,10000022,90600112)))
		or eg:IsExists(function(tc) return tc:IsRace(RACE_DIVINE) or tc:IsCode(10000020,10000022,90600112) end,1,nil)
	return is_divine and Duel.IsPlayerCanDraw(tp,2)
end

function s.godop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(id)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		if Duel.Draw(tp,2,REASON_EFFECT)==2 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

function s.tdfilter(c)
	return c:IsMonster() and (c:IsRace(RACE_DIVINE) or c:IsRace(RACE_DRAGON)) and c:IsAbleToDeck()
end

function s.thfilter(c)
	return c:IsSpellTrap() and (c:ListsCode(10000020, 10000022, 90600112) or c:IsCode(10000020, 10000022, 90600112) or (c:IsSetCard(SET_CRIMSON) and c:ListsCode(10000020))) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
