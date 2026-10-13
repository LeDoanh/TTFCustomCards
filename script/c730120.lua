-- ============================================================
-- Card Name: The Flower Blooms Late
-- Passcode : 730120
-- Type     : Spell / Normal
-- Archetype: Flower Spirit (0x702), Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Effect 0: Luôn được xem là cả "Flower Spirit" và "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

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
			-- Cả 2 bên đều không có bài ở GY và Banishment
			local my_gy_rm=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE+LOCATION_REMOVED,0)
			local opp_gy_rm=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)
			return my_gy_rm==0 and opp_gy_rm==0
		else
			return true
		end
	end

	if not is_opp_turn then
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},
			{true,aux.Stringid(id,1)})
		e:SetLabel(op)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		-- Phủ nhận mọi effect kích hoạt tại GY hoặc Banishment đến hết Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+Duel.GetCurrentPhase())
		Duel.RegisterEffect(e1,tp)
	else
		local op=e:GetLabel()
		if op==1 then
			-- Mọi lá bài gửi xuống GY sẽ bị banish thay thế
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetTargetRange(0xff,0xff)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif op==2 then
			-- Mọi lá bài bị banish sẽ bị đưa xuống GY thay thế
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e2:SetTargetRange(0xff,0xff)
			e2:SetValue(LOCATION_GRAVE)
			e2:SetTarget(s.rmtarget)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE or loc==LOCATION_REMOVED
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.rmtarget(e,c)
	return c:GetDestination()==LOCATION_REMOVED
end
