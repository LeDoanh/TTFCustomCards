-- Sky Striker Special Maneuver - Paradox Gate!
-- ID: 90600037
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.lkcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.lktg)
    e2:SetOperation(s.lkop)
    c:RegisterEffect(e2)
end

-- Cho phép nhận diện cả bài trong Mộ và bài bị loại bỏ (hỗ trợ cả bài Face-down banished)
function s.tdfilter(c)
    return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)) and c:IsAbleToDeck()
end

function s.thfilter1(c)
    return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,99,nil)
    if #g>0 then
        local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        if ct>0 then
            local return_count = math.floor(ct/4)
            if return_count>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
                local rg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,return_count,nil)
                if #rg>0 then
                    Duel.BreakEffect()
                    Duel.SendtoHand(rg,nil,REASON_EFFECT)
                end
            end
            
            -- Đếm số lượng Spell "Sky Striker" (hỗ trợ cả bài face-down dựa vào thông tin gốc)
            local sk_count = g:FilterCount(function(c) return (c:IsSetCard(0x115) or c:IsOriginalSetCard(0x115)) and (c:IsType(TYPE_SPELL) or c:IsOriginalType(TYPE_SPELL)) end, nil)
            if sk_count>=3 and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) then
                if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                    local sc=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
                    if sc then
                        Duel.SendtoHand(sc,nil,REASON_EFFECT)
                        Duel.ConfirmCards(1-tp,sc)
                    end
                end
            end
        end
    end

    -- Giới hạn Triệu hồi Đặc biệt: chỉ được gọi quái thú "Sky Striker" trong phần còn lại của lượt
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x115)
end

function s.cfilter(c,tp)
    return c:IsControler(tp) and c:IsSetCard(0x115) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.lkfilter(c,e,tp)
    return c:IsSetCard(0x115) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false) 
        and Duel.IsExistingMatchingCard(aux.LinkSummonableFilter,tp,LOCATION_EXTRA,0,1,nil,c)
end

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.LinkSummon(tp,tc,nil)
    end
end