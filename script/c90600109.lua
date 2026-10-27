-- Æthel Nemesis Deployment - Reinforcement
-- ID: 90600109
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A
local SET_SKY_STRIKER        = 0x115

function s.initial_effect(c)
	-- Hiệu ứng 1: Special Summon 1 quái thú "Æthel-Nemesis" Level 4 hoặc thấp hơn từ Deck, nhưng hiệu ứng của nó bị vô hiệu hóa
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Cho phép kích hoạt từ tay trong lượt đối thủ nếu điều khiển quái Æthel-Nemesis hoặc Sky Striker
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Khi bị banish -> Add 1 card "Æthel-Nemesis" hoặc "Sky Striker" từ Deck lên tay
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}
s.listed_names={id}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT TỪ TAY TRONG LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.handfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER)) and c:IsFaceup()
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: SPECIAL SUMMON LEVEL <= 4 TỪ DECK VỚI HIỆU ỨNG BỊ VÔ HIỆU
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- Vô hiệu hóa hiệu ứng của quái thú được gọi
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: KHI BỊ BANISH -> ADD CARD TỪ DECK LÊN TAY
--------------------------------------------------------------------------------
function s.thfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER)) 
		and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end