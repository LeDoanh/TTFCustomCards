-- Sky Striker Special Maneuver - Zero Hour
-- ID: 90600070
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng kích hoạt: Gửi 2 "Sky Striker" Spell khác tên từ Deck xuống GY -> Thêm hoặc Special Summon 1 quái "Sky Striker" từ Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Kích hoạt từ trên tay trong lượt đối thủ nếu đối thủ điều khiển quái thú và bạn không điều khiển lá bài nào
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT TỪ TAY TRONG LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT CHÍNH: Không có quái ở MMZ (hoặc có hiệu ứng Bypass)
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0 
		or Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsCode(90600061) or c:IsCode(90600003) or c:IsCode(90600024)) end,tp,LOCATION_FZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- TARGET & OPERATION
--------------------------------------------------------------------------------
function s.tgfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToGrave()
end

function s.monfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster()
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then
		return g:GetClassCount(Card.GetCode)>=2
			and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	
	-- Sử dụng aux.SelectUnselectGroup để đảm bảo chọn đúng 2 lá khác tên chuẩn YGOPro
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if sg and #sg==2 then
		if Duel.SendtoGrave(sg,REASON_EFFECT)>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local mg=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			local tc=mg:GetFirst()
			if tc then
				local b1=tc:IsAbleToHand()
				local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				local op=0
				if b1 and b2 then
					op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
				elseif b1 then
					op=0
				elseif b2 then
					op=1
				else
					return
				end

				if op==0 then
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,tc)
				else
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end