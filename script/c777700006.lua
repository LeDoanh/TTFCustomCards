-- Gensokyo Boundary - Gap of Phantasm
-- ID: 777700006
local s,id=GetID()

local SET_GENSOKYO = 0xa70

s.listed_series={SET_GENSOKYO}
s.listed_names={id}

function s.initial_effect(c)
	-- Hiệu ứng 1: Khi kích hoạt lá bài -> Có thể áp dụng 1 trong 3 hiệu ứng (HOPT kích hoạt bài)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi đối thủ target quái thú "Gensokyo" bạn điều khiển -> Trục xuất tạm thời đến hết Chain rồi trả về sân
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rmcon)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC CHỌN 1 TRONG 3 HIỆU ỨNG KHI KÍCH HOẠT
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tgfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.rmfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	local b3=Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if (b1 or b2 or b3) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)},
			{b3,aux.Stringid(id,3)})
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		elseif op==3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRỤC XUẤT TẠM THỜI NÉ TARGET ĐẾN HẾT CHAIN
--------------------------------------------------------------------------------
function s.has_used_name(tp,code)
	for _,v in ipairs({Duel.GetFlagEffectLabel(tp,id)}) do
		if v==code then return true end
	end
	return false
end

function s.dodgetgfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsSetCard(SET_GENSOKYO) and c:IsAbleToRemove()
		and not s.has_used_name(tp,c:GetOriginalCodeRule())
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.dodgetgfilter,1,nil,tp)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg then return end
	local g=tg:Filter(s.dodgetgfilter,nil,tp)
	if #g==0 then return end
	local c=e:GetHandler()
	if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,4)) then
		-- Nếu đối thủ target nhiều quái trùng tên gốc cùng lúc, chỉ được chọn 1 quái cho mỗi tên gốc
		if g:GetClassCount(Card.GetOriginalCodeRule)<#g then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g=aux.SelectUnselectGroup(g,e,tp,1,g:GetClassCount(Card.GetOriginalCodeRule),aux.dncheck,1,tp,HINTMSG_REMOVE)
		end
		if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
			local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			if #og>0 then
				for tc in aux.Next(og) do
					Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,tc:GetOriginalCodeRule())
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
				end
				og:KeepAlive()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_CHAIN_END)
				e1:SetLabelObject(og)
				e1:SetOperation(s.retop)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	if sg then
		for tc in aux.Next(sg) do
			if tc:HasFlagEffect(id) and tc:IsLocation(LOCATION_REMOVED) then
				Duel.ReturnToField(tc)
			end
		end
		sg:DeleteGroup()
	end
	e:Reset()
end
