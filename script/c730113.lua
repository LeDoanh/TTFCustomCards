-- ============================================================
-- Card Name: Into The Nightbloom
-- Passcode : 730113
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

	-- Cho phép kích hoạt từ tay lên sân trong lượt đối thủ (Spell vẫn ra sân)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Effect kích hoạt chính (Đặt lên sân và giải quyết hiệu ứng)
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end

-- Điều kiện kích hoạt từ tay: Chỉ áp dụng khi là lượt của đối thủ
function s.handcon(e)
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
-- Phân nhánh Target & Chặn nháy Chain ở lượt mình
-- ============================================================
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	-- TRONG LƯỢT MÌNH: CHẶN TUYỆT ĐỐI KHÔNG CHO CHAIN
	-- Nếu đang có một Chain Link khác đang mở (Duel.GetCurrentChain() > 0), không cho phép kích hoạt
	if not is_opp_turn and Duel.GetCurrentChain()>0 then
		return false
	end

	if chk==0 then
		if is_opp_turn then
			return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		else
			local ph=Duel.GetCurrentPhase()
			return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
				and Duel.IsPlayerCanDraw(tp,1) 
				and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6
		end
	end

	if is_opp_turn then
		-- Khóa đối thủ không được chain vào
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

-- ============================================================
-- Thực thi hiệu ứng
-- ============================================================
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local is_opp_turn=(Duel.GetTurnPlayer()~=tp)

	if is_opp_turn then
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,#g,nil)
		local ct=#sg
		if ct>0 then
			local req_banish=ct*3
			local deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
			
			if deck_ct>=req_banish and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
				local rg=Duel.GetDecktopGroup(1-tp,req_banish)
				Duel.DisableShuffleCheck()
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
				return
			end
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	else
		local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		local possible_draw=math.floor(deck_count/6)
		if possible_draw<1 then return end
		if possible_draw>5 then possible_draw=5 end

		local t={}
		for i=1,possible_draw do t[i]=i end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
		local num=Duel.AnnounceNumber(tp,table.unpack(t))
		
		local drawn=Duel.Draw(tp,num,REASON_EFFECT)
		if drawn>0 then
			Duel.BreakEffect()
			local bcount=drawn*5
			local rg=Duel.GetDecktopGroup(tp,bcount)
			if #rg>0 then
				Duel.DisableShuffleCheck()
				Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end
