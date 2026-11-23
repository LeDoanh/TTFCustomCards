-- Sky Striker Airspace - Sector Omega
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt Field Spell & Hiệu ứng đào 5 lá
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng: Cho phép kích hoạt Sky Striker Spell kể cả khi có quái thú ở Main Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)

	-- Hiệu ứng: Tăng công thủ (100 ATK/DEF cho mỗi Spell trong Mộ)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
s.listed_series={0x115} -- Setcode Sky Striker

-- ==================================================
-- HIỆU ỨNG KÍCH HOẠT: Đào 5 lá trên cùng Bộ bài
-- ==================================================
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thfilter(c)
	return c:IsSetCard(0x115) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.ConfirmDecktop(tp,5)
		local g=Duel.GetDecktopGroup(tp,5)
		if #g>0 then
			Duel.DisableShuffleCheck()
			if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
				if #sg>0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
					Duel.ShuffleHand(tp)
				end
			end
			Duel.ShuffleDeck(tp)
		end
	end
end

-- ==================================================
-- HỆ THỐNG HOOK: An toàn tuyệt đối cho Synchro Summon
-- ==================================================
if not s.sky_striker_hooked then
	s.sky_striker_hooked=true
	
	local old_GetFieldGroupCount=Duel.GetFieldGroupCount
	local old_GetMatchingGroupCount=Duel.GetMatchingGroupCount
	local old_IsExistingMatchingCard=Duel.IsExistingMatchingCard

	local function is_omega_active(tp)
		return old_IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() end, tp, LOCATION_FZONE, 0, 1, nil)
	end

	local function is_mmzone(loc)
		if not loc then return false end
		local mmz = rawget(_G, "LOCATION_MMZONE")
		return (mmz and loc == mmz)
	end

	-- Chỉ can thiệp khi hàm kiểm tra xuất phát từ check số lượng quái Main Zone của Sky Striker Spell
	if old_GetFieldGroupCount then
		Duel.GetFieldGroupCount=function(p, s_loc, o_loc, ...)
			if is_mmzone(s_loc) and is_omega_active(p) then
				-- Đảm bảo chỉ trả về 0 khi tiến trình gọi kiểm tra không phải từ bộ quy tắc Synchro/Extra Deck
				local info = debug.getinfo(2, "S")
				if info and info.source and not info.source:find("proc_") then
					return 0
				end
			end
			return old_GetFieldGroupCount(p, s_loc, o_loc, ...)
		end
	end

	if old_GetMatchingGroupCount then
		Duel.GetMatchingGroupCount=function(f, p, s_loc, o_loc, ex, ...)
			if is_mmzone(s_loc) and is_omega_active(p) then
				local info = debug.getinfo(2, "S")
				if info and info.source and not info.source:find("proc_") then
					return 0
				end
			end
			return old_GetMatchingGroupCount(f, p, s_loc, o_loc, ex, ...)
		end
	end

	if old_IsExistingMatchingCard then
		Duel.IsExistingMatchingCard=function(f, p, s_loc, o_loc, ct, ex, ...)
			if is_mmzone(s_loc) and is_omega_active(p) then
				local info = debug.getinfo(2, "S")
				if info and info.source and not info.source:find("proc_") then
					return false
				end
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
					if Duel.IsExistingMatchingCard(function(tc) return tc:IsFaceup() and tc:IsCode(id) and not tc:IsDisabled() end,c:GetControler(),LOCATION_FZONE,0,1,nil) then
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

-- ==================================================
-- HIỆU ỨNG TĂNG ATK/DEF
-- ==================================================
function s.atktg(e,c)
	return c:IsSetCard(0x115)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_SPELL)*100
end