-- Gensokyo Anomaly - Gathering of Spirits
-- ID: 777700008
local s,id=GetID()

local SET_GENSOKYO = 0xa70

s.listed_series={SET_GENSOKYO}

function s.initial_effect(c)
	-- Hiệu ứng 1: Counter Trap vô hiệu hóa kích hoạt, trả về đầu/đáy Deck và khóa tên gốc của các Chain Link trước đó
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 2 (chỉ được xài 1 trong 2 hiệu ứng mỗi lượt)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trục xuất lá này từ Mộ -> Triệu hồi Đặc biệt 1 quái "Gensokyo" từ Mộ/Trục xuất ở thế Thủ (bị vô hiệu hóa hiệu ứng)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) -- Hiệu ứng dưới Mộ của Trap mặc định là Spell Speed 2
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 1
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC COUNTER TRAP + TRẢ VỀ DECK + KHÓA TÊN GỐC SAU KHI CHAIN KẾT THÚC
--------------------------------------------------------------------------------
function s.is_gensokyo_cl(cl)
	local prev_re=Duel.GetChainInfo(cl,CHAININFO_TRIGGERING_EFFECT)
	if not prev_re then return false end
	if prev_re:GetHandler():IsSetCard(SET_GENSOKYO) then return true end
	local setcodes={Duel.GetChainInfo(cl,CHAININFO_TRIGGERING_SETCODES)}
	for _,sc in ipairs(setcodes) do
		if (sc&0xfff)==SET_GENSOKYO or sc==SET_GENSOKYO then return true end
	end
	return false
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- Đối thủ kích hoạt bài/hiệu ứng để phản hồi lại việc kích hoạt bài/hiệu ứng "Gensokyo" ở Chain Link ngay trước đó
	return ep==1-tp and ev>1 and Duel.IsChainNegatable(ev) and s.is_gensokyo_cl(ev-1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsAbleToDeck() then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if Duel.NegateActivation(ev) and tc:IsRelateToEffect(re) then
		tc:CancelToGrave()
		-- Đối thủ (1-tp) chọn đặt lên đầu Deck hoặc dưới đáy Deck
		local opt=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))
		Duel.SendtoDeck(tc,nil,opt==0 and SEQ_DECKTOP or SEQ_DECKBOTTOM,REASON_EFFECT)
	end

	-- Lưu lại toàn bộ tên gốc của các bài/hiệu ứng ở các Chain Link thấp hơn lá này
	local codes={}
	local cc=Duel.GetCurrentChain()
	for i=1,cc-1 do
		local ce=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if ce then
			table.insert(codes,ce:GetHandler():GetOriginalCodeRule())
		end
	end

	-- Sau khi Chain hiện tại kết thúc, cấm cả 2 người chơi kích hoạt các lá/hiệu ứng có tên gốc đó đến hết lượt
	if #codes>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(function(te)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,1)
			e2:SetValue(function(_,cre)
				local rc=cre:GetHandler()
				for _,code in ipairs(codes) do
					if rc:IsOriginalCodeRule(code) then return true end
				end
				return false
			end)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
			te:Reset()
		end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRIỆU HỒI ĐẶC BIỆT TỪ MỘ / TRỤC XUẤT (VÔ HIỆU HÓA HIỆU ỨNG)
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
