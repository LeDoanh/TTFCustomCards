-- Sky Striker Airspace - Assembly Area
-- ID: 90600061
local s,id=GetID()
local SET_SKY_STRIKER = 0x115

function s.initial_effect(c)
	-- Kích hoạt Field Spell: Lấy 1 quái thú "Sky Striker" từ Deck lên tay (tùy chọn)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng: Tăng 300 ATK/DEF cho quái "Sky Striker" ở Extra Monster Zone với mỗi Spell trong GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG KÍCH HOẠT: SEARCH QUÁI THÚ "SKY STRIKER" TỪ DECK
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster() and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG TĂNG ATK/DEF (300 ATK/DEF CHO MỖI SPELL TRONG GY CHO QUÁI TẠI EMZ)
--------------------------------------------------------------------------------
function s.atktg(e,c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:GetSequence()>=5
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSpell,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end