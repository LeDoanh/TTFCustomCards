-- Sky Striker Maneuver - Perspective Shift
-- ID: 90600074
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng kích hoạt: Special Summon 1 "Sky Striker" monster từ GY sang sân đối thủ, cướp 1 quái thú đối thủ, rồi (nếu >=3 Spells) phá hủy 1 card đối thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL+CATEGORY_DESTROY+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT: MAIN MONSTER ZONE CỦA BẠN TRỐNG
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0
end

--------------------------------------------------------------------------------
-- LOCATE & TARGET
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

--------------------------------------------------------------------------------
-- OPERATION
--------------------------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)>0 then
		-- Cướp quyền điều khiển 1 quái thú do đối thủ điều khiển
		local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.GetControl(sg,tp)
			end
		end
		
		-- Nếu có từ 3 lá Spell trở lên trong GY -> Tùy chọn phá hủy 1 card đối thủ điều khiển
		if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
			local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
			if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local des=dg:Select(tp,1,1,nil)
				if #des>0 then
					Duel.Destroy(des,REASON_EFFECT)
				end
			end
		end
	end

	-- Khóa Special Summon từ Extra Deck: Chỉ triệu hồi quái "Sky Striker" trong phần còn lại của lượt
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SKY_STRIKER)
end