-- Æthel Nemesis World Ender - Ragnarok
-- ID: 90600090
local s,id=GetID()

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN TRIỆU HỒI (Khai báo trước để tránh lỗi nil)
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

--------------------------------------------------------------------------------
-- INITIAL EFFECT
--------------------------------------------------------------------------------
function s.initial_effect(c)
    -- Điều kiện Link Summon: 5+ quái thú, bao gồm 2 quái thú Link "Æthel-Nemesis" và/hoặc "Sky Striker"
    c:EnableReviveLimit()
    Link.AddProcedure(c, nil, 5, 99, s.lcheck)

    -- Must first be Link Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- Hiệu ứng liên tục: Unaffected by opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Hiệu ứng Quick Effect 1: Omni-Negate & Banish
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- Hiệu ứng Quick Effect 2 (Main Phase): Bắt cóc 1 quái thú từ Extra Deck của đối thủ
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.excon)
    e3:SetTarget(s.extg)
    e3:SetOperation(s.exop)
    c:RegisterEffect(e3)
end

-- Mã Archetype (0x115a: Æthel-Nemesis, 0x115: Sky Striker)
s.listed_series={0x115a, 0x115}

-- Kiểm tra nguyên liệu Link (Tối thiểu 2 quái Link thuộc archetype)
function s.lcheck(g,lc,sumtype,tp)
    return g:FilterCount(s.matfilter,nil,lc,sumtype,tp)>=2
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsType(TYPE_LINK,lc,sumtype,tp) and (c:IsSetCard(0x115a,lc,sumtype,tp) or c:IsSetCard(0x115,lc,sumtype,tp))
end

-- Immune Filter
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Filter & Xử lý Omni-Negate
function s.negcostfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainDisablable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GY,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GY,0,1,1,nil)
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

-- Filter & Xử lý Bắt cóc Extra Deck
function s.excon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone()
    if chk==0 then 
        return zone~=0 
            and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 
            and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_EXTRA)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local zone=c:GetLinkedZone()
    local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
    if #g>0 and zone~=0 then
        Duel.ConfirmCards(tp,g)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false,POS_FACEUP,tp,zone)
        local tc=sg:GetFirst()
        if tc then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
        end
        Duel.ShuffleExtra(1-tp)
    end
end