-- Sky Striker Special Maneuver - Signal Flare
-- ID: 90600057
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt lá bài Spell
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT: Sân mình không có quái thú nào ở Main Monster Zone
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

--------------------------------------------------------------------------------
-- LỌC MỤC TIÊU CƠ BẢN
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsLevel(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end

function s.basicfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsLevel(4)
end

function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()
end

--------------------------------------------------------------------------------
-- TARGET & OPERATION
--------------------------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Kiểm tra xem sân đối thủ có còn trống ít nhất 2 ô Main Monster Zone không
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2 then return false end
		-- Kiểm tra trong Deck hoặc GY có từ 2 quái Level 4 "Sky Striker" trở lên không
		return Duel.IsExistingMatchingCard(s.basicfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2 then return end
	
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,2,2,nil)
		if #sg==2 then
			for tc in aux.Next(sg) do
				if Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
					-- Vô hiệu hóa hiệu ứng của quái được gọi
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					tc:RegisterEffect(e2)

					-- Không thể dùng làm nguyên liệu Fusion, Synchro, Xyz, Link
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
					e3:SetValue(1)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
					local e4=e3:Clone()
					e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
					tc:RegisterEffect(e4)
					local e5=e3:Clone()
					e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
					tc:RegisterEffect(e5)
					local e6=e3:Clone()
					e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
					tc:RegisterEffect(e6)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end

	-- Khóa Special Summon ngoại trừ quái thú "Sky Striker" cho đến hết lượt
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Nếu có từ 3 Spell trở lên trong Mộ: Lấy 1 lá "Sky Striker" từ Mộ lên tay
	if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local thg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #thg>0 then
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,thg)
		end
	end
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsSetCard(SET_SKY_STRIKER)
end