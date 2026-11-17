-- Gensokyo Scarlet - Patchouli Knowledge
-- ID: 777700010
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Nếu lượt này bạn đã mất/trả LP để kích hoạt bài/hiệu ứng "Gensokyo Scarlet"
	-- -> Triệu hồi Đặc biệt từ tay/Mộ (trục xuất khi rời sân), sau đó có thể gửi 1 quái "Gensokyo Scarlet" từ Deck xuống Mộ + Khóa Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi làm nguyên liệu Dung hợp -> Triệu hồi Đặc biệt 1 quái "Gensokyo Scarlet" Cấp 6+ từ Mộ (trục xuất vào End Phase)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	-- Bộ đếm toàn cục theo dõi việc mất/trả LP để kích hoạt bài/hiệu ứng "Gensokyo Scarlet" trong lượt
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_DAMAGE)
		ge2:SetCondition(function(_,_,_,_,r) return (r&REASON_COST)~=0 end)
		Duel.RegisterEffect(ge2,0)
	end)
end

--------------------------------------------------------------------------------
-- THEO DÕI ĐIỀU KIỆN MẤT LP ĐỂ KÍCH HOẠT "GENSOKYO SCARLET" TRONG LƯỢT
--------------------------------------------------------------------------------
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ev>0 and re and re:GetHandler():IsSetCard(SET_GENSOKYO_SCARLET) then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
	end
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ TAY/MỘ + GỬI QUÁI TỪ DECK + KHÓA EXTRA DECK
--------------------------------------------------------------------------------
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end

function s.tgfilter(c)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Trục xuất lá bài này khi rời sân
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		-- Sau đó có thể gửi 1 quái thú "Gensokyo Scarlet" từ Deck xuống Mộ
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
	-- Cấm Triệu hồi Đặc biệt từ Extra Deck đến hết lượt, trừ quái Fusion và quái Synchro/Xyz/Link/Pendulum "Gensokyo"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.splimit(e,c)
	if not c:IsLocation(LOCATION_EXTRA) then return false end
	return not (c:IsType(TYPE_FUSION) or (c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM)))
end

--------------------------------------------------------------------------------
-- 2. LOGIC HỒI SINH QUÁI CẤP 6+ KHI LÀM NGUYÊN LIỆU DUNG HỢP
--------------------------------------------------------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_FUSION)~=0
end

function s.gyfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsLevelAbove(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Trục xuất quái thú đó trong End Phase
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
