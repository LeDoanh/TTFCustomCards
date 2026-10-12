-- ============================================================
-- Card Name: The Flower Blooms Late
-- Passcode : <ID_CỦA_LÁ> (Thay bằng ID bạn chọn trong database)
-- Type     : Spell / Normal
-- Archetype: Flower Spirit (0x702), Nightbloom (0xb24)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Luôn được xem là cả "Flower Spirit" và "Nightbloom"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	local e0b=e0:Clone()
	e0b:SetValue(0xb24)
	c:RegisterEffect(e0b)

	-- Không thể Úp (Cannot be Set)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-- Cho phép kích hoạt từ tay lên sân trong lượt đối thủ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Hiệu ứng kích hoạt chính (Đặt lên sân và giải quyết hiệu ứng)
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.actcon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

-- Điều kiện kích hoạt từ tay: Chỉ áp dụng trong lượt đối thủ
function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

-- Điều kiện kích hoạt tổng thể:
-- Lượt mình: Bắt buộc Main Phase và Chain Link = 0 (Normal Spell chuẩn, không nháy chain)
-- Lượt đối thủ: Tự do
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()==tp then
		local ph=Duel.GetCurrentPhase()
		return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetCurrentChain()==0
	else
		return true
	end
end

-- Restrict: "You cannot activate cards from your Deck, except Spell Cards."
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
			-- Lượt đối thủ: GY và Banishment của cả 2 bên đều phải không có bài (0 lá)
			return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED)==0
		else
			return true
		end
	end

	if not is_opp_turn then
		-- Lượt mình: Cho chọn 1 trong 2 hiệu ứng
		local op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,0)},  -- Any card sent to GY is banished instead
			{true,aux.Stringid(id,1)}) -- Any card that would be banished is sent to GY instead
		e:SetLabel(op)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		-- Lượt đối thủ: Phủ nhận mọi effect kích hoạt tại GY hoặc Banishment đến hết Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+Duel.GetCurrentPhase())
		Duel.RegisterEffect(e1,tp)
	else
		-- Lượt mình: Áp dụng hiệu ứng đã chọn
		local op=e:GetLabel()
		if op==1 then
			-- "Any card sent to the GY is banished instead." (Macro Cosmos / Dimension Shifter)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetTargetRange(0xff,0xff)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		elseif op==2 then
			-- "Any card that would be banished is sent to the GY instead."
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

-- Xử lý Negate trong lượt đối thủ
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE or loc==LOCATION_REMOVED
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

-- Bộ lọc chuyển Banishment thành GY (Lựa chọn 2 ở lượt mình)
function s.rmtarget(e,c)
	return c:GetDestination()==LOCATION_REMOVED
end