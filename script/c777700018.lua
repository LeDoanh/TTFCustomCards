-- Gensokyo Scarlet - Scarlet Devil Mansion
-- ID: 777700018
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c
local COUNTER_BLOODY	   = 0x1a70 -- Bloody Counter

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}
s.counter_place_list={COUNTER_BLOODY}

function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BLOODY)

	-- Kích hoạt Field Spell
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Mỗi khi bạn mất LP -> Đặt 1 Bloody Counter lên lá này cho mỗi 400 LP bị mất
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Toàn bộ quái thú bạn điều khiển tăng 200 ATK/DEF cho mỗi Bloody Counter trên lá này
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2b)

	-- Hiệu ứng 3: Chọn 1 quái "Gensokyo Scarlet" trong Mộ/Trục xuất -> Gỡ Bloody Counter bằng Cấp của nó, Triệu hồi Đặc biệt & hồi LP bằng ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 4: Nếu lá bài này bị lộ -> Đặt thẳng vào vùng Field Zone của bạn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CONFIRM)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.tfcon)
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)

	-- Hiệu ứng 5 (Quick Effect): Khi 1 quái thú "Gensokyo" kích hoạt hiệu ứng -> Ngay sau khi giải quyết, Dung hợp 1 quái "Gensokyo Scarlet"
	local fparams={
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GENSOKYO_SCARLET)
	}
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,{id,2})
	e5:SetCondition(s.fuscon)
	e5:SetTarget(Fusion.SummonEffTG(fparams))
	e5:SetOperation(Fusion.SummonEffOP(fparams))
	c:RegisterEffect(e5)

	-- Bộ theo dõi toàn cục lượng LP bị mất (bao gồm trả LP, nhận sát thương, và giảm LP trực tiếp)
	aux.GlobalCheck(s,function()
		s.prev_lp={}
		local ge0=Effect.CreateEffect(c)
		ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge0:SetOperation(function()
			if not s.prev_lp[1] then s.prev_lp[1]=Duel.GetLP(0) end
			if not s.prev_lp[2] then s.prev_lp[2]=Duel.GetLP(1) end
		end)
		Duel.RegisterEffect(ge0,0)

		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.lpcheck)
		Duel.RegisterEffect(ge1,0)

		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_DAMAGE)
		Duel.RegisterEffect(ge2,0)

		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_PAY_LPCOST)
		Duel.RegisterEffect(ge3,0)
	end)
end

--------------------------------------------------------------------------------
-- 1. LOGIC ĐẶT BLOODY COUNTER MỖI KHI BẠN MẤT LP
--------------------------------------------------------------------------------
function s.lpcheck(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local curr=Duel.GetLP(p)
		local prev=s.prev_lp[p+1]
		if not prev then
			s.prev_lp[p+1]=curr
		elseif curr~=prev then
			s.prev_lp[p+1]=curr
			if curr<prev then
				Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,p,prev-curr)
			end
		end
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=400
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local cnt=ev//400
	if cnt>0 then
		e:GetHandler():AddCounter(COUNTER_BLOODY,cnt)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TĂNG 200 ATK/DEF CHO TOÀN BỘ QUÁI THÚ CỦA BẠN
--------------------------------------------------------------------------------
function s.atkval(e,c)
	return e:GetHandler():GetCounter(COUNTER_BLOODY)*200
end

--------------------------------------------------------------------------------
-- 3. LOGIC GỠ COUNTER ĐỂ TRIỆU HỒI TỪ MỘ / TRỤC XUẤT & HỒI LP BẰNG ATK
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp,fc)
	local lv=c:GetLevel()
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER) and lv>0
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and fc:IsCanRemoveCounter(tp,COUNTER_BLOODY,lv,REASON_EFFECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp,c) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)) then return end
	local lv=tc:GetLevel()
	if lv>0 and c:RemoveCounter(tp,COUNTER_BLOODY,lv,REASON_EFFECT) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			local atk=tc:GetAttack()
			if atk>0 then
				Duel.BreakEffect()
				Duel.Recover(tp,atk,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC ĐẶT THẲNG VÀO FIELD ZONE KHI BỊ LỘ
--------------------------------------------------------------------------------
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_FZONE) and not c:IsPosition(POS_FACEDOWN)
end

function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsForbidden() and c:CheckUniqueOnField(tp) end
end

function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsForbidden() and c:CheckUniqueOnField(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end

--------------------------------------------------------------------------------
-- 5. LOGIC QUICK EFFECT FUSION SUMMON KHI QUÁI "GENSOKYO" KÍCH HOẠT HIỆU ỨNG
--------------------------------------------------------------------------------
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	if re:GetHandler():IsSetCard(SET_GENSOKYO) then return true end
	local setcodes={Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)}
	for _,sc in ipairs(setcodes) do
		if (sc&0xfff)==SET_GENSOKYO or sc==SET_GENSOKYO then return true end
	end
	return false
end