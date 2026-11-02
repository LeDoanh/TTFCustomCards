-- ============================================================
-- Card Name: Witch of Nightbloom
-- Passcode : 730125
-- Type     : Synchro / Pendulum / Effect Monster
-- Level 8 | Scale 1/1 | WATER | Spellcaster
-- ATK 3000 / DEF 2800
-- Archetype: Nightbloom (0xb24), Flower Spirit (0x702)
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Kích hoạt Pendulum
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()

	-- ============================================================
	-- Synchro Summon Procedure Tùy biến (Custom)
	-- Cho phép: 1 Tuner chuẩn HOẶC 1 Normal Monster (tính như Tuner) + 1+ Non-Tuner
	-- ============================================================
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1164)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.syncon)
	e0:SetTarget(s.syntg)
	e0:SetOperation(s.synop)
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e0)

	-- ============================================================
	-- Pendulum Effect
	-- ============================================================
	local ep=Effect.CreateEffect(c)
	ep:SetDescription(aux.Stringid(id,0))
	ep:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	ep:SetType(EFFECT_TYPE_IGNITION)
	ep:SetRange(LOCATION_PZONE)
	ep:SetProperty(EFFECT_FLAG_CARD_TARGET)
	ep:SetCountLimit(1,id)
	ep:SetTarget(s.pentg)
	ep:SetOperation(s.penop)
	c:RegisterEffect(ep)

	-- ============================================================
	-- Monster Effect 1: On Synchro Summon -> Send Archetype Spell to GY
	-- ============================================================
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	-- ============================================================
	-- Monster Effect 2: Quick Negate unless opponent sends Spell
	-- ============================================================
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Monster Effect 3: Destroyed by opponent -> Place into PZone
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,3})
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg2)
	e3:SetOperation(s.penop2)
	c:RegisterEffect(e3)
end

s.listed_series={0x702,0xb24}

-- ============================================================
-- Xử lý Synchro Custom: Normal Monster được tính như Tuner
-- ============================================================
function s.matfilter(c,sc)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial(sc) and c:GetSynchroLevel(sc)>0
end

function s.tunerfilter(c,sc,tp)
	return s.matfilter(c,sc) and (c:IsType(TYPE_TUNER) or (c:IsControler(tp) and c:IsType(TYPE_NORMAL)))
end

function s.nontunerfilter(c,sc)
	return s.matfilter(c,sc)
end

function s.syncon(e,c,tuner,mg)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,c)
	return g:IsExists(s.syncheck,1,nil,g,c,tp)
end

function s.syncheck(c,g,sc,tp)
	if not s.tunerfilter(c,sc,tp) then return false end
	local tg=g:Clone()
	tg:RemoveCard(c)
	local lv=8-c:GetSynchroLevel(sc)
	if lv<=0 then return false end
	return tg:CheckWithSumEqual(Card.GetSynchroLevel,lv,1,99,sc)
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk,c,tuner,mg)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local tc=g:FilterSelect(tp,s.syncheck,1,1,nil,g,c,tp):GetFirst()
	if tc then
		local tg=g:Clone()
		tg:RemoveCard(tc)
		local lv=8-tc:GetSynchroLevel(c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local mat=tg:SelectWithSumEqual(tp,Card.GetSynchroLevel,lv,1,99,c)
		mat:AddCard(tc)
		mat:KeepAlive()
		e:SetLabelObject(mat)
		return true
	end
	return false
end

function s.synop(e,tp,eg,ep,ev,re,r,rp,c,tuner,mg)
	local mat=e:GetLabelObject()
	c:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_SYNCHRO)
	mat:DeleteGroup()
end

-- ============================================================
-- Pendulum Effect Logic
-- ============================================================
function s.penfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.penfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.penfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.penfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thfilter(c,code)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and not c:IsCode(code) and c:IsAbleToHand()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil,tc:GetCode())
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- ============================================================
-- Monster Effect 1: On Synchro Summon
-- ============================================================
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spellfilter(c)
	return (c:IsSetCard(0x702) or c:IsSetCard(0xb24)) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- ============================================================
-- Monster Effect 2: Quick Negate
-- ============================================================
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.rmcostfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.oppspellfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.oppspellfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
			return
		end
	end
	Duel.NegateEffect(ev)
end

-- ============================================================
-- Monster Effect 3: Destroyed -> Place to PZone
-- ============================================================
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and (r&REASON_EFFECT+REASON_BATTLE)~=0 and rp==1-tp
end
function s.pentg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
