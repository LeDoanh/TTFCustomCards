import os
import sqlite3
import shutil
import re

SCRIPTS = {}

SCRIPTS[90600125] = """-- Ryzeal Arc-Reactor
-- ID: 90600125
local s,id=GetID()
local SET_RYZEAL=0x1b6

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)

	-- Add 1 Level 4 "Ryzeal" or 1 Ritual Monster from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Attach 1 "Ryzeal" card in your GY as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_RYZEAL}

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thfilter(c)
	return ((c:IsSetCard(SET_RYZEAL) and c:IsLevel(4)) or c:IsType(TYPE_RITUAL)) and c:IsMonster() and c:IsAbleToHand()
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

function s.attachfilter(c,xyzc,tp)
	return c:IsSetCard(SET_RYZEAL) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.attachfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		local is_monster=tc:IsMonster()
		Duel.Overlay(c,tc)
		if is_monster and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(400)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
"""

SCRIPTS[90600126] = """-- Maliss <M> Alice
-- ID: 90600126
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 1 "Maliss" monster, except "Maliss <M> Alice"
	Link.AddProcedure(c,s.matfilter,1,1)

	-- If Link Summoned: banish 1 "Maliss" monster from hand, Deck, or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)

	-- If banished: Pay 300 LP; take 1 "Maliss" Spell/Trap from Deck with different name from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.PayLP(300))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_MALISS,lc,sumtype,tp) and not c:IsCode(id)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.rmfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.stfilter(c,tp)
	return c:IsSetCard(SET_MALISS) and c:IsSpellTrap()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
		and (c:IsAbleToHand() or c:IsSSetable())
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	local b1=tc:IsAbleToHand()
	local b2=tc:IsSSetable()
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SSet(tp,tc)
	end
end
"""

SCRIPTS[90600127] = """-- Maliss <P> Cake-Bit
-- ID: 90600127
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- If a "Maliss" card is banished: Special Summon from hand or GY, then can banish 1 "Maliss" card from hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- If Special Summoned: Add 1 "Maliss" Spell/Trap from Deck to hand, and if you do, all "Maliss" Link Monsters gain 400 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.cfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsFaceup()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) and not (Duel.IsPhase(PHASE_DAMAGE) or Duel.IsPhase(PHASE_DAMAGE_CAL))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.rmfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemove()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

function s.thfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local bg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,0,nil)
		local count=bg:GetClassCount(Card.GetCode)
		local lg=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
		if count>0 and #lg>0 then
			for tc in aux.Next(lg) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(count*400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end
"""

SCRIPTS[90600128] = """-- Maliss <P> Forget-Me-Not
-- ID: 90600128
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Target 1 "Maliss" monster in GY: Special Summon self from hand, and if you do, banish that target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- If banished: Pay 300 LP; Special Summon this card, then can add 1 "Maliss" Spell/Trap from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.PayLP(300))
	e2:SetTarget(s.bansptg)
	e2:SetOperation(s.banspop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.tgfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsAbleToRemove()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
		-- Cannot Special Summon from Extra Deck for rest of turn, except Link Monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.bansptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.thfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.banspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			local sc=g:GetFirst()
			if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,sc)
				-- Cannot be activated this turn
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
			end
		end
	end
end
"""

SCRIPTS[90600129] = """-- Maliss <Q> Heartsbane
-- ID: 90600129
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 monsters, including a "Maliss" monster
	Link.AddProcedure(c,nil,2,2,s.lcheck)

	-- If Link Summoned: banish 1 "Maliss" card from Deck or GY; gain ATK or draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lscon)
	e1:SetTarget(s.lstg)
	e1:SetOperation(s.lsop)
	c:RegisterEffect(e1)

	-- During opponent's Main Phase (Quick Effect): target 1 opponent monster, banish 1 "Maliss" monster from hand/GY to bounce it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.bcon)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)

	-- If banished: Pay 600 LP; Special Summon self, then can banish 1 card from opponent's GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(Cost.PayLP(600))
	e3:SetTarget(s.bansptg)
	e3:SetOperation(s.banspop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_MALISS}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_MALISS,lc,sumtype,tp)
end

function s.lscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.rmfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemove()
end

function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		if tc:IsMonster() and c:IsRelateToEffect(e) and c:IsFaceup() then
			local atk=tc:GetBaseAttack()
			if atk>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		elseif tc:IsSpellTrap() and Duel.IsPlayerCanDraw(tp,1) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.bcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end

function s.bfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsAbleToRemove()
end

function s.oppfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end

function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.oppfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.bfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(s.oppfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.oppfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.bfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		if tc and tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

function s.bansptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

function s.banspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
"""

