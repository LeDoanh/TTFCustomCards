-- Bujintei Hayate
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon: 2+ Level 4 "Bujin" monsters
	c:EnableReviveLimit()
	local maxc = (Xyz and (Xyz.InfiniteMats or Xyz.infiniteMats)) or 99
	if Xyz and Xyz.AddProcedure then
		Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x88),4,2,nil,nil,maxc)
	else
		aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x88),4,2,nil,nil,maxc)
	end
	
	-- Effect 1: If Special Summoned: Send "Bujin" cards from Deck to GY equal to opp cards + 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	
	-- Effect 2: Quick Effect: Banish 1 Beast/Winged Beast Bujin from hand/Deck and detach 1 material; copy its effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END+TIMING_BATTLE_START)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	
	-- Effect 3: During the End Phase: Return 1 banished "Bujin" card to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.rttg)
	e3:SetOperation(s.rtop)
	c:RegisterEffect(e3)
end
s.listed_series={0x88}
s.listed_names={id}

-- Effect 1
function s.tgfilter(c)
	return c:IsSetCard(0x88) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+1
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,ct,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,ct,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+1
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g>=ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:Select(tp,ct,ct,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

-- Effect 2
function s.bfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
		and (c:IsRace(RACE_BEAST) or c:IsRace(RACE_WINGEDBEAST))
		and c:IsAbleToRemoveAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_COST)>0 then
		e:SetLabel(tc:GetOriginalCode())
	end
end

function s.bwfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
function s.bujinmonsterfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
end
function s.bujinfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x88)
end
function s.boarfilter(c)
	return c:IsFaceup() and c:IsAttackPos()
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ)
end
function s.stfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local code=e:GetLabel()
	if code==48739166 then -- Quilin
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif code==95503694 then -- Centipede
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif code==59251766 then -- Hare
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.bwfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif code==32339440 then -- Boar
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)
		local g=Duel.SelectTarget(tp,s.boarfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	elseif code==22702055 then -- Ophidian
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.bujinmonsterfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif code==65169794 then -- Swallow
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.bwfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif code==68601507 then -- Crane
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.bwfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif code==02120090 then -- Ibis
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.bujinmonsterfilter,tp,LOCATION_MZONE,0,1,1,nil)
	elseif code==98642187 then -- Peacock
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	elseif code==75142039 then -- Kirin (custom)
		e:SetProperty(0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif code==75142041 then -- Phoenix (custom)
		e:SetProperty(0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif code==75142040 then -- Tortoise (custom)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetProperty(0)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	
	if code==48739166 then -- Quilin: destroy 1 face-up card opponent controls
		if tc and tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif code==95503694 then -- Centipede: destroy 1 S/T opponent controls
		if tc and tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif code==59251766 then -- Hare: target 1 Bujin Beast-Warrior, indestructible once
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCountLimit(1)
			e1:SetValue(function(e,re,r,rp) return (r&REASON_BATTLE+REASON_EFFECT)~=0 end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif code==32339440 then -- Boar: change to DEF and 0 DEF
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	elseif code==22702055 then -- Ophidian: 1 Bujin can attack directly
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif code==65169794 then -- Swallow: 1 Bujin Beast-Warrior can attack twice
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif code==68601507 then -- Crane: double original ATK
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local atk=tc:GetBaseAttack()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(atk*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif code==02120090 then -- Ibis: piercing
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PIERCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	elseif code==98642187 then -- Peacock: search Bujin monster, then send 1 from hand to GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.bujinmonsterfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	elseif code==02540753 then -- Fox: take no damage this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	elseif code==75214390 then -- Susa: no battle damage, opp takes damage
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif code==16188701 then -- Turtle: negate activation targeting Bujin
		if ev and ev>0 then
			local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
			if tg and tg:IsExists(s.bujinfilter,1,nil,tp) and Duel.IsChainNegatable(ev) then
				Duel.NegateActivation(ev)
			end
		end
	elseif code==75142039 then -- Kirin (custom): Protect or Special Summon from Deck
		local opt=0
		local b1=true
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.bujinmonsterfilter,tp,LOCATION_DECK,0,1,nil)
		if b1 and b2 then
			opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		elseif b2 then
			opt=1
		end
		if opt==0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsSetCard(0x88) end)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			Duel.RegisterEffect(e2,tp)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.bujinmonsterfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif code==75142041 then -- Phoenix (custom): Search or Attach
		local opt=0
		local b1=Duel.IsExistingMatchingCard(s.bwfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.bujinmonsterfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		if b1 and b2 then
			opt=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
		elseif b2 then
			opt=1
		end
		if opt==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.bwfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,g)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if xyz then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.bujinmonsterfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
				if #g>0 then
					Duel.Overlay(xyz,g)
				end
			end
		end
	elseif code==75142040 then -- Tortoise (custom): search Bujin Spell/Trap
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- Effect 3
function s.rtfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.rtfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
