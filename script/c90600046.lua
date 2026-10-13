-- Sky Striker Ace - Lycoris
-- ID: 90600046
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Khi Normal hoặc Special Summon -> Chọn 1 Phép "Sky Striker" trong Mộ và lấy về tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Ở trong Mộ -> Special Summon sang sân đối thủ ở thế Phòng thủ
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.effcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- RÀNG BUỘC CHUNG: Khóa Special Summon ngoài "Sky Striker" trong cả lượt
--------------------------------------------------------------------------------
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		or Duel.IsExistingMatchingCard(s.splimitfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- Khóa Extra Deck chỉ triệu hồi quái thú "Sky Striker" trong cả lượt
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

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: Lấy 1 Phép "Sky Striker" từ Mộ về tay
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: Special Summon sang sân đối thủ và gán các hiệu ứng bất lợi
--------------------------------------------------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- Không thể dùng làm nguyên liệu Fusion, Synchro, Xyz, Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		c:RegisterEffect(e2,true)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		c:RegisterEffect(e3,true)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		c:RegisterEffect(e4,true)

		-- Mỗi khi người điều khiển Normal/Special Summon quái thú từ tay hoặc Mộ -> Trừ 500 LP
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_SUMMON_SUCCESS)
		e5:SetRange(LOCATION_MZONE)
		e5:SetOperation(s.damop)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e5,true)
		local e6=e5:Clone()
		e6:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e6,true)
	end
end

function s.damfilter(c,tp)
	return c:IsControler(tp) and (c:IsPreviousLocation(LOCATION_HAND) or c:IsPreviousLocation(LOCATION_GRAVE))
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	if eg:IsExists(s.damfilter,1,nil,p) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SetLP(p, Duel.GetLP(p) - 500)
	end
end