SCRIPTS[90600130] = """-- Maliss in Wonderland
-- ID: 90600130
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Activate: Banish 1 "Maliss" card from hand/Deck, add 1 "Maliss" monster with different name from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- During your Main Phase (Quick Effect): Banish self from GY, target 1 banished "Maliss" card; add to hand or SS if monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.rmfilter(c,tp)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end

function s.thfilter(c,code)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and not c:IsCode(code) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
end

function s.gyfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsSetCard(SET_MALISS)) then return false end
	local b1=c:IsAbleToHand()
	local b2=c:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	return b1 or b2
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.gyfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local b1=tc:IsAbleToHand()
	local b2=tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end
	local res=false
	if op==0 then
		res=Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
	else
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
	end
	if res then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
"""

SCRIPTS[90600131] = """-- Maliss in Tea Party
-- ID: 90600131
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Activate: Banish 1 "Maliss" monster from hand/GY; draw 2, then banish 1 from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- In GY during Main Phase except turn sent: Banish self, target 1 banished "Maliss" card to add to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.cfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

function s.gyfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsAbleToHand()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
"""

SCRIPTS[90600132] = """-- Maliss <C> ERR-404
-- ID: 90600132
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Hand activation: If opponent goes first, during Standby Phase of their first turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- Activate: Banish 1 "Maliss" card from hand/GY; Special Summon 1 "Maliss" monster from Deck/banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- In GY during Main Phase (Quick Effect): Link Summon 1 "Maliss" Link Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.linkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.linktg)
	e2:SetOperation(s.linkop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(1-tp) and Duel.GetTurnCount()==1 and Duel.IsStandbyPhase()
end

function s.cfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemoveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_LINK) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.lkfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsLinkSummonable(nil)
end

function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),nil)
	end
end
"""

SCRIPTS[90600133] = """-- Maliss <C> LOL-13
-- ID: 90600133
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Hand activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- Activate: Banish 1 "Maliss" card from GY; banish 1 card opponent controls face-down, then can SS 1 banished "Maliss"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- If banished: Target 1 face-up monster opponent controls; its ATK becomes 0, and if it does, can banish 1 "Maliss" from hand/Deck and draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK)
end

function s.malissfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS)
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	if Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil) then
		return true
	end
	if Duel.IsExistingMatchingCard(s.malissfilter,tp,LOCATION_MZONE,0,1,nil) then
		local te=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)
		if te and te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=tp then
			return true
		end
	end
	return false
end

function s.costfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemoveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.deckrmfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemove()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if tc:RegisterEffect(e1) and tc:GetAttack()==0 then
			if Duel.IsExistingMatchingCard(s.deckrmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
				and Duel.IsPlayerCanDraw(tp,1)
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local g=Duel.SelectMatchingCard(tp,s.deckrmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
				if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end
"""

SCRIPTS[90600134] = """-- Maliss <C> WRN-18
-- ID: 90600134
local s,id=GetID()
local SET_MALISS=0x1b9

function s.initial_effect(c)
	-- Hand activation: If opponent SS from Extra Deck, or activates S/T while you control Maliss Link
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- Activate: Banish 1 "Maliss" card from hand/GY; banish 1 Set card (or 1 card if control Link-3+ Maliss)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- If banished: Target 1 "Maliss" in GY; add to hand or SS to zone a Maliss Link points to
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_MALISS}

function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK)
end

function s.l3filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MALISS) and c:IsType(TYPE_LINK) and c:IsLinkAbove(3)
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	if not Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil) then
		return false
	end
	local te=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_EFFECT)
	local chk_st = te and te:IsSpellTrapEffect() and te:GetOwnerPlayer()~=tp
	local chk_sp = Duel.GetActivityCount(1-tp,ACTIVITY_SPSUMMON)>0
	return chk_st or chk_sp
end

function s.cfilter(c)
	return c:IsSetCard(SET_MALISS) and c:IsAbleToRemoveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_l3=Duel.IsExistingMatchingCard(s.l3filter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then
		if has_l3 then
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		else
			return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local has_l3=Duel.IsExistingMatchingCard(s.l3filter,tp,LOCATION_MZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=nil
	if has_l3 then
		g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	else
		g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g and #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.get_linked_zone(tp)
	local zone=0
	local lg=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
	for lc in aux.Next(lg) do
		zone=zone|lc:GetLinkedZone(tp)
	end
	return zone&0x1f
end

function s.gyfilter(c,e,tp)
	if not (c:IsSetCard(SET_MALISS)) then return false end
	local b1=c:IsAbleToHand()
	local zone=s.get_linked_zone(tp)
	local b2=c:IsMonster() and zone>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	return b1 or b2
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gyfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local b1=tc:IsAbleToHand()
	local zone=s.get_linked_zone(tp)
	local b2=tc:IsMonster() and zone>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
"""

