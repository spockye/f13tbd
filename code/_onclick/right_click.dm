/mob/proc/RightClickOn(atom/A, params) //mostly a copy-paste from ClickOn()
	var/list/modifiers = params2list(params)
	if(incapacitated(ignore_restraints = 1))
		return

	face_atom(A)

	if(!CheckActionCooldown())
		return

	if(!modifiers["catcher"] && A.IsObscured())
		return

	if(ismecha(loc))
		var/obj/mecha/M = loc
		return M.click_action(A,src,params)

	if(restrained())
		DelayNextAction(CLICK_CD_HANDCUFFED)
		RestrainedClickOn(A)
		return TRUE

	if(in_throw_mode)
		throw_item(A)//todo: make it plausible to lightly toss items via right-click
		return

	var/obj/item/W = get_active_held_item()

	if(W == A)
		if(!W.rightclick_attack_self(src))
			W.attack_self(src)
		update_inv_hands()
		return

	//These are always reachable.
	//User itself, current loc, and user inventory
	if(A in DirectAccess())
		if(W)
			. = W.melee_attack_chain(src, A, params)
			return !(. & DISCARD_LAST_ACTION)
		else
			if(!AltUnarmedAttack(A))
				. = UnarmedAttack(A)
				if(!(. & NO_AUTO_CLICKDELAY_HANDLING) && ismob(A))
					DelayNextAction(CLICK_CD_MELEE))
				return .? TRUE : FALSE
			return TRUE

	//Can't reach anything else in lockers or other weirdness
	if(!loc.AllowClick())
		return

	//Standard reach turf to turf or reaching inside storage
	if(CanReach(A,W))
		if(W)
			. = W.melee_attack_chain(src, A, params)
			return !(. & DISCARD_LAST_ACTION)
		else
			if(!AltUnarmedAttack(A,1))
				. = UnarmedAttack(A)
				if(!(. & NO_AUTO_CLICKDELAY_HANDLING) && ismob(A))
					DelayNextAction(CLICK_CD_MELEE))
				return .? TRUE : FALSE
			return TRUE
	else
		if(W)
			if(!W.altafterattack(A, src, FALSE, params))
				W.afterattack(A, src, FALSE, params)
		else
			if(!AltRangedAttack(A,params))
				RangedAttack(A,params)
				return
			return TRUE

/mob/proc/AltUnarmedAttack(atom/A, proximity_flag)
	if(ismob(A))
		DelayNextAction(CLICK_CD_MELEE)
	return FALSE

/mob/proc/AltRangedAttack(atom/A, params)
	return FALSE
