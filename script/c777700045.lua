-- Gensokyo Eientei - Tewi, Queen of the Forest
-- ID: 777700045
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}
s.listed_names={id}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Liên kết: 3 quái thú, bao gồm ít nhất 1 quái thú "Gensokyo Eientei"
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,3,s.lcheck)

	-- Hiệu ứng 1: Khi được Triệu hồi Liên kết -> Lấy 1 lá "Gensokyo Eientei" từ Mộ hoặc vùng trục xuất lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Khi lá bài này đang ở trạng thái Co-Linked, đối thủ không thể kích hoạt Trap Card hoặc hiệu ứng Trap trong Mộ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.actcon)
	e2:SetValue(s.actlimit)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Toàn bộ quái thú "Gensokyo" bạn điều khiển tăng 500 ATK cho mỗi Monster Zone mà lá bài này chỉ tới
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GENSOKYO))
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

	-- Hiệu ứng 4: Nếu lá bài đã được Link Summon này bị gửi xuống Mộ
	-- -> Chọn 2 lá "Gensokyo Eientei" trong Mộ và/hoặc vùng trục xuất (trừ lá này); xào về Deck, sau đó rút 1 lá
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.tdcon)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. BỘ LỌC NGUYÊN LIỆU LINK (PHẢI CÓ ÍT NHẤT 1 QUÁI "GENSOKYO EIENTEI")
--------------------------------------------------------------------------------
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GENSOKYO_EIENTEI,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- 2. LOGIC LẤY 1 LÁ "GENSOKYO EIENTEI" TỪ MỘ / VÙNG TRỤC XUẤT KHI LINK SUMMON
--------------------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.thfilter(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC KHÓA KÍCH HOẠT TRAP / HIỆU ỨNG TRAP TRONG MỘ ĐỐI THỦ KHI CO-LINKED
--------------------------------------------------------------------------------
function s.actcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end

function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_TRAP) and re:GetActivateLocation()==LOCATION_GRAVE
end

--------------------------------------------------------------------------------
-- 4. LOGIC TĂNG 500 ATK CHO MỖI MONSTER ZONE MÀ LÁ BÀI NÀY CHỈ TỚI
--------------------------------------------------------------------------------
function s.atkval(e,c)
	local hc=e:GetHandler()
	local seq=hc:GetSequence()
	local lk=hc:GetLinkMarker()
	local ct=0
	if seq<5 then
		-- Đang ở Main Monster Zone (0..4)
		if seq>0 and (lk&LINK_MARKER_LEFT)~=0 then ct=ct+1 end
		if seq<4 and (lk&LINK_MARKER_RIGHT)~=0 then ct=ct+1 end
		if (seq==2 or seq==4) and (lk&LINK_MARKER_TOP_LEFT)~=0 then ct=ct+1 end
		if (seq==1 or seq==3) and (lk&LINK_MARKER_TOP)~=0 then ct=ct+1 end
		if (seq==0 or seq==2) and (lk&LINK_MARKER_TOP_RIGHT)~=0 then ct=ct+1 end
	else
		-- Đang ở Extra Monster Zone (5 hoặc 6)
		if (lk&LINK_MARKER_BOTTOM_LEFT)~=0 then ct=ct+1 end
		if (lk&LINK_MARKER_BOTTOM)~=0 then ct=ct+1 end
		if (lk&LINK_MARKER_BOTTOM_RIGHT)~=0 then ct=ct+1 end
		if (lk&LINK_MARKER_TOP_LEFT)~=0 then ct=ct+1 end
		if (lk&LINK_MARKER_TOP)~=0 then ct=ct+1 end
		if (lk&LINK_MARKER_TOP_RIGHT)~=0 then ct=ct+1 end
	end
	return ct*500
end

--------------------------------------------------------------------------------
-- 5. LOGIC XÀO 2 LÁ "GENSOKYO EIENTEI" VỀ DECK & RÚT 1 LÁ KHI BỊ GỬI XUỐNG MỘ
--------------------------------------------------------------------------------
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.tdfilter(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and not c:IsCode(id)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end