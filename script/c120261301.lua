--The Weather Mist
--Embedded support: this card has no separate custom-library dependency.
if not TheWeatherCustom then
	TheWeatherCustom={}
	local H=TheWeatherCustom
	H.MIST=120261301
	H.MATERIAL_FLAG=120261310
	function H.Faceup(c) return c:IsFaceup() and c:IsSetCard(SET_THE_WEATHER) end
	function H.Monster(c) return c:IsMonster() and c:IsSetCard(SET_THE_WEATHER) end
	function H.SPFilter(c,e,tp)
		return H.Monster(c) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (not c:IsLocation(LOCATION_EXTRA) or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
	end
	function H.PlaceFilter(c,tp,except)
		return c:IsSetCard(SET_THE_WEATHER) and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS)
			and not c:IsForbidden() and not (except and c:IsCode(except)) and c:CheckUniqueOnField(tp)
	end
	function H.ColumnTarget(e,c)
		return c:IsType(TYPE_EFFECT) and c:IsSetCard(SET_THE_WEATHER) and c:GetSequence()<5
			and e:GetHandler():GetColumnGroup(1,1):IsContains(c)
	end
	function H.Grant(c,eff)
		local grant=Effect.CreateEffect(c)
		grant:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
		grant:SetRange(LOCATION_STZONE)
		grant:SetTargetRange(LOCATION_MZONE,0)
		grant:SetTarget(H.ColumnTarget)
		grant:SetLabelObject(eff)
		c:RegisterEffect(grant)
	end
	function H.Placed(e,tp,eg,ep,ev,re)
		local c=e:GetHandler()
		local moved=e:GetCode()==EVENT_MOVE and eg:IsContains(c) and not c:IsPreviousLocation(LOCATION_SZONE)
		local activated=e:GetCode()==EVENT_CHAIN_SOLVED and re and re:GetHandler()==c
			and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsRelateToEffect(re)
		if c:IsFaceup() and c:IsLocation(LOCATION_STZONE) and (moved or activated)
			and c:GetFlagEffect(c:GetOriginalCode()+20)==0 then
			c:RegisterFlagEffect(c:GetOriginalCode()+20,RESET_CHAIN,0,1)
			return true
		end
		return false
	end
	function H.AddPlacement(c,description,category,target,operation)
		local e=Effect.CreateEffect(c)
		e:SetDescription(description)
		e:SetCategory(category)
		e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
		e:SetProperty(EFFECT_FLAG_DELAY)
		e:SetRange(LOCATION_STZONE)
		e:SetCode(EVENT_MOVE)
		e:SetCondition(H.Placed)
		e:SetTarget(target)
		e:SetOperation(operation)
		c:RegisterEffect(e)
		local ec=e:Clone() ec:SetCode(EVENT_CHAIN_SOLVED) c:RegisterEffect(ec)
	end
	function H.PlaceOne(e,tp,locations,except)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.PlaceFilter),tp,locations,0,1,1,nil,tp,except):GetFirst()
		return tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	function H.AddReturn(c,id,description,draw)
		local record=Effect.CreateEffect(c)
		record:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
		record:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		record:SetCode(EVENT_REMOVE)
		record:SetOperation(function(e,tp,eg,ep,ev,re)
			local c=e:GetHandler()
			if re and c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_ONFIELD)
				and re:GetHandler():IsSetCard(SET_THE_WEATHER) and c:IsFaceup() then
				e:SetLabel(Duel.GetTurnCount()+1)
				c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,2)
			end
		end)
		c:RegisterEffect(record)
		local ret=Effect.CreateEffect(c)
		ret:SetDescription(description)
		ret:SetCategory(CATEGORY_SPECIAL_SUMMON|(draw and CATEGORY_DRAW or 0))
		ret:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
		ret:SetRange(LOCATION_REMOVED)
		ret:SetCode(EVENT_PHASE|PHASE_STANDBY)
		ret:SetCountLimit(1)
		ret:SetCondition(function(e) return record:GetLabel()==Duel.GetTurnCount() and c:GetFlagEffect(id)>0 end)
		ret:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
			c:ResetFlagEffect(id)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_REMOVED)
			if draw then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
		end)
		ret:SetOperation(function(e,tp)
			if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and draw then
				Duel.BreakEffect() Duel.Draw(tp,1,REASON_EFFECT)
			end
		end)
		c:RegisterEffect(ret)
	end
	--The official Canvas scripts call aux.bfgcost. Add this narrowly scoped route
	--so Mist can replace that cost without shipping modified official scripts.
	local original_bfgcost=aux.bfgcost
	function H.BanishCost(e,tp,eg,ep,ev,re,r,rp,chk,replace_ok)
		local c=e:GetHandler()
		local eligible=c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(SET_THE_WEATHER)
		local function replacement(tc)
			local pe=tc:IsHasEffect(EFFECT_COST_REPLACE)
			return tc:IsCode(H.MIST) and tc:IsFaceup() and tc:IsAbleToRemoveAsCost() and pe and pe:CheckCountLimit(tp)
		end
		local has=eligible and replace_ok~=false and Duel.IsExistingMatchingCard(replacement,tp,LOCATION_PZONE,0,1,nil)
		local base=original_bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then return base or has end
		if has and (not base or Duel.SelectYesNo(tp,aux.Stringid(H.MIST,0))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local pc=Duel.SelectMatchingCard(tp,replacement,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
			local pe=pc:IsHasEffect(EFFECT_COST_REPLACE)
			pe:UseCountLimit(tp)
			Duel.Remove(pc,POS_FACEUP,REASON_COST|REASON_REPLACE)
			if Duel.IsExistingMatchingCard(function(tc) return tc:IsSetCard(SET_THE_WEATHER) and tc:IsAbleToHand() end,tp,LOCATION_DECK,0,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(H.MIST,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,function(tc) return tc:IsSetCard(SET_THE_WEATHER) and tc:IsAbleToHand() end,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g)
			end
			return
		end
		return original_bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	end
	aux.bfgcost=H.BanishCost
	--Extra Link materials follow The Weather Forecast's official implementation.
	function H.RegisterMaterials(c,range,allow,global)
		local extra=Effect.CreateEffect(c)
		extra:SetType(EFFECT_TYPE_FIELD)
		extra:SetCode(EFFECT_EXTRA_MATERIAL)
		extra:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
		if range then extra:SetRange(range) end
		extra:SetTargetRange(1,0)
		extra:SetOperation(aux.TRUE)
		extra:SetValue(function(chk,stype,e,...)
			local tp=e:GetHandlerPlayer()
			if chk==0 then
				local player,sc=...
				if stype~=SUMMON_TYPE_LINK or not sc or not allow(sc) then return Group.CreateGroup() end
				Duel.RegisterFlagEffect(player,H.MATERIAL_FLAG,0,0,1)
				return Duel.GetMatchingGroup(H.Faceup,player,LOCATION_STZONE,0,nil)
			elseif chk==2 then Duel.ResetFlagEffect(tp,H.MATERIAL_FLAG) end
		end)
		local typ=Effect.CreateEffect(c)
		typ:SetType(EFFECT_TYPE_FIELD)
		typ:SetCode(EFFECT_ADD_TYPE)
		typ:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
		if range then typ:SetRange(range) end
		typ:SetTargetRange(LOCATION_STZONE,0)
		typ:SetCondition(function(e) return Duel.GetFlagEffect(e:GetHandlerPlayer(),H.MATERIAL_FLAG)>0 end)
		typ:SetTarget(function(e,tc) return H.Faceup(tc) end)
		typ:SetValue(TYPE_MONSTER)
		if global then Duel.RegisterEffect(extra,global) Duel.RegisterEffect(typ,global)
		else c:RegisterEffect(extra) c:RegisterEffect(typ) end
		return extra,typ
	end
	function H.WithMaterials(c,tp,fn)
		local ex,typ=H.RegisterMaterials(c,nil,aux.TRUE,tp)
		local result=fn()
		ex:Reset() typ:Reset() Duel.ResetFlagEffect(tp,H.MATERIAL_FLAG)
		return result
	end
end
--End embedded support.
local H=TheWeatherCustom
local s,id=GetID()
s.listed_series={SET_THE_WEATHER}
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	local pend=Effect.CreateEffect(c)
	pend:SetType(EFFECT_TYPE_SINGLE)
	pend:SetCode(EFFECT_COST_REPLACE)
	pend:SetRange(LOCATION_PZONE)
	pend:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	pend:SetCountLimit(1)
	c:RegisterEffect(pend)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg) e1:SetOperation(s.thop) c:RegisterEffect(e1)
	local e1b=e1:Clone() e1b:SetCode(EVENT_SPSUMMON_SUCCESS) c:RegisterEffect(e1b)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE) e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg) e2:SetOperation(s.spop) c:RegisterEffect(e2)
	H.AddReturn(c,id,aux.Stringid(id,3),false)
end
function s.thfilter(c) return c:IsSetCard(SET_THE_WEATHER) and c:IsSpellTrap() and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.CheckPendulumZones(tp))
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(H.SPFilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.SPFilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not mc or Duel.SpecialSummon(mc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and Duel.CheckPendulumZones(tp) then
		Duel.BreakEffect() Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
