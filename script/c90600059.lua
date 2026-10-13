-- Sky Striker Ace - Harbinger of Calamity
-- ID: 90600059
local s,id=GetID()
function s.initial_effect(c)
	-- Nguyên liệu Link: 3+ quái thú "Sky Striker"
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),3)

	-- Bắt buộc phải Link Summon trước tiên
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.lnklimit)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1: Tất cả quái thú ngửa mặt trên sân trở thành quái thú DARK Machine
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.attrtg)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_MACHINE)
	c:RegisterEffect(e3)

	-- Hiệu ứng 2: Khi đối thủ kích hoạt card/effect (Quick Effect) -> Bỏ 1 lá bài; vô hiệu hóa kích hoạt và phá hủy 1 lá bài trên sân
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)

	-- Hiệu ứng 3: Theo dõi trạng thái liên tục khi lá bài ở trên sân
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.adjustop)
	c:RegisterEffect(e5)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: ĐỔI THUỘC TÍNH VÀ CHỦNG TỘC CỦA QUÁI THÚ TRÊN SÂN
--------------------------------------------------------------------------------
function s.attrtg(e,c)
	return c:IsFaceup()
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: VÔ HIỆU HÓA KÍCH HOẠT VÀ PHÁ HỦY 1 CARD TRÊN SÂN
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstCardFromDeck()
	if Duel.NegateActivation(ev) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- HỆ THỐNG HOOK: BỎ QUA KIỂM TRA MAIN MONSTER ZONE TRỐNG CHO SKY STRIKER SPELLS
--------------------------------------------------------------------------------
if not s.sky_striker_hooked then
	s.sky_striker_hooked=true
	
	local old_GetFieldGroupCount=Duel.GetFieldGroupCount
	local old_GetFieldGroup=Duel.GetFieldGroup
	local old_GetMatchingGroupCount=Duel.GetMatchingGroupCount
	local old_IsExistingMatchingCard=Duel.IsExistingMatchingCard

	local function is_harbinger_active(tp)
		return old_IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() end, tp, LOCATION_MZONE, 0, 1, nil)
	end

	local function is_mmzone(loc)
		if not loc then return false end
		local mmz = rawget(_G, "LOCATION_MMZONE")
		return (mmz and loc == mmz)
	end

	if old_GetFieldGroupCount then
		Duel.GetFieldGroupCount=function(p, s_loc, o_loc, ...)
			if is_mmzone(s_loc) and is_harbinger_active(p) then
				return 0
			end
			return old_GetFieldGroupCount(p, s_loc, o_loc, ...)
		end
	end

	if old_GetFieldGroup then
		Duel.GetFieldGroup=function(p, s_loc, o_loc, ...)
			if is_mmzone(s_loc) and is_harbinger_active(p) then
				return Group.CreateGroup()
			end
			return old_GetFieldGroup(p, s_loc, o_loc, ...)
		end
	end

	if old_GetMatchingGroupCount then
		Duel.GetMatchingGroupCount=function(f, p, s_loc, o_loc, ex, ...)
			if is_mmzone(s_loc) and is_harbinger_active(p) then
				return 0
			end
			return old_GetMatchingGroupCount(f, p, s_loc, o_loc, ex, ...)
		end
	end

	if old_IsExistingMatchingCard then
		Duel.IsExistingMatchingCard=function(f, p, s_loc, o_loc, ct, ex, ...)
			if is_mmzone(s_loc) and is_harbinger_active(p) then
				return false
			end
			return old_IsExistingMatchingCard(f, p, s_loc, o_loc, ct, ex, ...)
		end
	end
end

s.patched_tables = {}
function s.patch_cfilter()
	for k,v in pairs(_G) do
		if type(k)=="string" and k:sub(1,1)=="c" and type(v)=="table" and not s.patched_tables[v] then
			if type(v.cfilter)=="function" then
				local old_cfilter=v.cfilter
				v.cfilter=function(c,...)
					if Duel.IsExistingMatchingCard(function(tc) return tc:IsFaceup() and tc:IsCode(id) and not tc:IsDisabled() end,c:GetControler(),LOCATION_MZONE,0,1,nil) then
						return false
					end
					return old_cfilter(c,...)
				end
				s.patched_tables[v]=true
			end
		end
	end
end
s.patch_cfilter()

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	s.patch_cfilter()
end