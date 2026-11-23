-- Gensokyo Eientei - Palace of the Eternal Moon
-- ID: 777700046
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc
local TOKEN_EIENTEI		= 777700038 -- Eientei Token
local COUNTER_MOON		 = 0x1a71	-- Moon Counter

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}
s.listed_names={id,TOKEN_EIENTEI}
s.counter_place_list={COUNTER_MOON}

function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_MOON)
	c:SetCounterLimit(COUNTER_MOON,5)

	-- Hiệu ứng 1: Kích hoạt bài -> Có thể gửi 1 quái "Gensokyo Eientei" trên tay & 1 lá "Gensokyo Eientei" từ Deck xuống Mộ;
	-- Triệu hồi Đặc biệt 2 "Eientei Token" (chỉ được dùng làm nguyên liệu Link cho quái "Gensokyo Eientei")
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu lá bài này sắp bị phá hủy khi bạn điều khiển Link Monster "Gensokyo Eientei"
	-- -> Có thể trục xuất lá trên cùng Deck; nếu là lá "Gensokyo Eientei", lá bài này không bị phá hủy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(function() end)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Mỗi khi 1 "Eientei Token" được Triệu hồi (trừ Token do hiệu ứng lá bài này gọi ra)
	-- -> Có thể Hiến tế Token đó; đặt 1 Moon Counter lên lá bài này (tối đa 5)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.ctcon)
	e3:SetCost(s.ctcost)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 4 (Soft OPT): Gỡ số lượng Moon Counter trên lá này -> Triệu hồi Đặc biệt 1 Link Monster "Gensokyo Eientei"
	-- từ Extra Deck có Link Rating bằng đúng số Moon Counter đã gỡ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC KÍCH HOẠT & GỬI TAY/DECK XUỐNG MỘ -> TRIỆU HỒI 2 "EIENTEI TOKEN"
--------------------------------------------------------------------------------
function s.tgfilter_hand(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end

function s.tgfilter_deck(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsAbleToGraveAsCost()
end

function s.can_summon_2_tokens(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EIENTEI,0,TYPES_TOKEN,0,0,1,RACE_PSYCHIC,ATTRIBUTE_LIGHT)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(s.tgfilter_hand,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter_deck,tp,LOCATION_DECK,0,1,nil)
		and s.can_summon_2_tokens(tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectMatchingCard(tp,s.tgfilter_hand,tp,LOCATION_HAND,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.tgfilter_deck,tp,LOCATION_DECK,0,1,1,nil)
		g1:Merge(g2)
		Duel.SendtoGrave(g1,REASON_COST)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1 or not e:GetHandler():IsRelateToEffect(e) then return end
	if not s.can_summon_2_tokens(tp) then return end
	local c=e:GetHandler()
	for i=1,2 do
		local token=Duel.CreateToken(tp,TOKEN_EIENTEI)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			-- Chỉ được dùng làm nguyên liệu Link cho quái thú "Gensokyo Eientei"
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(s.lnklimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e2:SetValue(1)
			token:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			token:RegisterEffect(e3,true)
			local e4=e2:Clone()
			e4:SetCode(EFFECT_UNRELEASABLE_SUM)
			token:RegisterEffect(e4,true)
			local e5=e2:Clone()
			e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e5,true)
		end
	end
	Duel.SpecialSummonComplete()
end

function s.lnklimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_GENSOKYO_EIENTEI)
end

--------------------------------------------------------------------------------
-- 2. LOGIC CHỐNG PHÁ HỦY BẰNG CÁCH TRỤC XUẤT LÁ TRÊN CÙNG DECK
--------------------------------------------------------------------------------
function s.lnkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_LINK)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.GetDecktopGroup(tp,1)
		return not c:IsReason(REASON_REPLACE)
			and Duel.IsExistingMatchingCard(s.lnkfilter,tp,LOCATION_MZONE,0,1,nil)
			and #g>0 and g:GetFirst():IsAbleToRemove()
	end
	if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3)) then
		local g=Duel.GetDecktopGroup(tp,1)
		Duel.DisableShuffleCheck()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			local tc=g:GetFirst()
			return tc and tc:IsLocation(LOCATION_REMOVED) and tc:IsSetCard(SET_GENSOKYO_EIENTEI)
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- 3. LOGIC HIẾN TẾ "EIENTEI TOKEN" KHÁC ĐỂ ĐẶT MOON COUNTER (TỐI ĐA 5)
--------------------------------------------------------------------------------
function s.tkfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(TOKEN_EIENTEI) and c:IsReleasable()
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandler()==e:GetHandler() then return false end
	return eg:IsExists(s.tkfilter,1,nil,tp)
end

function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.tkfilter,nil,tp)
	if chk==0 then return #g>0 end
	local tc=g:GetFirst()
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	Duel.Release(tc,REASON_COST)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(COUNTER_MOON,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_MOON)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanAddCounter(COUNTER_MOON,1) then
		c:AddCounter(COUNTER_MOON,1)
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC GỠ MOON COUNTER -> TRIỆU HỒI LINK MONSTER TỪ EXTRA DECK
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp,lk)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_LINK) and c:GetLink()==lk
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local max_ct=c:GetCounter(COUNTER_MOON)
	local opts={}
	for i=1,max_ct do
		if c:IsCanRemoveCounter(tp,COUNTER_MOON,i,REASON_COST)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i) then
			table.insert(opts,i)
		end
	end
	if chk==0 then return #opts>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
	local cnt=Duel.AnnounceNumber(tp,table.unpack(opts))
	c:RemoveCounter(tp,COUNTER_MOON,cnt,REASON_COST)
	e:SetLabel(cnt)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local cnt=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,cnt)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