# CDB Data Definitions
CARDS_DATA = [
    # (id, ot, alias, setcode, type, atk, def, level, race, attribute, category)
    (90600125, 32, 0, 0x1b6, 0x800021, 2400, 2000, 4, 0x80000, 0x4, 0),
    (90600126, 32, 0, 0x1b9, 0x4000021, 300, 2, 1, 0x1000000, 0x20, 0),
    (90600127, 32, 0, 0x1b9, 0x21, 600, 1200, 3, 0x1000000, 0x20, 0),
    (90600128, 32, 0, 0x1b9, 0x21, 1200, 600, 3, 0x1000000, 0x20, 0),
    (90600129, 32, 0, 0x1b9, 0x4000021, 1800, 5, 2, 0x1000000, 0x20, 0),
    (90600130, 32, 0, 0x1b9, 0x2, 0, 0, 0, 0, 0, 0),
    (90600131, 32, 0, 0x1b9, 0x10002, 0, 0, 0, 0, 0, 0),
    (90600132, 32, 0, 0x1b9, 0x4, 0, 0, 0, 0, 0, 0),
    (90600133, 32, 0, 0x1b9, 0x4, 0, 0, 0, 0, 0, 0),
    (90600134, 32, 0, 0x1b9, 0x4, 0, 0, 0, 0, 0, 0),
]

