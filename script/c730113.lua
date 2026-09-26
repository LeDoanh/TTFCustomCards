--Into The Nightbloom
local s,id=GetID()

function s.initial_effect(c)
	--Luôn được coi là card "Flower Spirit"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x702)
	c:RegisterEffect(e0)

	--Không thể Úp (Set)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)

	-----------------------------------------------------------------------
	-- 1. KÍCH HOẠT TRONG LƯỢT CỦA MÌNH: Normal Spell thuần túy (Spell Speed 1)
	-----------------------------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.selfcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.selftg)
	e2:SetOperation(s.selfop)
	c:RegisterEffect(e2)

	-----------------------------------------------------------------------
	-- 2. KÍCH HOẠT TRONG LƯỢT ĐỐI THỦ: Quick Effect từ trên tay (Spell Speed 2)
	-----------------------------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.oppcon)
	e3:SetCost(s.oppcost)
	e3:SetTarget(s.opptg)
	e3:SetOperation(s.oppop)
	c:RegisterEffect(e3)
end

--Cost khóa Deck chung
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
	e2:SetTarget(function(e,tc)
		return tc:IsLocation(LOCATION_DECK)
	end)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(function(e,tc)
		return not tc:IsType(TYPE_SPELL)
	end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	Duel.RegisterEffect(e4,tp)

	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_HAND)
	Duel.RegisterEffect(e5,tp)
end

-----------------------------------------------------------------------
-- LOGIC LƯỢT CỦA MÌNH
-----------------------------------------------------------------------
function s.selfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.lock_deck(e:GetHandler(),tp)
end

function s.selftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.selfop(e,tp,eg,ep,ev,re,r,rp)
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

-----------------------------------------------------------------------
-- LOGIC LƯỢT ĐỐI THỦ (QUICK EFFECT TỪ TAY)
-----------------------------------------------------------------------
function s.oppcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end

function s.oppcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	--Gửi lá bài từ tay xuống Mộ như chi phí kích hoạt
	Duel.SendtoGrave(c,REASON_COST)
	s.lock_deck(c,tp)
end

function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	--Đối thủ không thể phản ứng lại hiệu ứng này
	Duel.SetChainLimit(function(e,ep,tp) return ep==tp end)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.oppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,#g,nil)
	local ct=#sg
	if ct>0 then
		local req_banish=ct*3
		local deck_ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
		
		--Đối thủ có quyền banish úp top Deck để triệt tiêu hiệu ứng
		if deck_ct>=req_banish and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
			local rg=Duel.GetDecktopGroup(1-tp,req_banish)
			Duel.DisableShuffleCheck()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
			return
		end
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end