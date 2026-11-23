-- Gensokyo Eientei - Beyond of the Moon
-- ID: 777700051
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Nếu từ 2 quái thú trở lên, hoặc 1 quái thú "Gensokyo" bạn điều khiển bị gửi xuống Mộ bởi hiệu ứng bài đối thủ
	-- -> Triệu hồi Đặc biệt các quái thú đó, sau đó phá hủy quái thú đối thủ điều khiển tối đa bằng số quái vừa Triệu hồi
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ): Trục xuất lá bài này -> Trả 3 lá "Gensokyo" từ Mộ và/hoặc vùng trục xuất về Deck/Extra Deck,
	-- sau đó rút 2 lá và bỏ 1 lá trên tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOEXTRA+CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC HỒI SINH QUÁI BỊ GỬI MỘ BỞI ĐỐI THỦ & PHÁ HỦY QUÁI ĐỐI THỦ
--------------------------------------------------------------------------------
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetReason()&(REASON_EFFECT+REASON_DESTROY))~=0
		and c:GetReasonPlayer()==1-tp
end

function s.gfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(SET_GENSOKYO)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,tp)
	return #g>=2 or (#g==1 and g:IsExists(s.gfilter,1,nil))
end

function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,tp):Filter(s.spfilter,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g
		and (#g==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(aux.NecroValleyFilter(s.spfilter),nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #g==0 or ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if #g>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=g:Select(tp,ft,ft,nil)
	end
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	if ct>0 then
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,ct,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC DƯỚI MỘ: TRẢ 3 LÁ "GENSOKYO" VỀ DECK/EXTRA DECK -> RÚT 2 & BỎ 1
--------------------------------------------------------------------------------
function s.tdfilter(c)
	return c:IsSetCard(SET_GENSOKYO)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and (c:IsAbleToDeck() or c:IsAbleToExtra())
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=g:Select(tp,3,3,nil)
	Duel.HintSelection(tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
		if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3 then
			Duel.BreakEffect()
			if Duel.Draw(tp,2,REASON_EFFECT)==2 then
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
				Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
			end
		end
	end
end