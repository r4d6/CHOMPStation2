// Specialized AI for metroid simplemobs.
// Unlike the parent AI code, this will probably break a lot of things if you put it on something that isn't /mob/living/simple_mob/metroid/juvenile

/datum/ai_holder/simple_mob/juvenile_metroid
	hostile = TRUE
	cooperative = TRUE
	firing_lanes = TRUE
	mauling = TRUE // They need it to get the most out of monkeys.

	var/always_stun = FALSE // If true, the slime will elect to attempt to permastun the target.
/*
/datum/ai_holder/simple_mob/juvenile_metroid/ranged
	pointblank = TRUE
*/


/datum/ai_holder/simple_mob/juvenile_metroid/passive/New() // For Jellybrig.
	..()
	pacify()

/datum/ai_holder/simple_mob/juvenile_metroid/New()
	..()
	ASSERT(istype(holder, /mob/living/simple_mob/metroid/juvenile))


/datum/ai_holder/simple_mob/juvenile_metroid/handle_special_tactic()
	evolve_and_reproduce()

// Hit the correct verbs to keep the slime species going.
/datum/ai_holder/simple_mob/juvenile_metroid/proc/evolve_and_reproduce()
	var/mob/living/simple_mob/metroid/juvenile/my_juvenile = holder
	if(my_juvenile.nutrition >= my_juvenile.evo_point)
		// Press the correct verb when we can.
		if(my_juvenile.is_adult)
			my_juvenile.reproduce() // Splits into four new baby slimes.
		else
			my_juvenile.evolve() // Turns our holder into an adult slime.


// Called when using a pacification agent (or it's Jellybrig being initalized). Actually it's all just jellybrig, but I'm stealing everything from slime code anyway.
/datum/ai_holder/simple_mob/juvenile_metroid/proc/pacify()
	remove_target() // So it stops trying to kill them.
	hostile = FALSE
	retaliate = TRUE //Exceot for this. He retaliates because he's a vore mob.
	cooperative = FALSE
	holder.a_intent = I_HELP

// The holder's attack changes based on intent. This lets the AI choose what effect is desired.
/datum/ai_holder/simple_mob/juvenile_metroid/pre_melee_attack(atom/A)
	if(istype(A, /mob/living))
		var/mob/living/L = A
		var/mob/living/simple_mob/metroid/juvenile/my_juvenile = holder

		if( (!L.lying && prob(30 + (my_juvenile.power_charge * 7) ) || (!L.lying && always_stun) ))
			my_juvenile.a_intent = I_DISARM // Stun them first.
		else if(my_juvenile.can_consume(L) && L.lying)
			my_juvenile.a_intent = I_GRAB // Then eat them.
		else
			my_juvenile.a_intent = I_HURT // Otherwise robust them.

/datum/ai_holder/simple_mob/juvenile_metroid/closest_distance(atom/movable/AM)
	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.species, /datum/species/monkey))
				return 1 // Otherwise ranged slimes will eat a lot less often.
		if(L.stat >= UNCONSCIOUS)
			return 1 // Melee (eat) the target if dead/dying, don't shoot it.
	return ..()

/datum/ai_holder/simple_mob/juvenile_metroid/can_attack(atom/movable/AM, var/vision_required = TRUE)
	. = ..()
	if(.) // Do some additional checks because we have Special Code(tm).
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(istype(H.species, /datum/species/monkey)) // istype() is so they'll eat the alien monkeys too.
				return TRUE // Monkeys are always food (sorry Pun Pun).