CARDS_TEXT = [
    (
        90600125,
        "Ryzeal Arc-Reactor",
        "2 Level 4 monsters\nIf this card is Xyz Summoned: You can detach 1 material from this card; add 1 Level 4 \"Ryzeal\" monster or 1 Ritual Monster from your Deck to your hand.\nDuring your Main Phase: You can target 1 \"Ryzeal\" card in your GY; attach it to this card as material, then if you attached a monster, this card gains 400 ATK.\nYou can only use each effect of \"Ryzeal Arc-Reactor\" once per turn.",
        "Add 1 Level 4 \"Ryzeal\" or 1 Ritual Monster from Deck to hand",
        "Attach 1 \"Ryzeal\" card in your GY as material",
        "", "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600126,
        "Maliss <M> Alice",
        "1 \"Maliss\" monster, except \"Maliss <M> Alice\"\nIf this card is Link Summoned: You can banish 1 \"Maliss\" monster from your hand, Deck, or GY.\nIf this card is banished: You can pay 300 LP; take 1 \"Maliss\" Spell/Trap from your Deck, with a different name from cards in your GY, and either add it to your hand or Set it.\nYou can only use each effect of \"Maliss <M> Alice\" once per turn.",
        "Banish 1 \"Maliss\" monster from your hand, Deck, or GY",
        "Take 1 \"Maliss\" Spell/Trap from Deck",
        "Add to hand",
        "Set to field",
        "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600127,
        "Maliss <P> Cake-Bit",
        "You can only use each effect of \"M∀LICE <P> Cake-Bit\" once per turn.\n① If a \"M∀LICE\" card(s) is banished (except during the Damage Step): You can Special Summon this card from your hand or GY, then you can banish 1 \"M∀LICE\" card from your hand or GY.\n② If this card is Special Summoned: You can add 1 \"M∀LICE\" Spell/Trap from your Deck to your hand, and if you do, all \"M∀LICE\" Link Monsters you currently control gain 400 ATK for each banished \"M∀LICE\" card with a different name until the end of this turn.",
        "Special Summon this card from hand or GY",
        "Add 1 \"M∀LICE\" Spell/Trap from Deck, and boost ATK",
        "Banish 1 \"M∀LICE\" card from hand or GY",
        "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600128,
        "Maliss <P> Forget-Me-Not",
        "You can target 1 \"Maliss\" monster in your GY; Special Summon this card from your hand, and if you do, banish that target, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Link Monsters.\nIf this card is banished: You can pay 300 LP; Special Summon this card, then you can add 1 \"Maliss\" Spell/Trap from your GY to your hand, also it cannot be activated this turn.\nYou can only use each effect of \"Maliss <P> Forget-me-not\" once per turn.",
        "Special Summon this card from hand, banish 1 \"Maliss\" from GY",
        "Special Summon this banished card",
        "Cannot Special Summon from Extra Deck, except Link Monsters",
        "Add 1 \"Maliss\" Spell/Trap from GY to hand",
        "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600129,
        "Maliss <Q> Heartsbane",
        "2 monsters, including a \"Maliss\" monster\nIf this card is Link Summoned: You can banish 1 \"Maliss\" card from your Deck or GY; for the rest of this turn, this card gains ATK equal to the banished card's original ATK (if it is a monster), or you can draw 1 card (if it is a Spell/Trap).\nDuring your opponent's Main Phase (Quick Effect): You can target 1 monster your opponent controls; banish 1 \"Maliss\" monster from your hand or GY, and if you do, return that opponent's monster to the hand.\nIf this card is banished: You can pay 600 LP; Special Summon this card, then you can banish 1 card from your opponent's GY.\nYou can only use each effect of \"M∀LICE <Q> Heartsbane\" once per turn.",
        "Banish 1 \"Maliss\" card from Deck or GY",
        "Banish 1 \"Maliss\" monster to return opponent's monster to hand",
        "Special Summon this banished card",
        "Banish 1 card from opponent's GY",
        "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600130,
        "Maliss in Wonderland",
        "You can only activate 1 \"M∀LICE in Wonderland\" per turn.\n① Banish 1 \"M∀LICE\" card from your hand or Deck, and if you do, add 1 \"M∀LICE\" monster with a different name from your Deck to your hand.\n② During your Main Phase (Quick Effect): You can banish this card from your GY, then target 1 of your banished \"M∀LICE\" cards; add it to your hand, or if it is a \"M∀LICE\" monster, you can Special Summon it instead, also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Link Monsters.",
        "Banish 1 \"M∀LICE\" card, add 1 with different name from Deck",
        "Banish this card from GY; add or Special Summon 1 banished card",
        "Add to hand",
        "Special Summon",
        "Cannot Special Summon from Extra Deck, except Link Monsters",
        "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600131,
        "Maliss in Tea Party",
        "You can only activate 1 \"M∀LICE in Tea Party\" per turn.\n① Banish 1 \"M∀LICE\" monster from your hand or GY, then draw 2 cards, and if you do, banish 1 card from your hand.\n② During your Main Phase, except the turn this card was sent to the GY: You can banish this card from your GY, then target 1 of your banished \"M∀LICE\" cards; add it to your hand.",
        "Draw 2 cards, then banish 1 card from hand",
        "Banish this card from GY; add 1 banished \"M∀LICE\" card to hand",
        "", "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600132,
        "Maliss <C> ERR-404",
        "You can only use each effect of \"M∀LICE <C> ERR-404\" once per turn.\n① If your opponent goes first, you can also activate this card from your hand during the Standby Phase of their first turn. Banish 1 \"M∀LICE\" card from your hand or GY; Special Summon 1 \"M∀LICE\" monster from your Deck or banishment, also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Link Monsters.\n② During the Main Phase (Quick Effect): You can banish this card from your GY; immediately after this effect resolves, Link Summon 1 \"M∀LICE\" Link Monster from your Extra Deck, using monsters you control as material.",
        "Special Summon 1 \"M∀LICE\" monster from Deck or banishment",
        "Link Summon 1 \"M∀LICE\" Link Monster",
        "Cannot Special Summon from Extra Deck, except Link Monsters",
        "", "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600133,
        "Maliss <C> LOL-13",
        "You can only use each effect of \"M∀LICE <C> LOL-13\" once per turn.\n① If you control a \"M∀LICE\" Link Monster, or if your opponent activates a monster effect while you control a \"M∀LICE\" monster: You can activate this card from your hand. Banish 1 \"M∀LICE\" card from your GY; banish 1 card your opponent controls face-down, then you can Special Summon 1 of your banished \"M∀LICE\" monsters.\n② If this card is banished: You can target 1 face-up monster your opponent controls; its ATK becomes 0 until the end of this turn, and if it does, you can banish 1 \"M∀LICE\" card from your hand or Deck, then draw 1 card.",
        "Banish 1 card opponent controls face-down, then can Special Summon",
        "Target 1 monster; make ATK 0, banish 1 card and draw 1",
        "Special Summon 1 of your banished \"M∀LICE\" monsters",
        "Banish 1 \"M∀LICE\" card and draw 1 card",
        "", "", "", "", "", "", "", "", "", "", "", ""
    ),
    (
        90600134,
        "Maliss <C> WRN-18",
        "You can only use each effect of \"M∀LICE <C> WRN-18\" once per turn.\n① If your opponent Special Summons a monster(s) from the Extra Deck, or activates a Spell/Trap Card or effect while you control a \"M∀LICE\" Link Monster: You can activate this card from your hand. Banish 1 \"M∀LICE\" card from your hand or GY; banish 1 Set card your opponent controls, or if you control a Link-3 or higher \"M∀LICE\" monster, you can banish 1 card your opponent controls instead.\n② If this card is banished: You can target 1 \"M∀LICE\" card in your GY; add it to your hand, or if it is a \"M∀LICE\" monster, you can Special Summon it to your zone a \"M∀LICE\" Link Monster points to instead.",
        "Banish 1 card your opponent controls",
        "Target 1 \"M∀LICE\" card in GY; add or Special Summon to linked zone",
        "Add to hand",
        "Special Summon to linked zone",
        "", "", "", "", "", "", "", "", "", "", "", ""
    ),
]

