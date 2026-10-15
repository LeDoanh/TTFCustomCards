-- Sky Striker Ace - Omega Zero
-- ID: 90600052
local s,id=GetID()
function s.initial_effect(c)
	-- Nguyên liệu Link: 2 quái thú "Sky Striker Ace"
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER_ACE),2,2)

	-- Bắt buộc phải Link Summon trước tiên
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.lnklimit)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1 (Quick Effect): Chọn 1 "Sky Striker" Spell từ GY (Banish & Copy) HOẶC Chọn 1 "Sky Striker" từ Deck (Thêm lên tay hoặc Gửi xuống GY)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Tribute lá bài này -> Special Summon 1 quái thú "Sky Striker Ace" từ GY hoặc bị Banish (trừ "Sky Striker Ace - Omega Zero")
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: CHỌN 1 TRONG 2 LỰA CHỌN (COPY SPELL TỪ GY HOẶC SEARCH/MILL TỪ DECK)
--------------------------------------------------------------------------------
function s.cpfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToRemove()
end

function s.thtgfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.cpfilter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) 
			or Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil) 
	end
	
	-- Cho phép người chơi chọn hình thức kích hoạt (Target từ GY hoặc chọn từ Deck)
	-- Ở đây ta ưu tiên cho phép chọn target từ GY nếu có, hoặc linh hoạt
	local b1=Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil)
	
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)) -- 0: Copy Spell từ GY, 1: Thêm/Gửi từ Deck
	elseif b1 then
		op=0
	else
		op=1
	end
	
	e:SetLabel(op)
	
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	else
		e:SetProperty(0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end

function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	
	if op==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- Sao chép tên và hiệu ứng của lá Spell bị Banish cho đến cuối lượt
			c:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.thtgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			local b1=tc:IsAbleToHand()
			local b2=tc:IsAbleToGrave()
			local sub_op=0
			if b1 and b2 then
				sub_op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5)) -- 0: Thêm lên tay, 1: Gửi xuống Mộ
			elseif b1 then
				sub_op=0
			elseif b2 then
				sub_op=1
			else
				return
			end
			
			if sub_op==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: TRIBUTE VÀ SPECIAL SUMMON SKY STRIKER ACE TỪ GY/BANISHMENT
--------------------------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end