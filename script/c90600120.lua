
-- Thunderstorm Dominion
-- ID: 90600120

local s,id=GetID()
local SET_CRIMSON=0x1405

function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --Divine-Beast ATK Boost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,0x400))
    e2:SetValue(s.val)
    c:RegisterEffect(e2)

    --Divine-Beast DEF Boost
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    --Quick Effect: Negate and inflict damage
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

--------------------------------------------------
-- EFFECT 1: SELECT CARD
--------------------------------------------------

function s.filter(c,e,tp)
    return c:IsCode(10000020,10000022,90600112)
        and (
            not c:IsForbidden()
            or c:IsCanBeSpecialSummoned(e,0,tp,true,false)
        )
        and (
            not c:IsLocation(LOCATION_GRAVE)
            or not Duel.IsPlayerAffectedByEffect(tp,59822133)
        )
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local player=e:GetHandlerPlayer()

    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.filter,
            player,
            LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
            0,1,nil,e,player
        )
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local player=e:GetHandlerPlayer()

    if not e:GetHandler():IsRelateToEffect(e) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,player,HINTMSG_OPERATECARD)

    local g=Duel.SelectMatchingCard(
        player,
        s.filter,
        player,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
        0,1,1,nil,e,player
    )

    local tc=g:GetFirst()
    if not tc then return end

    --Check available actions
    local b1=not tc:IsForbidden()
        and Duel.GetLocationCount(player,LOCATION_SZONE)>0

    local b2=tc:IsCanBeSpecialSummoned(e,0,player,true,false)
        and Duel.GetLocationCount(player,LOCATION_MZONE)>0

    if not b1 and not b2 then return end

    local op=0

    if b1 and b2 then
        op=Duel.SelectOption(
            player,
            aux.Stringid(id,1),
            aux.Stringid(id,2)
        )
    elseif b1 then
        op=Duel.SelectOption(
            player,
            aux.Stringid(id,1)
        )
    else
        op=Duel.SelectOption(
            player,
            aux.Stringid(id,2)
        )
    end

    --Option 1: Place in Spell/Trap Zone
    if (b1 and op==0) then
        if Duel.MoveToField(
            tc,player,player,
            LOCATION_SZONE,POS_FACEUP,true
        ) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end

    --Option 2: Special Summon
    else
        if Duel.GetLocationCount(player,LOCATION_MZONE)>0 then
            if Duel.SpecialSummon(
                tc,0,player,player,true,false,POS_FACEUP
            )~=0 then
                tc:CompleteProcedure()
            end
        end
    end
end

--------------------------------------------------
-- DIVINE-BEAST BOOST
--------------------------------------------------

function s.val(e,c)
    local player=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(
        player,LOCATION_HAND,0
    )*500
end

--------------------------------------------------
-- EFFECT 2: NEGATE
--------------------------------------------------

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainDisablable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local player=e:GetHandlerPlayer()

    if chk==0 then
        return Duel.IsExistingMatchingCard(
            Card.IsAbleToGraveAsCost,
            player,LOCATION_HAND,0,1,nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,player,HINTMSG_TOGRAVE)

    local g=Duel.SelectMatchingCard(
        player,
        Card.IsAbleToGraveAsCost,
        player,
        LOCATION_HAND,0,1,1,nil
    )

    Duel.SendtoGrave(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    Duel.SetOperationInfo(
        0,CATEGORY_NEGATE,eg,1,0,0
    )

    Duel.SetOperationInfo(
        0,CATEGORY_DAMAGE,nil,0,1-tp,1000
    )
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev) then
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    end
end
