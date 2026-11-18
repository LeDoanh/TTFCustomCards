-- Crimson Slifer, The Scarlet Sky Dragon
-- ID: 90600112
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)

	local e1_sp=Effect.CreateEffect(c)
	e1_sp:SetDescription(aux.Stringid(id,0))
	e1_sp:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1_sp:SetType(EFFECT_TYPE_IGNITION)
	e1_sp:SetRange(LOCATION_HAND)
	e1_sp:SetCost(s.hscost)
	e1_sp:SetTarget(s.hstg)
	e1_sp:SetOperation(s.hsop)
	c:RegisterEffect(e1_sp)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetTarget(s.atktg)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	local e5_clone=e5:Clone()
	e5_clone:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5_clone)

	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCountLimit(1,id)
	e6:SetCondition(s.lfcon)
	e6:SetTarget(s.lftg)
	e6:SetOperation(s.lfop)
	c:RegisterEffect(e6)
end

s.listed_series={SET_CRIMSON}
s.listed_names={10000020, 10000022, 90600112}

function s.costfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end

function s.hscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then return g:GetCount()>=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,3,3,e:GetHandler())
	Duel.SendtoGrave(sg,REASON_COST)
end

function s.hstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end

function s.hsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end

function s.atkval(e,c)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)*1000
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=6-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end

function s.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsFaceup()
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,tp) end
	local g=eg:Filter(s.cfilter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	for tc in aux.Next(g) do
		if tc:IsFaceup() then
			local pos=tc:GetPosition()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e2:SetValue(-2000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			
			if (pos & POS_ATTACK~=0 and tc:GetAttack()<=0) or (pos & POS_DEFENSE~=0 and tc:GetDefense()<=0) then
				Duel.Destroy(tc,REASON_EFFECT)
			end
		end
	end
end

function s.lfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and rp~=tp
end

function s.lffilter(c,e,tp)
	return c:IsLevelAbove(4) and (c:IsRace(RACE_DRAGON|0x400)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.lffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.lfop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lffilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,math.min(2,ft),nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end