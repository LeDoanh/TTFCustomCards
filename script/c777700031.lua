-- Gensokyo Nether - Fallen Down
-- ID: 777700031
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}

function s.initial_effect(c)
	-- Hiệu ứng 1: Chọn 1 quái "Gensokyo Nether" bạn điều khiển -> Triệu hồi Đặc biệt lá này thành Normal Tuner Monster (Fairy/LIGHT/Level 2/ATK 0/DEF 0),
	-- và nếu đối thủ điều khiển quái thú, ngay sau đó Triệu hồi Đồng bộ 1 quái Đồng bộ "Gensokyo Nether" chỉ dùng lá này và mục tiêu làm nguyên liệu
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Dưới Mộ): Trục xuất lá này -> Triệu hồi Đặc biệt 1 quái "Gensokyo Nether" từ Mộ (vô hiệu hóa hiệu ứng & trục xuất khi rời sân)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI THÀNH NORMAL TUNER MONSTER & SYNCHRO SUMMON VỚI MỤC TIÊU
--------------------------------------------------------------------------------
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_NETHER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_GENSOKYO|SET_GENSOKYO_NETHER,TYPE_MONSTER+TYPE_NORMAL+TYPE_TUNER,0,0,2,RACE_FAIRY,ATTRIBUTE_LIGHT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.synfilter(c,mg)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsSynchroSummonable(nil,mg)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_GENSOKYO|SET_GENSOKYO_NETHER,TYPE_MONSTER+TYPE_NORMAL+TYPE_TUNER,0,0,2,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end

	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER,ATTRIBUTE_LIGHT,RACE_FAIRY,2,0,0)
	c:AddMonsterAttributeComplete()
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp)
			and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
			Duel.AdjustAll()
			local mg=Group.FromCards(c,tc)
			Synchro.CheckAdditional=function(tp,sg,sc) return #sg==2 and sg:IsContains(c) and sg:IsContains(tc) end
			local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,mg)
			if #syng>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=syng:Select(tp,1,1,nil):GetFirst()
				Duel.SynchroSummon(tp,sc,nil,mg)
			end
			Synchro.CheckAdditional=nil
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRIỆU HỒI TỪ MỘ (VÔ HIỆU HÓA HIỆU ỨNG & TRỤC XUẤT KHI RỜI SÂN)
--------------------------------------------------------------------------------
function s.gyfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
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
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3300)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end