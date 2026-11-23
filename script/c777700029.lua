-- Gensokyo Nether - Chen
-- ID: 777700029
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c
local CARD_HAKUGYOKUROU   = 777700030 -- Gensokyo Nether - Hakugyokurou 

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}
s.listed_names={CARD_HAKUGYOKUROU}

function s.initial_effect(c)
	-- Hiệu ứng 1: Có thể được coi là non-Tuner khi Triệu hồi Đồng bộ quái thú "Gensokyo Nether"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.ntval)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu điều khiển "Gensokyo Nether - Hakugyokurou" -> Triệu hồi Đặc biệt lá bài này từ tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Khi Normal hoặc Special Summon lúc bạn không điều khiển Field Spell
	-- -> Đặt 1 "Gensokyo Nether - Hakugyokurou" từ Deck ngửa mặt lên vùng Field Zone của bạn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.plcon)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)

	local e3b=e3:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)

	-- Hiệu ứng 4: Khi bị gửi xuống Mộ làm nguyên liệu Triệu hồi Đồng bộ
	-- -> Trục xuất 1 lá "Gensokyo Nether" từ Mộ, sau đó lấy 1 lá "Gensokyo Nether" khác tên từ Mộ hoặc vùng trục xuất lên tay
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC COI LÀ NON-TUNER CHO QUÁI SYNCHRO "GENSOKYO NETHER"
--------------------------------------------------------------------------------
function s.ntval(e,sc,tp)
	return sc and sc:IsSetCard(SET_GENSOKYO_NETHER)
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRIỆU HỒI TỪ TAY KHI CÓ "GENSOKYO NETHER - HAKUGYOKUROU"
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_HAKUGYOKUROU),tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC ĐẶT "GENSOKYO NETHER - HAKUGYOKUROU" TỪ DECK LÊN FIELD ZONE
--------------------------------------------------------------------------------
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,0)==0
end

function s.plfilter(c,tp)
	return c:IsCode(CARD_HAKUGYOKUROU) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC TRỤC XUẤT 1 LÁ Ở MỘ -> THU HỒI 1 LÁ KHÁC TÊN TỪ MỘ / TRỤC XUẤT
--------------------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_SYNCHRO)~=0 and c:IsLocation(LOCATION_GRAVE)
end

function s.thfilter(c,code)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and not c:IsCode(code)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsAbleToHand()
end

function s.rmfilter(c,tp)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c,c:GetCode())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and rg:GetFirst():IsLocation(LOCATION_REMOVED) then
		local code=rg:GetFirst():GetCode()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,code)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end