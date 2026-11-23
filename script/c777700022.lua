-- Gensokyo Scarlet - Death of Time
-- ID: 777700022
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Trong lượt này, mỗi khi trả LP để kích hoạt hiệu ứng quái "Gensokyo Scarlet" thì hồi LP thay vì mất;
	-- Nếu LP > 8000: Chia đôi LP, sau đó Triệu hồi Đặc biệt tối đa quái "Gensokyo Scarlet" từ Mộ (không thể tấn công lượt này)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ): Trục xuất lá này & trả 2000 LP -> Trả 3 lá "Gensokyo Scarlet" khác tên từ Mộ/Trục xuất về Deck,
	-- sau đó Triệu hồi Đặc biệt 1 quái "Gensokyo Scarlet" từ Deck (trả về Deck vào End Phase)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-- Theo dõi hiệu ứng đang kích hoạt để chuyển đổi Cost trả LP thành Hồi LP chính xác
	aux.GlobalCheck(s,function()
		s.activating_eff=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_ACTIVATING)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re)
			s.activating_eff=re
		end)
		Duel.RegisterEffect(ge1,0)

		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetOperation(function()
			s.activating_eff=nil
		end)
		Duel.RegisterEffect(ge2,0)

		local orig_PayLPCost=Duel.PayLPCost
		Duel.PayLPCost=function(p,cost)
			local ce=s.activating_eff
			if Duel.GetFlagEffect(p,id)>0 and cost>0 and ce and ce:IsActiveType(TYPE_MONSTER) and s.is_scarlet_eff(ce) then
				Duel.Recover(p,cost,REASON_EFFECT)
				return
			end
			orig_PayLPCost(p,cost)
		end
	end)
end

function s.is_scarlet_eff(re)
	local rc=re:GetHandler()
	return rc and rc:IsSetCard(SET_GENSOKYO_SCARLET)
end

--------------------------------------------------------------------------------
-- 1. LOGIC CHUYỂN TRẢ LP THÀNH HỒI LP & CHIA ĐÔI LP ĐỂ HỒI SINH HÀNG LOẠT TỪ MỘ
--------------------------------------------------------------------------------
function s.spfilter_gy(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_LPCOST_CHANGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.costchange)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	if Duel.GetLP(tp)>8000 then
		Duel.SetLP(tp,(Duel.GetLP(tp)+1)//2)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 then
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter_gy),tp,LOCATION_GRAVE,0,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				local sg=g
				if #g>ft then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					sg=g:Select(tp,ft,ft,nil)
				end
				for tc in aux.Next(sg) do
					if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
						local e2=Effect.CreateEffect(c)
						e2:SetDescription(3206)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
						e2:SetCode(EFFECT_CANNOT_ATTACK)
						e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
						tc:RegisterEffect(e2)
					end
				end
				Duel.SpecialSummonComplete()
			end
		end
	end
end

function s.costchange(e,re,rp,val)
	if re and re:IsActiveType(TYPE_MONSTER) and s.is_scarlet_eff(re) then
		return 0
	end
	return val
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRẢ 3 LÁ KHÁC TÊN VỀ DECK & TRIỆU HỒI TỪ DECK (TRẢ VỀ VÀO END PHASE)
--------------------------------------------------------------------------------
function s.tdfilter(c)
	return c:IsSetCard(SET_GENSOKYO_SCARLET)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsAbleToDeck()
end

function s.spfilter_deck(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,c)
		return c:IsAbleToRemoveAsCost() and Duel.CheckLPCost(tp,2000)
			and g:GetClassCount(Card.GetCode)>=3
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter_deck,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.PayLPCost(tp,2000)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetClassCount(Card.GetCode)<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==3 then
		Duel.HintSelection(sg)
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tc=Duel.SelectMatchingCard(tp,s.spfilter_deck,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
				if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
					local fid=e:GetHandler():GetFieldID()
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetCountLimit(1)
					e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					e1:SetLabel(fid)
					e1:SetLabelObject(tc)
					e1:SetCondition(s.tdcon)
					e1:SetOperation(s.tdop)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
end

function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end