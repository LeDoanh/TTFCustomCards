-- Crimson Herald - Sky Conduit
-- ID: 90600121
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)

	-- ① Nếu được Link Summon: Add bài từ Deck lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ② Quick Effect: Tribute card này (tính là 3 Tributes) để Normal Summon 1 Divine-Beast từ tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end

s.listed_names={10000020, 10000022, 90600112}
s.listed_series={SET_CRIMSON}

function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(4) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_DRAGON))
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
	return (c:IsCode(10000020, 10000022, 90600112) or c:ListsCode(10000020) or c:ListsCode(10000022) or c:ListsCode(90600112) or c:IsSetCard(SET_CRIMSON)) and c:IsAbleToHand()
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

-- Kiểm tra quái Divine-Beast trên tay có thể Normal Summon được khi dùng card này làm 3 Tributes
function s.sumfilter(c,tp)
	return c:IsRace(0x400) and c:IsSummonable(tp,true,nil,1,aux.Stringid(id,1))
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return c:IsReleasable() and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not c:IsReleasable() then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,function(tc,p) return tc:IsRace(0x400) and tc:IsSummonable(p,true,nil,1,aux.Stringid(id,1)) end,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- Thực hiện Release card này làm cost/vật tế và cấu hình ghi nhận đủ 3 tributes cho quái Divine-Beast
		if Duel.Release(c, REASON_COST+REASON_RELEASE) > 0 then
			Duel.Summon(tp, tc, true, nil, 3)
		end
	end
end