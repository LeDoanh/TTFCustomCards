-- Descent of the Crimson Sky
-- ID: 90600117
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

s.listed_names={10000020, 10000022, 90600112}
s.listed_series={SET_CRIMSON}

function s.thfilter(c,e,tp)
	return (c:IsCode(10000020, 10000022, 90600112) or c:ListsCode(10000020) or c:ListsCode(10000022) or c:ListsCode(90600112) or c:IsSetCard(SET_CRIMSON)) 
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,tc)
			if (tc:IsLocation(LOCATION_HAND)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				if tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
					tc:CompleteProcedure()
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetRange(LOCATION_MZONE)
					e1:SetCountLimit(1)
					e1:SetOperation(s.thop)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e1)
				else
					Duel.NormalSummon(tp,tc,true,1)
				end
			end
		end
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsRace(0x400) end,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsRace(0x400) end,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end