-- Æthel Nemesis Dominator - Lockdown
-- ID: 90600093
local s,id=GetID()

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN TRIỆU HỒI (Định nghĩa trước để tránh lỗi nil)
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

--------------------------------------------------------------------------------
-- INITIAL EFFECT
--------------------------------------------------------------------------------
function s.initial_effect(c)
    -- Điều kiện Link Summon: 3+ quái thú "Æthel Nemesis"
    c:EnableReviveLimit()
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsSetCard, 0x115a), 3, 99)

    -- Must first be Link Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- Hiệu ứng Quick Effect 1: Negate card/effect của đối thủ & banish lá đó
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- Hiệu ứng Quick Effect 2 (Main Phase): Banish 1 lá từ hand/field/GRAVE, sau đó Link Summon 1 quái thú Link "Æthel Nemesis"
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.lkcon)
    e2:SetTarget(s.lktg)
    e2:SetOperation(s.lkop)
    c:RegisterEffect(e2)
end

-- Mã Archetype (0x115a: Æthel-Nemesis, 0x115: Sky Striker)
s.listed_series={0x115a, 0x115}

--------------------------------------------------------------------------------
-- FILTER & XỬ LÝ OMNI-NEGATE
--------------------------------------------------------------------------------
function s.negcostfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainDisablable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
        Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
    end
end

--------------------------------------------------------------------------------
-- FILTER & XỬ LÝ LINK SUMMON TRONG MAIN PHASE
--------------------------------------------------------------------------------
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.rmfilter(c)
    return c:IsAbleToRemove()
end
function s.lkfilter(c,mg)
    return c:IsSetCard(0x115a) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil,mg)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(Card.IsCanBeLinkMaterial,tp,LOCATION_MZONE,0,nil)
        return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        local mg=Duel.GetMatchingGroup(Card.IsCanBeLinkMaterial,tp,LOCATION_MZONE,0,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
        local tc=sg:GetFirst()
        if tc then
            Duel.LinkSummon(tp,tc,nil,mg)
        end
    end
end