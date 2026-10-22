-- Æthel Nemesis Executor - Glitch
-- ID: 90600091
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A
function s.initial_effect(c)
    -- Điều kiện Link Summon: 2+ monsters, bao gồm 1 "Æthel Nemesis" hoặc "Sky Striker" monster
    c:EnableReviveLimit()
    Link.AddProcedure(c, aux.FilterBoolFunctionEqual(Card.IsType, TYPE_MONSTER), 2, 99, s.lcheck)

    -- Must be Link Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.linklimit)
    c:RegisterEffect(e0)

    -- Hiệu ứng 1: Khi Special Summon -> Đối thủ không thể xích bài/hiệu ứng đối đầu với Trap "Æthel Nemesis" trong lượt này
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.inactop)
    c:RegisterEffect(e1)

    -- Hiệu ứng 2: Quick Effect trong Main Phase -> Banish 1 Spell từ hand/GY, nhìn hand đối thủ và banish 1 lá cho tới End Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.handcon)
    e2:SetCost(s.handcost)
    e2:SetTarget(s.handtg)
    e2:SetOperation(s.handop)
    c:RegisterEffect(e2)
end

-- Mã Archetype (0x115a: Æthel-Nemesis, 0x115: Sky Striker)
s.listed_series={0x115a, 0x115}

-- Kiểm tra nguyên liệu Link
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x115a,lc,sumtype,tp) or c:IsSetCard(0x115,lc,sumtype,tp)
end

-- Xử lý Hiệu ứng 1: Chống xích bài Bẫy
function s.inactop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.actlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.actlimit(e,re,tp)
    local ch=Duel.GetCurrentChain()
    if ch==0 then return false end
    local chain_e=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
    return chain_e and chain_e:GetHandler():IsSetCard(0x115a) and chain_e:IsActiveType(TYPE_TRAP)
end

-- Filter Cost & Xử lý Hiệu ứng 2: Banish lá bài trên tay
function s.handcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.costfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GY,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GY,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.handop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g>0 then
        Duel.ConfirmCards(tp,g)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetLabelObject(tc)
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end
        Duel.ShuffleHand(1-tp)
    end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc then
        Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
    end
end