-- Sky Striker Maneuver - Sangen Burst
-- ID: 90600111
local s,id=GetID()
local SET_SKY_STRIKER = 0x115
local SET_SANGEN      = 0x14e
local SET_TENPAI      = 0x1d7

function s.initial_effect(c)
	-- Luôn luôn được tính là card "Sangen"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_SANGEN)
	c:RegisterEffect(e0)

	-- Kích hoạt 1 trong 2 hiệu ứng
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SKY_STRIKER,SET_SANGEN,SET_TENPAI}

--------------------------------------------------------------------------------
-- BỘ LỌC HIỆU ỨNG 1 & 2
--------------------------------------------------------------------------------
function s.thfilter1(c,tp)
	return (c:IsSetCard(SET_SKY_STRIKER) or c:IsSetCard(SET_TENPAI)) and c:IsMonster() and c:IsAbleToHand()
	       and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (c:IsCanBeNormalSummoned(e,0,tp,false,nil) or true)) -- Cho phép check thêm điều kiện Normal Summon nếu có 3+ Spell
end

function s.tgfilter2(c)
	return (c:IsSetCard(SET_TENPAI) or (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO))) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
end

--------------------------------------------------------------------------------
-- XỬ LÝ KÍCH HOẠT
--------------------------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- Hiệu ứng 1: Search monster rồi có thể Normal Summon
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			local tc=g:GetFirst()
			-- Nếu có 3 Spell trở lên trong GY, có thể Normal Summon quái vừa lấy hoặc 1 quái trên tay
			if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 
				and (tc:IsCanBeNormalSummoned(e,0,tp,true,nil) or Duel.IsExistingMatchingCard(Card.IsCanBeNormalSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,true,nil))
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local sg=Duel.SelectMatchingCard(tp,function(c,e,tp) return (c==tc or c:IsLocation(LOCATION_HAND)) and c:IsCanBeNormalSummoned(e,0,tp,true,nil) end,tp,LOCATION_HAND,0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.Summon(tp,sg:GetFirst(),true,nil)
				end
			end
		end
	else
		-- Hiệu ứng 2: Tăng ATK dựa trên số Spell trong GY và miễn dịch hiệu ứng kích hoạt của đối thủ
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local ct=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)
			if ct>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(ct*300)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			-- Miễn dịch hiệu ứng kích hoạt của đối thủ trong phần còn lại của lượt
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,4))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetValue(s.efilter)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end

function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and re:IsActivated() and re:GetOwner()~=e:GetHandler():GetOwner()
end