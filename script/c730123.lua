-- ============================================================
-- Card Name: Nightbloom - Missing Pieces of Memories
-- Passcode : 730123
-- Type     : Spell / Normal
-- Archetype: Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Always treated as a "Nightbloom" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xb24)
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

	-- Kích hoạt từ tay không cần Set CHỈ TRONG LƯỢT ĐỐI THỦ
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)

	-- Hiệu ứng kích hoạt chính
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.actcon)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
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

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
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
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)
	if chk==0 then
		if is_opp_turn then
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
				and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		else
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,e:GetHandler())
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		end
	end

	if is_opp_turn then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local hand=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #hand==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
		
		local rh=hand:RandomSelect(tp,1):GetFirst()
		if not rh or Duel.Remove(rh,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rh)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)

		local rd=Duel.GetDecktopGroup(1-tp,1)
		if #rd==0 or Duel.Remove(rd,POS_FACEUP,REASON_EFFECT)==0 then return end
		local rdc=rd:GetFirst()

		local same_type=false
		local lock_type=0
		if rh:IsType(TYPE_MONSTER) and rdc:IsType(TYPE_MONSTER) then
			same_type=true
			lock_type=TYPE_MONSTER
		elseif rh:IsType(TYPE_SPELL) and rdc:IsType(TYPE_SPELL) then
			same_type=true
			lock_type=TYPE_SPELL
		elseif rh:IsType(TYPE_TRAP) and rdc:IsType(TYPE_TRAP) then
			same_type=true
			lock_type=TYPE_TRAP
		end

		if same_type then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,1)
			e2:SetValue(function(e,re)
				return re:GetHandler():IsType(lock_type)
			end)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		local dg=Duel.GetDecktopGroup(tp,1)
		if #hg==0 or #dg==0 then return end

		local rg=Group.CreateGroup()
		rg:Merge(hg)
		rg:Merge(dg)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

		local is_normal_spell=false
		local is_quickplay=false
		local is_equip=false
		local is_field=false
		local is_continuous=false
		local has_spell=false

		for tc in aux.Next(rg) do
			if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_SPELL) then
				has_spell=true
				local stype=tc:GetType()
				-- Normal Spell: là Spell và không có cờ phụ nào khác
				if (stype & (TYPE_QUICKPLAY+TYPE_CONTINUOUS+TYPE_EQUIP+TYPE_FIELD+TYPE_RITUAL))==0 then
					is_normal_spell=true
				end
				if tc:IsType(TYPE_QUICKPLAY) then is_quickplay=true end
				if tc:IsType(TYPE_EQUIP) then is_equip=true end
				if tc:IsType(TYPE_FIELD) then is_field=true end
				if tc:IsType(TYPE_CONTINUOUS) then is_continuous=true end
			end
		end

		if not has_spell then return end
		Duel.BreakEffect()

		-- Normal Spell: Draw 2 cards
		if is_normal_spell and Duel.IsPlayerCanDraw(tp,2) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end

		-- Quick-Play Spell: Banish 1 card on the field
		if is_quickplay and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg,true)
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end

		-- Equip Spell: Take control of 1 monster until end of turn
		if is_equip and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=sg:GetFirst()
			if tc then
				Duel.GetControl(tc,tp,PHASE_END,1)
			end
		end

		-- Field Spell: Destroy all Spell/Trap Cards on the field
		if is_field then
			local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
			if #sg>0 then
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end

		-- Continuous Spell: Spell Card effects cannot be negated until end of turn
		if is_continuous then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_DISEFFECT)
			e1:SetValue(s.effectfilter)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:IsActiveType(TYPE_SPELL)
end
