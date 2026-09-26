-- ============================================================
-- Card Name: Ruined of the Ashened City
-- Passcode : 42100004
-- Type     : Trap / Continuous
-- Archetype: Ashened (0x1a5)
-- ============================================================
-- Effect 1: Can be activated the turn it was Set by "Veidos".
-- Effect 2: Treated as "Obsidim, the Ashened City" while face-up or in GY.
-- Effect 3: Special Summon 1 "Ashened" monster from hand during either turn.
-- Effect 4: "Ashened" monsters gain 200 ATK/DEF per Pyro monster, and cannot
--           be targeted, destroyed by card effects, or Tributed.
-- Effect 5: Send to GY if no "Ashened" or "Veidos" monster on field.
-- ============================================================

local s,id=GetID()
Duel.LoadScript("constants.lua")

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	c:RegisterEffect(e1)

	-- Can activate the turn it was set by Veidos
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)

	-- Treated as "Obsidim, the Ashened City" while face-up on field or in GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
	e2:SetValue(CARD_OBSIDIM_ASHENED_CITY)
	c:RegisterEffect(e2)

	-- Quick Special Summon 1 "Ashened" monster from hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	-- ATK/DEF boost for Ashened monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ASHENED))
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e4b=e4:Clone()
	e4b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4b)

	-- Cannot be targeted by card effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ASHENED))
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)

	-- Cannot be destroyed by card effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ASHENED))
	e6:SetValue(aux.indoval)
	c:RegisterEffect(e6)

	-- Cannot be Tributed
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_UNRELEASABLE_SUM)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ASHENED))
	e7:SetValue(1)
	c:RegisterEffect(e7)
	local e7b=e7:Clone()
	e7b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e7b)

	-- Send to GY if no Ashened or Veidos monster on the field
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetRange(LOCATION_SZONE)
	e8:SetOperation(s.sdop)
	c:RegisterEffect(e8)

	-- Check for cards Set by Veidos
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_SSET)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
end

s.listed_names={CARD_OBSIDIM_ASHENED_CITY,CARD_VEIDOS_ERUPTION_DRAGON}
s.listed_series={SET_ASHENED,SET_VEIDOS}

function s.actcon(e)
	return e:GetHandler():HasFlagEffect(id)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if not (rc and (rc:IsCode(CARD_VEIDOS_ERUPTION_DRAGON) or rc:IsOriginalCodeRule(CARD_VEIDOS_ERUPTION_DRAGON))) then return end
	for ec in eg:Iter() do
		ec:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ASHENED) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,0,
		LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,RACE_PYRO)*200
end

function s.sdfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_ASHENED) or c:IsSetCard(SET_VEIDOS) or c:IsCode(78783557,8540986))
end

function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.sdfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
