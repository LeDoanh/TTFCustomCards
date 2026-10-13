-- Sky Striker Ace - Apex Predator
-- ID: 90600048
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Hiệu ứng Nhanh từ tay - Hiến tế tất cả quái thú ngửa mặt trên sân, Special Summon lá này và tạo 1 Token sang sân đối thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Đếm số lần Special Summon của đối thủ trong lượt
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end

	-- Hiệu ứng 2: Ở trong Main Monster Zone (Hiệu ứng Nhanh) - Hiến tế lá này để gọi 1 quái thú Link "Sky Striker Ace" từ Extra Deck vào Extra Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.lkcon)
	e2:SetCost(s.lkcost)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SKY_STRIKER}
s.listed_names={90600049} -- ID đại diện cho Token "Sky Striker Ace Token" (Machine/DARK/Level 11/ATK 3000/DEF 0)

--------------------------------------------------------------------------------
-- HÀM ĐẾM SỐ LẦN SPECIAL SUMMON CỦA ĐỐI THỦ
--------------------------------------------------------------------------------
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		local p=tc:GetSummonPlayer()
		Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: TRIBUTE TOÀN BỘ SÂN VÀ SPECIAL SUMMON
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetFlagEffect(1-tp,id)>=5
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		or Duel.IsExistingMatchingCard(s.splimitfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- Khóa Special Summon chỉ triệu hồi quái thú "Sky Striker" trong cả lượt
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimitfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SKY_STRIKER)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and g:IsExists(Card.IsReleasable,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,90600049,SET_SKY_STRIKER,TYPES_TOKEN,3000,0,11,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
				and Duel.IsPlayerCanSpecialSummonMonster(tp,90600049,SET_SKY_STRIKER,TYPES_TOKEN,3000,0,11,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then
				Duel.BreakEffect()
				local token=Duel.CreateToken(tp,90600049)
				Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: TRIBUTE Ở MAIN MONSTER ZONE ĐỂ GỌI SKY STRIKER LINK MONSTER
--------------------------------------------------------------------------------
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()<5
end

function s.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function s.lkfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsType(TYPE_LINK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false