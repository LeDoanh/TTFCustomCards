-- Sky Striker Ace - Serpentis
-- ID: 90600112
local s,id=GetID()
local SET_SKY_STRIKER        = 0x115
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters, including a "Sky Striker" or Dragon monster
	Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(s.nontunerfilter), 1, 99)

	-- Cho phép dùng 1 "Sky Striker" Link Monster bạn điều khiển làm Tuner cấp 4 khi Synchro Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e0:SetValue(s.synval)
	c:RegisterEffect(e0)

	-- ① Hiệu ứng khi được Synchro Summon: Xáo tối đa 3 Spell "Sky Striker" từ Mộ vào Deck, rút 1 lá cho mỗi 3 lá, rồi có thể banish 1 lá trên sân đối thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.syncon)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)

	-- ② Quick Effect: Khi đối thủ kích hoạt hiệu ứng quái thú, banish 1 Spell từ Mộ để vô hiệu và giảm một nửa ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ③ Trong End Phase nếu bị gửi vào Mộ trong lượt này: Thêm 1 quái "Sky Striker" hoặc card "Æthel-Nemesis" từ Deck/GY lên tay
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SKY_STRIKER,SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN NGUYÊN LIỆU NON-TUNER & TÙY CHỈNH LINK LÀM TUNER
--------------------------------------------------------------------------------
function s.nontunerfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_SKY_STRIKER,scard,sumtype,tp) or c:IsRace(RACE_DRAGON,scard,sumtype,tp)
end

function s.synval(e,c,mg)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsType(TYPE_LINK) and c:IsFaceup()
end

--------------------------------------------------------------------------------
-- ① HIỆU ỨNG SYNCHRO SUMMON SUCCESS (XÁO SPELL VÀO DECK, RÚT VÀ BANISH)
--------------------------------------------------------------------------------
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.tdfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToDeck()
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end

function s.synop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,3,nil)
	if #g>0 then
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if ct>0 then
			local dct=math.floor(ct/3)
			if dct>0 and Duel.IsPlayerCanDraw(tp,dct) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.Draw(tp,dct,REASON_EFFECT)
			end
			-- Nếu đã xáo bài, tùy chọn banish 1 lá trên sân đối thủ
			local og=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
			if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
				local sg=og:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- ② QUICK EFFECT: VÔ HIỆU HÓA QUÁI THỨ VÀ GIẢM MỘT NỬA ATK
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end

function s.costfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GY,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.costfilter),tp,LOCATION_GY,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(function(e,c) return math.ceil(c:GetAttack()/2) * -1 end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e1)
	end
end

--------------------------------------------------------------------------------
-- ③ END PHASE: THÊM QUÁI "Sky Striker" HOẶC CARD "Æthel-Nemesis" LÊN TAY
--------------------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_SENT_TO_GY) and c:GetTurnID()==Duel.GetTurnCount()
end

function s.thfilter(c)
	return (c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster()) or c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end