def main():
    # 1. Write scripts
    os.makedirs("script", exist_ok=True)
    os.makedirs("d:/AMEE/custom card/code card", exist_ok=True)

    with open("tools/edopro_constants.txt") as f:
        constants = set(l.strip() for l in f if l.strip())
    with open("tools/edopro_apis.txt") as f:
        apis = set(l.strip() for l in f if l.strip())

    for card_id, lua_code in SCRIPTS.items():
        # Validate
        clean = "\\n".join(l.split("--")[0] for l in lua_code.splitlines())
        words = set(re.findall(r"\\b([A-Z][A-Z0-9_]{2,})\\b", clean))
        missing_c = [w for w in sorted(words) if w not in constants and not w.startswith("SET_")]
        missing_a = sorted(set(m.group(1)+"."+m.group(2) for m in re.finditer(r"\\b(Duel|Effect|Card|Group|aux|Link|Xyz)\\.([\\w]+)\\b", clean) if m.group(1)+"."+m.group(2) not in apis))
        
        if missing_c:
            print(f"[{card_id}] Missing constants: {missing_c}")
        if missing_a:
            print(f"[{card_id}] Missing APIs: {missing_a}")

        path1 = f"script/c{card_id}.lua"
        path2 = f"d:/AMEE/custom card/code card/c{card_id}.lua"

        with open(path1, "w", encoding="utf-8") as f:
            f.write(lua_code.strip() + "\\n")
        with open(path2, "w", encoding="utf-8") as f:
            f.write(lua_code.strip() + "\\n")

    print(f"Successfully wrote and validated {len(SCRIPTS)} scripts.")

    # 2. Insert into CDB
    db = sqlite3.connect("cdb/Sky Striker.cdb")
    cur = db.cursor()

    for data in CARDS_DATA:
        cur.execute("INSERT OR REPLACE INTO datas VALUES (?,?,?,?,?,?,?,?,?,?,?)", data)

    for text in CARDS_TEXT:
        cur.execute("INSERT OR REPLACE INTO texts VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", text[:19])

    db.commit()
    db.close()
    print("Successfully updated cdb/Sky Striker.cdb!")

if __name__ == "__main__":
    main()
