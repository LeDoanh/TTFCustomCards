-- Sky Striker Airspace - Assembly Area
-- ID: 90600061
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt Field Spell: Lấy 1 quái thú "Sky Striker" từ Deck lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng continuous: Cho phép kích hoạt Sky Striker Spell ngay cả khi có quái ở Main Monster Zone (Bypass Hook)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)

	-- Hiệu ứng: Tăng 300 ATK/DEF cho quái "Sky Striker" ở Extra Monster Zone với mỗi Spell trong GY
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

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG KÍCH HOẠT: SEARCH QUÁI THÚ "SKY STRIKER" TỪ DECK
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster() and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

--------------------------------------------------------------------------------
-- HỆ THỐNG HOOK: OVERRIDE LỖI MAIN MONSTER ZONE
--------------------------------------------------------------------------------
if not s.sky_striker_hooked then
	s.sky_striker_hooked=true
	
	local old_GetFieldGroupCount=Duel.GetFieldGroupCount
	local old_GetFieldGroup=Duel.GetFieldGroup
	local old_GetMatchingGroupCount=Duel.GetMatchingGroupCount
	local old_IsExistingMatchingCard=Duel.IsExistingMatchingCard

	local function is_assembly_active(tp)
		return old_IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(id) and not c:IsDisabled() end, tp, LOCATION_FZONE, 0, 1, nil)
	end

	local function is_mmzone(loc)
		if not loc then return false end
		local mmz = rawget(_G, "LOCATION_MMZONE")
		return (mmz and loc == mmz)
	end

	if old_GetFieldGroupCount then
		Duel.GetFieldGroupCount=function(p, s_loc, o_loc, ...)
			if is_mmzone(s_loc) and is_assembly_active(p) then
				return 0
			end
			return old_GetFieldGroupCount(p, s_loc, o_loc, ...)
		end
	end

	if old_GetFieldGroup then
		Duel.GetFieldGroup=function(p, s_loc, o_loc, ...)
			if is_mmzone(s_loc) and is_assembly_active(p) then
				return Group.CreateGroup()
			end
			return old_GetFieldGroup(p, s_loc, o_loc, ...)
		end
	end

	if old_GetMatchingGroupCount then
		Duel.GetMatchingGroupCount=function(f, p, s_loc, o_loc, ex, ...)
			if is_mmzone(s_loc) and is_assembly_active(p) then
				return 0
			end
			return old_GetMatchingGroupCount(f, p, s_loc, o_loc, ex, ...)
		end
	end

	if old_IsExistingMatchingCard then
		Duel.IsExistingMatchingCard=function(f, p, s_loc, o_loc, ct, ex, ...)
			if is_mmzone(s_loc) and is_assembly_active(p) then
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

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	s.patch_cfilter()
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG TĂNG ATK/DEF (300 ATK/DEF CHO MỖI SPELL TRONG GY CHO QUÁI TẠI EMZ)
--------------------------------------------------------------------------------
function s.atktg(e,c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:GetSequence()>=5
end

function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSpell,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end