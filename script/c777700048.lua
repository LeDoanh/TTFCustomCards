-- Gensokyo Eientei - Moonlight Dancing
-- ID: 777700048
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Trục xuất 2 Link-5 "Gensokyo Eientei" từ Extra Deck -> Áp dụng 1 trong 2 hiệu ứng khóa trong lượt này
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_STANDBY_PHASE+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ - Trừ lượt lá này được gửi xuống Mộ, hoặc trong chính lượt kích hoạt Hiệu ứng 1 bị vô hiệu hóa):
	-- Gửi ngẫu nhiên 1 lá trên tay và lá trên cùng Deck xuống Mộ, sau đó trả 2 lá từ Mộ và/hoặc vùng trục xuất về Deck/Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-- Theo dõi toàn cục trường hợp kích hoạt Hiệu ứng 1 của lá bài này bị vô hiệu hóa trong lượt
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(s.negcheck)
		Duel.RegisterEffect(ge1,0)
	end)
end

function s.negcheck(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc and rc:IsOriginalCodeRule(id) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+RESET_PHASE+PHASE_END,0,1)
	end
end

--------------------------------------------------------------------------------
-- 1. LOGIC COST TRỤC XUẤT 2 LINK-5 TỪ EXTRA DECK & ÁP DỤNG 1 TRONG 2 HIỆU ỨNG KHÓA
--------------------------------------------------------------------------------
function s.costfilter(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_LINK) and c:GetLink()==5
		and c:IsAbleToRemoveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	e:SetLabel(op)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		-- Hiệu ứng dấu chấm 1: Đối thủ không thể kích hoạt lá bài từ tay,
		-- hoặc hiệu ứng của các quái thú đã được Triệu hồi Đặc biệt trong lượt này
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.aclimit1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	else
		-- Hiệu ứng dấu chấm 2: Bài trong Mộ và vùng trục xuất của đối thủ không thể bị di chuyển sang vị trí khác,
		-- đồng thời hiệu ứng của chúng không thể được kích hoạt trong lượt này
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.aclimit2)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		-- Ngăn di chuyển bài từ Mộ / vùng trục xuất đối thủ lên tay, Deck, Extra Deck, Mộ, vùng trục xuất hoặc Triệu hồi Đặc biệt
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_TO_HAND)
		e2:SetTargetRange(0,LOCATION_GRAVE+LOCATION_REMOVED)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)

		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_TO_DECK)
		Duel.RegisterEffect(e3,tp)

		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_REMOVE)
		e4:SetTargetRange(0,LOCATION_GRAVE)
		e4:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,tp)

		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_CANNOT_TO_GRAVE)
		e5:SetTargetRange(0,LOCATION_REMOVED)
		e5:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)

		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e6:SetTargetRange(1,1)
		e6:SetTarget(s.splimit)
		e6:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e6,tp)

		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_NECRO_VALLEY)
		e7:SetTargetRange(0,LOCATION_GRAVE)
		e7:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e7,tp)
	end
end

function s.aclimit1(e,re,tp)
	local rc=re:GetHandler()
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetActivateLocation()==LOCATION_HAND)
		or (re:IsActiveType(TYPE_MONSTER) and rc and rc:IsStatus(STATUS_SPSUMMON_TURN))
end

function s.aclimit2(e,re,tp)
	return (re:GetActivateLocation()&(LOCATION_GRAVE+LOCATION_REMOVED))~=0
end

function s.splimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer()) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end

--------------------------------------------------------------------------------
-- 2. LOGIC DƯỚI MỘ: GỬI NGẪU NHIÊN 1 LÁ TRÊN TAY & 1 LÁ ĐỈNH DECK -> TRẢ 2 LÁ VỀ DECK/EXTRA DECK
--------------------------------------------------------------------------------
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return aux.exccon(e) or c:HasFlagEffect(id)
end

function s.tdfilter(c)
	return c:IsAbleToDeck() or c:IsAbleToExtra()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsPlayerCanDiscardDeck(tp,1)
			and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 or not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):RandomSelect(tp,1)
	local dg=Duel.GetDecktopGroup(tp,1)
	hg:Merge(dg)
	Duel.DisableShuffleCheck()
	if Duel.SendtoGrave(hg,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if #og==2 then
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
			if #g>=2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local tg=g:Select(tp,2,2,nil)
				Duel.HintSelection(tg)
				Duel.BreakEffect()
				Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
