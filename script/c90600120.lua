-- Thunderstorm Dominion
-- ID: 90600120
local s,id=GetID()
local SET_CRIMSON=0x1405

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DIVINE))
    e2:SetValue(s.val)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.negcon)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

s.listed_names={10000020,10000022,90600112}
s.listed_series={SET_CRIMSON}

-- Hàm lọc chỉ nhận tham số c cơ bản để tránh hoàn toàn lỗi lệch tham số Parameter 3
function s.filter(c,e,tp)
	return c:IsCode(10000020,10000022,90600112) 
		and (not c:IsForbidden() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
		and (not c:IsLocation(LOCATION_GRAVE) or not Duel.IsPlayerAffectedByEffect(tp,59822133))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) 
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	-- Sử dụng hàm ẩn đơn giản kiểm tra mã code trực tiếp, tránh truyền hàm rườm rà gây lỗi con trỏ
	local g=Duel.SelectMatchingCard(tp,function(c)
		return c:IsCode(10000020,10000022,90600112) 
			and (not c:IsForbidden() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
			and (not c:IsLocation(LOCATION_GRAVE) or not Duel.IsPlayerAffectedByEffect(tp,59822133))
	end,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local b1=not tc:IsForbidden() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		local b2=tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,1))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
		end
		if op==0 then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			tc:RegisterEffect(e1)
		else
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end

function s.val(e,c)
    local player=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(player,LOCATION_HAND,0)*500
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainDisablable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local player=e:GetHandlerPlayer()
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,player,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,player,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(player,Card.IsAbleToGraveAsCost,player,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev) then
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    end
end