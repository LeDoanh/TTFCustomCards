-- Gensokyo Eientei - Kaguya, Princess of Eientein
-- ID: 777700042
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc
local TOKEN_EIENTEI		= 777700038 -- Eientei Token

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}
s.listed_names={TOKEN_EIENTEI}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Liên kết: 3+ quái thú, bao gồm ít nhất 1 quái thú "Gensokyo Eientei"
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,5,s.lcheck)

	-- Hiệu ứng 1: Khi được Triệu hồi Liên kết -> Triệu hồi Đặc biệt 1 "Eientei Token" (Psychic/LIGHT/Level 1/ATK 0/DEF 0)
	-- (chỉ được dùng làm nguyên liệu Link cho quái thú "Gensokyo Eientei")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi lá bài này đang ở trạng thái Co-Linked, đối thủ không thể kích hoạt hiệu ứng quái thú trên tay
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.actcon)
	e2:SetValue(s.actlimit)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Khi 1 quái thú được Triệu hồi vào vùng mà lá bài này chỉ tới
	-- -> Chọn 1 quái thú "Gensokyo Eientei" trong Mộ; Triệu hồi Đặc biệt nó (vô hiệu hóa hiệu ứng),
	-- sau đó ngay lập tức Triệu hồi Liên kết 1 Link Monster dùng các quái thú bạn điều khiển làm nguyên liệu
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	local e3b=e3:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)

	local e3c=e3:Clone()
	e3c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3c)
end

--------------------------------------------------------------------------------
-- 1. BỘ LỌC NGUYÊN LIỆU LINK (PHẢI CÓ ÍT NHẤT 1 QUÁI "GENSOKYO EIENTEI")
--------------------------------------------------------------------------------
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GENSOKYO_EIENTEI,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRIỆU HỒI "EIENTEI TOKEN" KHI LINK SUMMON & KHÓA NGUYÊN LIỆU
--------------------------------------------------------------------------------
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

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
-- 3. LOGIC KHÓA KÍCH HOẠT HIỆU ỨNG QUÁI THÚ TRÊN TAY ĐỐI THỦ KHI CO-LINKED
--------------------------------------------------------------------------------
function s.actcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end

function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_HAND
end

--------------------------------------------------------------------------------
-- 4. LOGIC HỒI SINH TỪ MỘ KHI CÓ QUÁI TRIỆU HỒI VÀO LINK ARROW -> LINK SUMMON
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(function(c) return lg:IsContains(c) end,1,nil)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- Vô hiệu hóa hiệu ứng của quái vừa gọi
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		Duel.AdjustAll()
		-- Ngay sau đó, Triệu hồi Liên kết 1 Link Monster dùng quái bạn điều khiển
		local lnkg=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil)
		if #lnkg>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=lnkg:Select(tp,1,1,nil):GetFirst()
			Duel.LinkSummon(tp,sc,nil)
		end
	end
end