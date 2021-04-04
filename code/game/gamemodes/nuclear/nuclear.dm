/*
	MERCENARY ROUNDTYPE
*/

var/list/nuke_disks = list()

/datum/game_mode/nuclear
	name = "Chaos Insurgency"
	round_description = "A Chaos Insurgency strike force is approaching!"
	extended_round_description = "The site's success and safety has attracted the prevasive eye  \
		of the Chaos Insurgency, a heavily militarized organization in opposition to the Foundation."
	config_tag = "mercenary"
	required_players = 9999 // пока войд режим не допилит
	required_enemies = 1
	end_on_antag_death = 1
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/syndies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level
	antag_tags = list(MODE_MERCENARY)

//checks if L has a nuke disk on their person
/datum/game_mode/nuclear/proc/check_mob(mob/living/L)
	for(var/obj/item/weapon/disk/nuclear/N in nuke_disks)
		if(N.storage_depth(L) >= 0)
			return 1
	return 0

/datum/game_mode/nuclear/declare_completion()
	var/datum/antagonist/merc = all_antag_types()[MODE_MERCENARY]
	if(config.objectives_disabled == CONFIG_OBJECTIVE_NONE || (merc && !merc.global_objectives.len))
		..()
		return
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in global.item_list)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, GLOB.using_map.post_round_safe_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (evacuation_controller.has_evacuated())

	if(!disk_rescued &&  station_was_nuked && !syndies_didnt_escape)
		feedback_set_details("round_end_result","win - syndicate nuke")
		to_world("<FONT size = 3><B>Chaos Insurgency Major Victory!</B></FONT>")
		to_world("<B>Chaos Insurgency operatives have destroyed [station_name()]!</B>")

	else if (!disk_rescued &&  station_was_nuked && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		to_world("<FONT size = 3><B>Total Annihilation</B></FONT>")
		to_world("<B>Chaos Insurgency operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		to_world("<FONT size = 3><B>Site Minor Victory</B></FONT>")
		to_world("<B>Chaos Insurgency operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!")

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && syndies_didnt_escape)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		to_world("<FONT size = 3><B>Chaos Insurgency operatives have earned Darwin Award!</B></FONT>")
		to_world("<B>Chaos Insurgency operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!")

	else if (disk_rescued && mercs.antags_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		to_world("<FONT size = 3><B>Site Major Victory!</B></FONT>")
		to_world("<B>The Site Staff has saved the disc and killed the Chaos Insurgency Operatives</B>")

	else if ( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		to_world("<FONT size = 3><B>Site Major Victory</B></FONT>")
		to_world("<B>The Site Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>")

	else if (!disk_rescued && mercs.antags_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		to_world("<FONT size = 3><B>Chaos InsurgencyMinor Victory!</B></FONT>")
		to_world("<B>The Site Staff failed to secure the authentication disk but did manage to kill most of the Chaos Insurgency Operatives!</B>")

	else if (!disk_rescued && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		to_world("<FONT size = 3><B>Chaos Insurgency Minor Victory!</B></FONT>")
		to_world("<B>Chaos Insurgency operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!")

	else if (!disk_rescued && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		to_world("<FONT size = 3><B>Neutral Victory</B></FONT>")
		to_world("<B>Round was mysteriously interrupted!</B>")

	..()
	return
