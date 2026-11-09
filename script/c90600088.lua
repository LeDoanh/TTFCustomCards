-- Æthel Nemesis Commander - Iron Throne
-- ID: 90600088
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A
local SET_SKY_STRIKER        = 0x115

function s.initial_effect(c)
    -- Điều kiện Link Summon: 3+ quái thú, bao gồm 1 "Æthel-Nemesis" hoặc "Sky Striker"
    c:EnableReviveLimit()
    Link.AddProcedure(c, nil, 3, 99, s.lcheck)

    -- Hiệu ứng liên tục: Tăng 300 ATK cho mỗi Spell đang bị banish
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Hiệu ứng Quick Effect 1: Negate monster effect của đối thủ
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

    -- Hiệu ứng Quick Effect 2: Link Summon trong Main Phase của cả 2 người chơi
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.lkcon)
    e3:SetCost(s.lkcost)
    e3:SetTarget(s.lktg)
    e3:SetOperation(s.lkop)
    c:RegisterEffect(e3)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- KIỂM TRA NGUYÊN LIỆU LINK BAN ĐẦU
--------------------------------------------------------------------------------
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SETCODE_AETHEL_NEMESIS,lc,sumtype,tp) or c:IsSetCard(SET_SKY_STRIKER,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG TĂNG ATK
--------------------------------------------------------------------------------
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsSpell,c:GetControler(),LOCATION_REMOVED,0,nil)*300
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: NEGATE MONSTER EFFECT
--------------------------------------------------------------------------------
function s.costfilter1(c)
    return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER)) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND+LOCATION_GY,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND+LOCATION_GY,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: LINK SUMMON TRONG MAIN PHASE CẢ 2 LƯỢT (COST: BANISH SPELL TỪ GY)
--------------------------------------------------------------------------------
-- Chỉ cần đang ở Main Phase của bất kỳ người chơi nào
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Chi phí: Banish 1 lá "Æthel-Nemesis" hoặc "Sky Striker" Spell từ Mộ (GY)
function s.lkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_GY,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_GY,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- Lọc quái thú Link "Æthel-Nemesis" có thể triệu hồi được bằng nguyên liệu trên sân
function s.lkfilter(c,mg)
    return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil,mg)
end

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetMatchingGroup(Card.IsCanBeLinkMaterial,tp,LOCATION_MZONE,0,nil)
        return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(Card.IsCanBeLinkMaterial,tp,LOCATION_MZONE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
    local tc=g:GetFirst()
    if tc then
        Duel.LinkSummon(tp,tc,nil,mg)
    end
end