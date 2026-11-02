-- Æthel Nemesis Assimilation - System Purge
-- ID: 90600094
local s,id=GetID()
function s.initial_effect(c)
    -- Kích hoạt: Banish 1 lá "Æthel-Nemesis" từ Deck, sau đó rút 1 lá nếu có >= 3 Spells bị banish
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Mã Archetype (0x115a: Æthel-Nemesis)
s.listed_series={0x115a}

function s.rmfilter(c)
    return c:IsSetCard(0x115a) and not c:IsCode(id) and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
    if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3 then
        Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        -- Kiểm tra nếu có từ 3 Spells bị banish trở lên thì được rút 1 lá
        if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3 
            and Duel.IsPlayerCanDraw(tp,1) 
            and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end