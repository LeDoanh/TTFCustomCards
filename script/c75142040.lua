-- Bujin Tortoise
local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: Special Summon procedure from hand or GY if you control a "Bujin" monster
	c:SetSPSummonOnce(id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	
	-- Effect 2: If Normal or Special Summoned: Add 1 "Bujin" Spell/Trap from Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	
	-- Effect 3: An Xyz Monster whose original Type is Beast-Warrior and has this card as Xyz Material gains this effect:
	-- While there are 3 or more banished "Bujin" card, this card is unaffected by your opponent's activated monster's effect.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(s.immcon)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
end
s.listed_series={0x88}
s.listed_names={id}

-- Effect 1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Effect 2
function s.thfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
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

-- Effect 3
function s.immcon(e)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and Duel.GetMatchingGroupCount(s.banfilter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)>=3
end
function s.banfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88)
end
function s.immval(e,te)
	if not te:IsActivated() then return false end
	local trig_p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)
	local is_monster=te:IsMonsterEffect()
	if not is_monster then
		local _,trig_typ=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_TYPE)
		is_monster=trig_typ and (trig_typ&TYPE_MONSTER~=0)
	end
	return is_monster and (trig_p==1-e:GetHandlerPlayer() or te:GetOwnerPlayer()==1-e:GetHandlerPlayer())
end
