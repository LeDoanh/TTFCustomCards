-- Gensokyo Nether - Yuyuko Saigyouji
-- ID: 777700027
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c
local CARD_HAKUGYOKUROU   = 777700030 -- Gensokyo Nether - Hakugyokurou 

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}
s.listed_names={CARD_HAKUGYOKUROU}

function s.initial_effect(c)
	-- Hiệu ứng 1: Bỏ 1 lá trên tay -> Triệu hồi Đặc biệt lá bài này từ tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi Normal hoặc Special Summon -> Lấy 1 quái không phải Tuner "Gensokyo Nether" từ Deck lên tay
	-- (hoặc Triệu hồi Đặc biệt nó nếu bạn điều khiển "Gensokyo Nether - Hakugyokurou")
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	-- Hiệu ứng 3: Khi bị gửi xuống Mộ làm nguyên liệu Triệu hồi Đồng bộ -> Triệu hồi Đặc biệt lá này (trục xuất khi rời sân)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC BỎ 1 LÁ TRÊN TAY ĐỂ TRIỆU HỒI TỪ TAY
--------------------------------------------------------------------------------
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC SEARCH HOẶC TRIỆU HỒI NON-TUNER "GENSOKYO NETHER" TỪ DECK
--------------------------------------------------------------------------------
function s.haku_check(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_HAKUGYOKUROU),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.thfilter(c,e,tp,sp_ok)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
		and (c:IsAbleToHand() or (sp_ok and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sp_ok=s.haku_check(tp)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sp_ok)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sp_ok=s.haku_check(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_ok):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		function(sc) return sp_ok and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function(sc) Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,2)
	)
end

--------------------------------------------------------------------------------
-- 3. LOGIC HỒI SINH TỪ MỘ KHI LÀM NGUYÊN LIỆU SYNCHRO (TRỤC XUẤT KHI RỜI SÂN)
--------------------------------------------------------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_SYNCHRO)~=0 and c:IsLocation(LOCATION_GRAVE)
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