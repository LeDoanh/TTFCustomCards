-- Gensokyo Nether - Youmu Konpaku
-- ID: 777700028
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c
local CARD_HAKUGYOKUROU   = 777700030 -- Gensokyo Nether - Hakugyokurou 

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}
s.listed_names={CARD_HAKUGYOKUROU}

function s.initial_effect(c)
	-- Hiệu ứng 1: Khi Normal hoặc Special Summon -> Lấy 1 quái Tuner "Gensokyo Nether" từ Deck lên tay
	-- (hoặc Triệu hồi Đặc biệt từ Deck nếu bạn điều khiển "Gensokyo Nether - Hakugyokurou")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)

	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- Hiệu ứng 2: Khi bị gửi xuống Mộ làm nguyên liệu Triệu hồi Đồng bộ
	-- -> Lấy 1 Spell/Trap "Gensokyo Nether" từ Deck lên tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC SEARCH HOẶC TRIỆU HỒI TUNER "GENSOKYO NETHER" TỪ DECK
--------------------------------------------------------------------------------
function s.haku_check(tp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_HAKUGYOKUROU),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.thfilter1(c,e,tp,sp_ok)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsType(TYPE_TUNER)
		and (c:IsAbleToHand() or (sp_ok and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sp_ok=s.haku_check(tp)
		return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,sp_ok)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local sp_ok=s.haku_check(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,sp_ok):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,
		function(sc) return sp_ok and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function(sc) Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,1)
	)
end

--------------------------------------------------------------------------------
-- 2. LOGIC SEARCH SPELL/TRAP "GENSOKYO NETHER" KHI LÀM NGUYÊN LIỆU SYNCHRO
--------------------------------------------------------------------------------
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_SYNCHRO)~=0 and c:IsLocation(LOCATION_GRAVE)
end

function s.thfilter2(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end