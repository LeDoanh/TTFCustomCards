-- Gensokyo Eientei - Kaguya Houraisan
-- ID: 777700040
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc
local TOKEN_EIENTEI		= 777700038 -- Eientei Token

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}
s.listed_names={TOKEN_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Nếu bạn điều khiển quái thú "Gensokyo Eientei", có thể Triệu hồi Đặc biệt lá bài này từ tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon1)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi Normal hoặc Special Summon -> Triệu hồi Đặc biệt 1 "Eientei Token" (Psychic/LIGHT/Level 1/ATK 0/DEF 0)
	-- (chỉ được dùng làm nguyên liệu Link cho quái thú "Gensokyo Eientei")
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	-- Hiệu ứng 3 (Dưới Mộ): Trục xuất 1 lá "Gensokyo Eientei" khác từ Mộ
	-- -> Triệu hồi Đặc biệt lá bài này, nhưng trục xuất nó khi rời sân
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ TAY KHI CÓ QUÁI THÚ "GENSOKYO EIENTEI"
--------------------------------------------------------------------------------
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GENSOKYO_EIENTEI),tp,LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRIỆU HỒI "EIENTEI TOKEN" & KHÓA NGUYÊN LIỆU LINK
--------------------------------------------------------------------------------
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EIENTEI,0,TYPES_TOKEN,0,0,1,RACE_PSYCHIC,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EIENTEI,0,TYPES_TOKEN,0,0,1,RACE_PSYCHIC,ATTRIBUTE_LIGHT) then return end
	local token=Duel.CreateToken(tp,TOKEN_EIENTEI)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- Chỉ được dùng làm nguyên liệu Link cho quái thú "Gensokyo Eientei"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(s.lnklimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetValue(1)
		token:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		token:RegisterEffect(e3,true)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_UNRELEASABLE_SUM)
		token:RegisterEffect(e4,true)
		local e5=e2:Clone()
		e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e5,true)
	end
	Duel.SpecialSummonComplete()
end

function s.lnklimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_GENSOKYO_EIENTEI)
end

--------------------------------------------------------------------------------
-- 3. LOGIC HỒI SINH TỪ MỘ BẰNG CÁCH TRỤC XUẤT 1 LÁ "GENSOKYO EIENTEI" KHÁC
--------------------------------------------------------------------------------
function s.rmfilter(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsAbleToRemoveAsCost()
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
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
	end
end