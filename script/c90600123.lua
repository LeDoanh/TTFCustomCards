-- Shooting Beyond Dragon
-- ID: 90600123
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon: 1+ Dragon Synchro Monsters + 1 Synchro Tuner
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTunerEx(s.mtfilter),1,99)

	-- Special Summon procedure by banishing Synchro Monsters from GY whose total Levels equal 12
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	-- Unaffected by opponent's activated effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	-- Quick Effect: target 1 Synchro Monster or Tuner in GY or banishment, shuffle into Deck, apply effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end

-- 1 Synchro Tuner
function s.tfilter(c,sc,stype,tp)
	return c:IsType(TYPE_TUNER,sc,stype,tp) and c:IsType(TYPE_SYNCHRO,sc,stype,tp)
end

-- 1+ Dragon Synchro Monsters
function s.mtfilter(c,sc,stype,tp)
	return c:IsRace(RACE_DRAGON,sc,stype,tp) and c:IsType(TYPE_SYNCHRO,sc,stype,tp)
end

function s.spmatfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:HasLevel() and c:GetLevel()>0 and c:IsAbleToRemoveAsCost()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.spmatfilter,tp,LOCATION_GRAVE,0,nil)
	return aux.SelectUnselectGroup(g,e,tp,1,99,s.spcheck,0)
end

function s.spcheck(sg,e,tp,mg)
	local sum=0
	for tc in aux.Next(sg) do
		sum=sum+tc:GetLevel()
	end
	return sum==12 and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spmatfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,99,s.spcheck,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end

function s.tkfilter(c)
	return (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_TUNER)) and c:IsAbleToDeck()
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tkfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.atkfilter(c,lv)
	return c:IsMonster() and c:HasLevel() and c:GetLevel()<=lv and c:GetBaseAttack()>0
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local is_synchro=tc:IsOriginalType(TYPE_SYNCHRO)
	local is_tuner=tc:IsOriginalType(TYPE_TUNER)
	local lv=tc:GetLevel()
	if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	if is_synchro then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.negcon)
		e1:SetOperation(s.negop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if is_tuner and c:IsRelateToEffect(e) and c:IsFaceup() and lv>0 then
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,lv)
		local atk=0
		for ac in aux.Next(g) do
			atk=atk+ac:GetBaseAttack()
		end
		if atk>0 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(atk)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and re:GetHandler()==tc and Duel.IsChainDisablable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end