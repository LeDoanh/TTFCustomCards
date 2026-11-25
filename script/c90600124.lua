-- Blue-eyes Cosmic Burst Dragon
-- ID: 90600124
local s,id=GetID()
local SET_BLUE_EYES=0xdd

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon: 1 "Blue-Eyes" monster + 1 LIGHT Tuner
	Synchro.AddProcedure(c,s.mfilter,1,1,Synchro.NonTuner(s.ntfilter),1,1)

	-- ① If Special Summoned: reveal Synchro Monster from Extra Deck or GY, copy name & effect & gain half original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)

	-- ② If sent to GY: shuffle 3 "Blue-Eyes" monsters from GY and/or banishment into Deck, destroy all opponent's cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

s.listed_names={89631139}
s.listed_series={SET_BLUE_EYES}

-- Tuner filter: 1 LIGHT Tuner
function s.mfilter(c,sc,stype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,sc,stype,tp) and c:IsType(TYPE_TUNER,sc,stype,tp)
end

-- Non-tuner filter: 1 "Blue-Eyes" monster
function s.ntfilter(c,sc,stype,tp)
	return c:IsSetCard(SET_BLUE_EYES,sc,stype,tp)
end

function s.bewdfilter(c)
	return c:IsFaceup() and c:IsCode(89631139)
end

function s.cpfilter(c,has_bewd)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	if has_bewd then return true end
	return c:IsRace(RACE_DRAGON)
end

function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_bewd=Duel.IsExistingMatchingCard(s.bewdfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,has_bewd)
	end
end

function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local has_bewd=Duel.IsExistingMatchingCard(s.bewdfilter,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,has_bewd)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	local code=tc:GetOriginalCode()
	local atk=math.floor(tc:GetBaseAttack()/2)
	-- "until end of your NEXT turn": survive opponent's turn then reset at end of your next turn
	local reset_flag=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN

	-- Copy name until end of your next turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	e1:SetReset(reset_flag,2)
	c:RegisterEffect(e1)

	-- Copy effects of that monster until end of your next turn
	c:CopyEffect(code,reset_flag,2)

	-- Gain half original ATK until end of your next turn
	if atk>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(reset_flag,2)
		c:RegisterEffect(e2)
	end
end

function s.tdfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsAbleToDeck()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end
	-- Use count-based SetOperationInfo (no specific group) to avoid nil param issues
	Duel.SetOperationInfo(0,CATEGORY_TODECK,0,3,0,0)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	if #g<3 then return end
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
