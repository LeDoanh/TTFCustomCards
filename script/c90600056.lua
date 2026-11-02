-- Sky Striker Mecha Modules - Core Processor
-- ID: 90600056
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt lá bài Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1: Đối thủ không thể kích hoạt card/effect để phản ứng với việc kích hoạt card/effect "Sky Striker" của bạn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Gửi 1 card từ tay/sân xuống GY -> Úp 1 card "Sky Striker" từ Deck/GY (có thể kích hoạt trong lượt), đồng thời khóa Extra Deck ngoại trừ quái "Sky Striker"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3: Trong Main Phase - Chọn bất kỳ số lượng "Sky Striker" Spell khác tên trong GY -> Lấy lên tay hoặc Úp lên sân
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: KHÓA CHUỖI PHẢN ỨNG (ANTI-CHAIN) CỦA ĐỐI THỦ
--------------------------------------------------------------------------------
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and rc:IsSetCard(SET_SKY_STRIKER) then
		Duel.SetChainLimit(s.chainlimit)
	end
end

function s.chainlimit(e,rp,tp)
	return rp==tp
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: ÚP CARD TỪ DECK/GY & KÍCH HOẠT NGAY TRONG LƯỢT
--------------------------------------------------------------------------------
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end

function s.setfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		-- Cho phép kích hoạt lá bài vừa Úp ngay trong lượt này
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
	end

	-- Khóa Special Summon quái từ Extra Deck ngoại trừ quái "Sky Striker" trong phần còn lại của lượt
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_SKY_STRIKER)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 3: LẤY HOẶC ÚP NHIỀU SPELL "SKY STRIKER" KHÁC TÊN TỪ GY
--------------------------------------------------------------------------------
function s.gyfilter(c,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and (c:IsAbleToHand() or (c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0))
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,nil,tp)
	if #g==0 then return end
	
	-- Sử dụng aux.SelectUnselectGroup với aux.dncheck để lọc bài khác tên an toàn chuẩn EDOPro
	local sg=aux.SelectUnselectGroup(g,e,tp,1,#g,aux.dncheck,1,tp,HINTMSG_SELECT)
	if sg and #sg>0 then
		for tc in aux.Next(sg) do
			local b1=tc:IsAbleToHand()
			local b2=tc:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			local op=0
			if b1 and b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			elseif b1 then
				op=0
			elseif b2 then
				op=1
			else
				goto continue
			end
			
			if op==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SSet(tp,tc)
			end
			::continue::
		end
	end
end