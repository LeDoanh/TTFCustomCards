-- Sky Striker Ace - Draconis
-- ID: 90600113
local s,id=GetID()
local SET_SKY_STRIKER = 0x115

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters, including a "Sky Striker" or Dragon monster
	Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(s.nontunerfilter), 1, 99)

	-- Cho phép dùng 1 "Sky Striker" Link Monster bạn điều khiển làm Tuner cấp 4 khi Synchro Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e0:SetValue(s.synval)
	c:RegisterEffect(e0)

	-- ① Hiệu ứng khi được Synchro Summon: Banish tùy ý Spell từ Mộ để phá hủy số lượng bài tương ứng của đối thủ và tăng ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.syncon)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)

	-- ② Quick Effect: Gửi 1 "Sky Striker" card từ tay hoặc sân ngửa xuống Mộ để vô hiệu hóa và banish úp mặt
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ③ Hiệu ứng khi bị phá hủy trong tầm kiểm soát của chủ nhân: Special Summon tối đa 2 quái Link "Sky Striker Ace" khác tên từ Mộ hoặc vùng banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN NGUYÊN LIỆU NON-TUNER & TÙY CHỈNH LINK LÀM TUNER
--------------------------------------------------------------------------------
function s.nontunerfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_SKY_STRIKER,scard,sumtype,tp) or c:IsRace(RACE_DRAGON,scard,sumtype,tp)
end

function s.synval(e,c,mg)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

--------------------------------------------------------------------------------
-- ① HIỆU ỨNG SYNCHRO SUMMON SUCCESS (BANISH SPELL PHÁ HỦY VÀ TĂNG ATK)
--------------------------------------------------------------------------------
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.rmfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	local og=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and #og>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	local og=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if #g==0 or #og==0 then return end
	local ct=math.min(#g,#og)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,ct,nil)
	local rct=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	if rct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=og:Select(tp,rct,rct,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			local dct=Duel.Destroy(dg,REASON_EFFECT)
			if dct>0 then
				local c=e:GetHandler()
				if c:IsRelateToEffect(e) and c:IsFaceup() then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(dct*500)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					c:RegisterEffect(e1)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- ② QUICK EFFECT: GỬI CARD XUỐNG MỘ ĐỂ VÔ HIỆU VÀ BANISH ÚP MẶT
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainDisablable(ev)
end

function s.costfilter(c,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) and c:IsAbleToGraveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,rc:GetPosition())
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		rc:SetLocation(re:GetActivateLocation())
		Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- ③ HIỆU ỨNG KHI BỊ PHÁ HỦY: GỌI TỐI ĐA 2 LINK "Sky Striker Ace" KHÁC TÊN
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)
		if ft<=0 then return false end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		return g:CheckSubGroup(aux.dncheck,1,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(2,ft),e,tp)
		if sg and #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end