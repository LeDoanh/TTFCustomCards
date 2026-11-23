-- Gensokyo Scarlet - Flandre Scarlet
-- ID: 777700014
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Trả 400 LP, lộ 1 Fusion Monster "Gensokyo Scarlet" trong Extra Deck
	-- -> Gửi 1 quái bạn điều khiển xuống Mộ, Triệu hồi Đặc biệt lá này từ tay & nguyên liệu được chọn từ Mộ + Khóa Extra Deck + Bảo hộ Fusion Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

--------------------------------------------------------------------------------
-- 1. BỘ LỌC NGUYÊN LIỆU DUNG HỢP & MỤC TIÊU
--------------------------------------------------------------------------------
function s.is_listed_mat(c,fc)
	if not fc.material then return false end
	for _,code in ipairs(fc.material) do
		if type(code)=="number" and c:IsCode(code) then
			return true
		end
	end
	return false
end

function s.tgfilter1(c,tp)
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>=2
end

function s.tgfilter2(c,e,tp,fc)
	return s.is_listed_mat(c,fc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.revfilter(fc,e,tp)
	return fc:IsSetCard(SET_GENSOKYO_SCARLET) and fc:IsType(TYPE_FUSION) and not fc:IsPublic()
		and fc.material and Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,fc)
end

--------------------------------------------------------------------------------
-- 2. LOGIC COST, TARGET & XỬ LÝ TRIỆU HỒI + KHÓA EXTRA DECK + BẢO HỘ FUSION
--------------------------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then
		local c=e:GetHandler()
		return Duel.CheckLPCost(tp,400)
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.PayLPCost(tp,400)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local fc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,fc)
	e:SetLabelObject(fc)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local res=e:GetLabel()==100
		e:SetLabel(0)
		if res then return true end
		local c=e:GetHandler()
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	local fc=e:GetLabelObject()
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,s.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,fc)
	e:SetLabelObject(g1:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	g2:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc1=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	local tc2=(g-tc1):GetFirst()
	if tc1 and tc1:IsRelateToEffect(e) and Duel.SendtoGrave(tc1,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_GRAVE) then
		if c:IsRelateToEffect(e) and tc2 and tc2:IsRelateToEffect(e) and not tc2:IsHasEffect(EFFECT_NECRO_VALLEY)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc2:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			local sg=Group.FromCards(c,tc2)
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==2 then
				-- Việc Triệu hồi Dung hợp sử dụng cả lá này và quái thú vừa gọi làm nguyên liệu không thể bị vô hiệu hóa lượt này
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
				e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
				e1:SetTarget(s.limtg)
				e1:SetLabelObject({c,tc2})
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
	-- Cấm Triệu hồi Đặc biệt từ Extra Deck đến hết lượt, trừ quái Fusion và quái Synchro/Xyz/Link/Pendulum "Gensokyo"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.limtg(e,fc)
	local mats=e:GetLabelObject()
	if not (mats and fc:IsSummonType(SUMMON_TYPE_FUSION)) then return false end
	local mg=fc:GetMaterial()
	return mg and mg:IsContains(mats[1]) and mg:IsContains(mats[2])
end

function s.splimit(e,c)
	if not c:IsLocation(LOCATION_EXTRA) then return false end
	return not (c:IsType(TYPE_FUSION) or (c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM)))
end
