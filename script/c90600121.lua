
--Crimson Herald - Sky Conduit
--ID: 18199611
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)

    --You can only Link Summon this card once per turn.
    c:SetSPSummonOnce(id)

    --① If this card is Link Summoned:
    --Add 1 Field Spell or Continuous Spell
    --that mentions "Slifer the Sky Dragon" or "Divine-Beast"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --② Quick Effect: Tribute this card;
    --immediately after this effect resolves,
    --Special Summon 1 Divine-Beast monster
    --from your hand, Deck or GY
    --(You can treat this as a Normal Summon).
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_names={10000020}
s.listed_series={SET_CRIMSON}

--Link Material:
--1 Level 4 or lower FIRE or Dragon monster
function s.matfilter(c,lc,sumtype,tp)
    return c:IsLevelBelow(4)
        and (c:IsAttribute(ATTRIBUTE_FIRE)
        or c:IsRace(RACE_DRAGON))
end

--Effect 1: Link Summon condition
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--Search filter:
--Field Spell or Continuous Spell
--that mentions Slifer or Divine-Beast
function s.thfilter(c)
    return (c:IsType(TYPE_FIELD) or c:IsType(TYPE_CONTINUOUS))
        and (
            c:ListsCode(10000020)
            or c:ListsCode(10000022)
            or c:ListsCode(90600112)
            or c:ListsCode(10000000)
        )
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(
        0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--Effect 2: Divine-Beast monster filter
function s.spfilter(c,e,tp)
    return c:IsRace(0x400)
        and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

--Tribute this card as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsReleasable()
    end
    Duel.Release(c,REASON_COST+REASON_RELEASE)
end

--Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
            and Duel.IsExistingMatchingCard(
                aux.NecroValleyFilter(s.spfilter),
                tp,
                LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
                0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

--Special Summon and treat as Normal/Advance Summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(
        tp,
        aux.NecroValleyFilter(s.spfilter),
        tp,
        LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,
        0,1,1,nil,e,tp)

    local tc=g:GetFirst()
    if tc then
        if Duel.SpecialSummon(
            tc,SUMMON_TYPE_ADVANCE,tp,tp,true,false,
            POS_FACEUP)~=0 then

            tc:CompleteProcedure()

            Duel.RaiseEvent(
                tc,EVENT_SUMMON_SUCCESS,e,
                REASON_EFFECT,tp,tp,Duel.GetCurrentChain())
        end
    end
end
