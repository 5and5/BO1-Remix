#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_zone_manager; 
#include maps\zombie_theater_quad;
main()
{
	maps\zombie_ww_fx::main();
	maps\zombie_ww_amb::main();

	//setExpFog(100, 1000, 0.4, 0.425, 0.44, 0.0);
	setVolFog( 110, 2016, 621, 674, 0.572, 0.672, 0.678, 0 );
	// for weight functions
	level.total_chest_hits = 0;
	
	level.pulls_since_tesla = 0;
	level.pulls_since_tgun = 0;
	level.pulls_since_dolls = 0;
	level.pulls_since_ray_gun = 0;

	level.total_tesla_hits = 0;
	level.total_tgun_hits = 0;
	level.total_dolls_hits = 0;

	level.total_tesla_trades = 0;
	level.total_tgun_trades = 0;
	level.total_dolls_trades = 0;
	level.total_ray_gun_trades = 0;

	level.player_drops_tesla_gun = false;
	level.player_drops_thundergun = false;
	level.player_drops_dolls = false;
	level.player_drops_ray_gun = false;

	//remove fog
	//setExpFog(0, 0, 0, 0, 0, 0);
	//setVolFog(0, 0, 0, 0, 0, 0, 0, 0);
	// der riese dvars
	SetSavedDvar( "r_lightGridEnableTweaks", 1 );
	SetSavedDvar( "r_lightGridIntensity", 1.45 );
	SetSavedDvar( "r_lightGridContrast", 0.15 );

	PreCacheModel("zombie_zapper_cagelight_red");
	precachemodel("zombie_zapper_cagelight_green");
	precacheShader("ac130_overlay_grain");	
	precacheshellshock( "electrocution" );
	// ww: viewmodel arms for the level
	PreCacheModel( "viewmodel_usa_pow_arms" ); // Dempsey
	PreCacheModel( "viewmodel_rus_prisoner_arms" ); // Nikolai
	PreCacheModel( "viewmodel_vtn_nva_standard_arms" );// Takeo
	PreCacheModel( "viewmodel_usa_hazmat_arms" );// Richtofen
	// DSM: models for light changing
	PreCacheModel("zombie_zapper_cagelight_on");
	precachemodel("zombie_zapper_cagelight");
	if(GetDvarInt( #"artist") > 0)
	{
		return;
	}
	
	level.random_pandora_box_start = true;
	level.zombiemode_using_marathon_perk = true;
	level.zombiemode_using_divetonuke_perk = true;
	level.zombiemode_using_deadshot_perk = true;
	level.zombiemode_using_additionalprimaryweapon_perk = true;
	level.zombiemode_precache_player_model_override = ::precache_player_model_override;
	level.zombiemode_give_player_model_override = ::give_player_model_override;
	level.zombiemode_player_set_viewmodel_override = ::player_set_viewmodel_override;
	level.register_offhand_weapons_for_level_defaults_override = ::register_offhand_weapons_for_level_defaults_override;
	level.zombiemode_offhand_weapon_give_override = ::offhand_weapon_give_override;
	
	level.zombie_anim_override = maps\zombie_ww::anim_override_func;
	level thread maps\_callbacksetup::SetupCallbacks();
	
	level.dog_spawn_func = maps\_zombiemode_ai_dogs::dog_spawn_factory_logic;
	level.exit_level_func = ::zombie_ww_exit_level;
	// Special zombie types, engineer and quads.
	level.dogs_enabled = true;	
	level.mixed_rounds_enabled = 1;//true;
	level.custom_ai_type = [];
	level.custom_ai_type = array_add( level.custom_ai_type, maps\_zombiemode_ai_dogs::init );
	maps\_zombiemode_ai_dogs::enable_dog_rounds();

	level.door_dialog_function = maps\_zombiemode::play_door_dialog;
	level.first_round_spawn_func = true;
	include_weapons();
	include_powerups();
	level.use_zombie_heroes = true;
	level.disable_protips = 1;
	// DO ACTUAL ZOMBIEMODE INIT
	maps\_zombiemode::main();
	// maps\_zombiemode_weap_nesting_dolls::init();
	//maps\_zombiemode_weap_black_hole_bomb::init();
	// maps\_zombiemode_timer::init();
	// Turn off generic battlechatter - Steve G
	battlechatter_off("allies");
	battlechatter_off("axis");

	init_zombie_ww();
	
	// Setup the levels Zombie Zone Volumes
	maps\_compass::setupMiniMap("menu_map_zombie_ww"); 
	//level.ignore_spawner_func = ::zombie_ww_ignore_spawner;
	level.zone_manager_init_func = ::zombie_ww_zone_init;
	init_zones[0] = "start_zone";
	level thread maps\_zombiemode_zone_manager::manage_zones( init_zones );
	
	init_sounds();
	//level thread add_powerups_after_round_1();
	// visionsetnaked( "zombie_ww", 0 );
	visionsetnaked( "mp_berlinwall2", 0 );

	// custom
	level thread maps\_custom_zapper_system::init();
	level thread ray_gun_wallbuy();
}
#using_animtree( "generic_human" );
anim_override_func()
{
	level.scr_anim["zombie"]["walk7"] 	= %ai_zombie_walk_v8;	//goose step walk
}
//*****************************************************************************
theater_playanim( animname )
{
	self UseAnimTree(#animtree);
	self animscripted(animname + "_done", self.origin, self.angles, level.scr_anim[animname],"normal", undefined, 2.0  );
}
//*****************************************************************************
// WEAPON FUNCTIONS
//
// Include the weapons that are only in your level so that the cost/hints are accurate
// Also adds these weapons to the random treasure chest.
// Copy all include_weapon lines over to the level.csc file too - removing the weighting funcs...
//*****************************************************************************
include_weapons()
{	
	include_weapon( "frag_grenade_zm", false, true );
	// include_weapon( "stielhandgranate", false, true );
	include_weapon( "claymore_zm", false, true );
	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm", false );						// 357
	include_weapon( "python_upgraded_zm", false );
  	include_weapon( "cz75_zm" );
  	include_weapon( "cz75_upgraded_zm", false );
	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false, true );							// gewehr43
	include_weapon( "m14_upgraded_zm", false );
	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false, true );						
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );
	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false, true );						// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false, true );
	include_weapon( "mp5k_upgraded_zm", false );
	include_weapon( "mp40_zm", false, true );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "mpl_zm", false, true );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false, true );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );
	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );
	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false, true );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false, true );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm", false );						// 
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm", false );
	include_weapon( "hs10_upgraded_zm", false );
	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm" );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm", false );
	include_weapon( "fnfal_upgraded_zm", false );
	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm", false );					// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm", false );
	include_weapon( "l96a1_upgraded_zm", false );
	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );							// mg42, 30 cal, ppsh
	include_weapon( "rpk_upgraded_zm", false );
	include_weapon( "hk21_zm" );
	include_weapon( "hk21_upgraded_zm", false );
	//	Weapons - Misc
	include_weapon( "m72_law_zm", false );
	include_weapon( "m72_law_upgraded_zm", false );
	//include_weapon( "china_lake_zm" );
	//include_weapon( "china_lake_upgraded_zm", false );
	//	Weapons - Special
	include_weapon( "zombie_cymbal_monkey", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );
	include_weapon( "ray_gun_zm", true, false, maps\_zombiemode_weapons::default_ray_gun_weighting_func );
	// include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "thundergun_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );
	// include_weapon( "thundergun_upgraded_zm", false );
	include_weapon( "tesla_gun_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );
	// include_weapon( "tesla_gun_upgraded_zm", false );
	include_weapon( "blundergat_zm", true, false, maps\_zombiemode_weapons::default_wonder_weapon_weighting_func );

	// Custom weapons
	include_weapon( "ppsh_zm" );
	// include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	// include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	// include_weapon( "ak47_upgraded_zm", false);

	// include_weapon( "zombie_black_hole_bomb" );
	// include_weapon( "zombie_nesting_dolls", true, false, maps\_zombiemode_weapons::default_cymbal_monkey_weighting_func );

	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );
	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
	level._uses_retrievable_ballisitic_knives = true;

	// register weapons 
	// maps\_zombiemode_weapons::add_zombie_weapon( "stielhandgranate", "", 						&"WAW_ZOMBIE_WEAPON_STIELHANDGRANATE_250", 		250,	"grenade", "", 250 );
	// limited weapons
	maps\_zombiemode_weapons::add_limited_weapon( "m1911_zm", 0 );
	maps\_zombiemode_weapons::add_limited_weapon( "thundergun_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "tesla_gun_zm", 1 );
	// maps\_zombiemode_weapons::add_limited_weapon( "zombie_nesting_dolls", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "crossbow_explosive_zm", 1 );
	maps\_zombiemode_weapons::add_limited_weapon( "knife_ballistic_zm", 1 );
	precacheItem( "explosive_bolt_zm" );
	precacheItem( "explosive_bolt_upgraded_zm" );
}
//*****************************************************************************
// POWERUP FUNCTIONS
//*****************************************************************************
include_powerups()
{
	include_powerup( "nuke" );
	include_powerup( "insta_kill" );
	include_powerup( "double_points" );
	include_powerup( "full_ammo" );
	//include_powerup( "carpenter" );
	//include_powerup( "fire_sale" );
}
add_powerups_after_round_1()
{
	
	//want to precache all the stuff for these powerups, but we don't want them to be available in the first round
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "nuke"); 
	level.zombie_powerup_array = array_remove (level.zombie_powerup_array, "fire_sale");
	while (1)
	{
		if (level.round_number > 1)
		{
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "nuke");
			level.zombie_powerup_array = array_add(level.zombie_powerup_array, "fire_sale");
			break;
		}
		wait (1);
	}
}			
//*****************************************************************************
init_zombie_ww()
{
	flag_init( "curtains_done" );
	flag_init( "lobby_occupied" );
	flag_init( "dining_occupied" );
	flag_init( "special_quad_round" );
	level thread electric_switch();		
	level thread teleporter_intro();
}
//*****************************************************************************
teleporter_intro()
{
	flag_wait( "all_players_spawned" );
	wait( 0.25 );
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] SetTransported( 2 );
	}
	
	playsoundatposition( "evt_beam_fx_2d", (0,0,0) );
    playsoundatposition( "evt_pad_cooldown_2d", (0,0,0) );
}
//*****************************************************************************
// ELECTRIC SWITCH
// once this is used, it activates other objects in the map
// and makes them available to use
//*****************************************************************************
electric_switch()
{
	trig = getent("use_elec_switch","targetname");
	trig sethintstring(&"ZOMBIE_ELECTRIC_SWITCH");
	trig setcursorhint( "HINT_NOICON" );
	level thread wait_for_power();
	trig waittill("trigger",user);
	trig delete();	
	flag_set( "power_on" );
	Objective_State(8,"done");
	//Enable quad zombie spawners
	reinit_zone_spawners();
}
//
//	Wait for the power_on flag to be set.  This is needed to work in conjunction with
//		the devgui cheat.
//
wait_for_power()
{
	master_switch = getent("elec_switch","targetname");	
	master_switch notsolid();
	flag_wait( "power_on" );
	master_switch rotateroll(-90,.3);
	master_switch playsound("zmb_switch_flip");
	clientnotify( "ZPO" );		// Zombie power on.
	master_switch waittill("rotatedone");
	playfx(level._effect["switch_sparks"] ,getstruct("elec_switch_fx","targetname").origin);
	
	//Sound - Shawn J  - adding temp sound to looping sparks & turning on power sources
	master_switch playsound("zmb_turn_on");
	//get the teleporter ready
	//maps\zombie_theater_teleporter::teleporter_init();	
	wait_network_frame();
	// Set Perk Machine Notifys
	level notify("revive_on");
	wait_network_frame();
	level notify("juggernog_on");
	wait_network_frame();
	level notify("sleight_on");
	wait_network_frame();
	level notify("doubletap_on");
	wait_network_frame();
	level notify("Pack_A_Punch_on" );	
	wait_network_frame();
	//SE2Dev - Enable additional perks
	level notify("marathon_on" );	
	wait_network_frame();
	level notify("divetonuke_on" );	
	wait_network_frame();
	level notify("deadshot_on" );	
	wait_network_frame();
	level notify("additionalprimaryweapon_on" );	
	wait_network_frame();
	// start quad round
	// Set number of quads per round
	players = get_players();
	level.quads_per_round = 4 * players.size;	// initial setting
	level notify("quad_round_can_end");
	level.delay_spawners = undefined;
	
	// DCS: start check for potential quad waves after power turns on.
	level thread quad_wave_init();
}
//AUDIO
init_sounds()
{
	maps\_zombiemode_utility::add_sound( "wooden_door", "zmb_door_wood_open" );
	maps\_zombiemode_utility::add_sound( "fence_door", "zmb_door_fence_open" );
}
// *****************************************************************************
// Zone management
// *****************************************************************************
zombie_ww_zone_init()
{
	flag_init( "always_on" );
	flag_set( "always_on" );

	add_adjacent_zone( "start_zone", "zone1", "enter_zone1" ); // Spawn to PM63 Porch
	add_adjacent_zone( "start_zone", "zone2", "enter_zone2_from_spawn" ); // Spawn to Power
	add_adjacent_zone( "zone1", "zone2", "enter_zone2_from_zone1" ); // PM63 Porch to Power
	add_adjacent_zone( "zone1", "zone3", "enter_zone3" ); // PM63 Porch to Courtyard
	add_adjacent_zone( "zone4", "zone5", "enter_zone5" ); // Speed Floor to Jug Floor
	add_adjacent_zone( "zone5", "zone4", "enter_zone4" ); // Jug Floor to Speed Floor

	if(getdvarInt("first_room_power") == 1 && getdvar("gamemode") == "first_room")
	{
		// activate power zone
		zone_init( "zone2");
		enable_zone( "zone2");
	}
}	
zombie_ww_ignore_spawner( spawner )
{
	// no power, no quads
	if ( !flag("power_on") )
	{
		if ( spawner.script_noteworthy == "quad_zombie_spawner" )
		{
			return true;
		}
	}
	return false;
}
// *****************************************************************************
// 	DCS: random round change quad emphasis
// 	This should only happen in zones where quads spawn into
// 	and crawl down the wall.
//	potential zones: foyer_zone, theater_zone, stage_zone, dining_zone
// *****************************************************************************
quad_wave_init()
{
	level thread time_for_quad_wave("foyer_zone");
	level thread time_for_quad_wave("theater_zone");
	level thread time_for_quad_wave("stage_zone");
	level thread time_for_quad_wave("dining_zone");
	
	level waittill( "end_of_round" );
	flag_clear( "special_quad_round" );	
}
time_for_quad_wave(zone_name)
{
	if(!IsDefined(zone_name))
	{
		return;
	}
	zone = level.zones[ zone_name ];
	//	wait for round change.
	level waittill( "between_round_over" );
	
	//avoid dog rounds.
	if ( IsDefined( level.next_dog_round ) && level.next_dog_round == level.round_number )
	{
		level thread time_for_quad_wave(zone_name);			
		return;
	}	
	// ripped from spawn script for accuracy.	-------------------------------------
	max = level.zombie_vars["zombie_max_ai"];
	multiplier = level.round_number / 5;
	if( multiplier < 1 )
	{
		multiplier = 1;
	}
	if( level.round_number >= 10 )
	{
		multiplier *= level.round_number * 0.15;
	}
	player_num = get_players().size;
	if( player_num == 1 )
	{
		max += int( ( 0.5 * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}
	else
	{
		max += int( ( ( player_num - 1 ) * level.zombie_vars["zombie_ai_per_player"] ) * multiplier ); 
	}
	// ripped from spawn script for accuracy.	-------------------------------------
	//percent chance.
	chance = 100;
	max_zombies = [[ level.max_zombie_func ]]( max );
	current_round = level.round_number;
	
	// every third round a chance of a quad wave.
	if((level.round_number % 3 == 0) && chance >= RandomInt(100))
	{	
		if(zone.is_occupied)
		{
			flag_set( "special_quad_round" );
			maps\_zombiemode_zone_manager::reinit_zone_spawners();
			while( level.zombie_total < max_zombies /2 && current_round == level.round_number )
			{
				wait(0.1);
			}
			//level waittill( "end_of_round" );
			flag_clear( "special_quad_round" );
			maps\_zombiemode_zone_manager::reinit_zone_spawners();
			
		}
	}
	level thread time_for_quad_wave(zone_name);
}
zombie_ww_exit_level()
{
	zombies = GetAiArray( "axis" );
	for ( i = 0; i < zombies.size; i++ )
	{
		zombies[i] thread zombie_ww_find_exit_point();
	}
}
zombie_ww_find_exit_point()
{
	self endon( "death" );
	player = getplayers()[0];
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;
	away = VectorNormalize( self.origin - player.origin );
	endPos = self.origin + vector_scale( away, 600 );
	locs = array_randomize( level.enemy_dog_locations );
	for ( i = 0; i < locs.size; i++ )
	{
		dist_zombie = DistanceSquared( locs[i].origin, endPos );
		dist_player = DistanceSquared( locs[i].origin, player.origin );
		if ( dist_zombie < dist_player )
		{
			dest = i;
			break;
		}
	}
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self setgoalpos( locs[dest].origin );
	while ( 1 )
	{
		if ( !flag( "wait_and_revive" ) )
		{
			break;
		}
		wait_network_frame();
	}
	
	self thread maps\_zombiemode_spawner::find_flesh();
}
precache_player_model_override()
{
	mptype\player_t5_zm_theater::precache();
}
give_player_model_override( entity_num )
{
	if( IsDefined( self.zm_random_char ) )
	{
		entity_num = self.zm_random_char;
	}
	switch( entity_num )
	{
		case 0:
			character\c_usa_dempsey_zt::main();// Dempsy
			break;
		case 1:
			character\c_rus_nikolai_zt::main();// Nikolai
			break;
		case 2:
			character\c_jap_takeo_zt::main();// Takeo
			break;
		case 3:
			character\c_ger_richtofen_zt::main();// Richtofen
			break;	
	}
}
player_set_viewmodel_override( entity_num )
{
	switch( self.entity_num )
	{
		case 0:
			// Dempsey
			self SetViewModel( "viewmodel_usa_pow_arms" );
			break;
		case 1:
			// Nikolai
			self SetViewModel( "viewmodel_rus_prisoner_arms" );
			break;
		case 2:
			// Takeo
			self SetViewModel( "viewmodel_vtn_nva_standard_arms" );
			break;
		case 3:
			// Richtofen
			self SetViewModel( "viewmodel_usa_hazmat_arms" );
			break;		
	}
}
register_offhand_weapons_for_level_defaults_override()
{
	// register_lethal_grenade_for_level( "stielhandgranate" );
	register_lethal_grenade_for_level( "frag_grenade_zm" );
	level.zombie_lethal_grenade_player_init = "frag_grenade_zm";

	register_tactical_grenade_for_level( "zombie_cymbal_monkey" );
	// register_tactical_grenade_for_level( "zombie_nesting_dolls" );
	level.zombie_tactical_grenade_player_init = undefined;

	// register_placeable_mine_for_level( "mine_bouncing_betty" );
	register_placeable_mine_for_level( "claymore_zm" );
	level.zombie_placeable_mine_player_init = undefined;

	register_melee_weapon_for_level( "knife_zm" );
	register_melee_weapon_for_level( "bowie_knife_zm" );
	level.zombie_melee_weapon_player_init = "knife_zm";
}

// -- gives the player a black hole bomb when it comes out of the box
offhand_weapon_give_override( str_weapon )
{
	self endon( "death" );
	
	if( is_tactical_grenade( str_weapon ) && IsDefined( self get_player_tactical_grenade() ) && !self is_player_tactical_grenade( str_weapon ) )
	{
		self SetWeaponAmmoClip( self get_player_tactical_grenade(), 0 );
		self TakeWeapon( self get_player_tactical_grenade() );
	}
	
	if( str_weapon == "zombie_nesting_dolls" )
	{
		self maps\_zombiemode_weap_nesting_dolls::player_give_nesting_dolls();
		//self maps\_zombiemode_weapons::play_weapon_vo( str_weapon ); // ww: need to figure out how we will get the sound here
		return true;
	}
	
	if( str_weapon == "zombie_cymbal_monkey" )
	{
		self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
		//self maps\_zombiemode_weapons::play_weapon_vo( str_weapon ); // ww: need to figure out how we will get the sound here
		return true;
	}

	return false;
}

ray_gun_wallbuy()
{
	trigger = getent("ray_gun_wallbuy", "targetname");
	trigger SetCursorHint( "HINT_NOICON" );
	trigger UseTriggerRequireLookAt();
	trigger setHintString("Hold ^3[{+activate}]^7 for Ray Gun [15000]");

	cost = 15000;
	ammo_cost = 15000;
	zombie_weapon_upgrade = "ray_gun_zm";

	while (1)
	{
		wait(0.5);

		trigger waittill( "trigger", player);

		if( !player maps\_zombiemode_weapons::can_buy_weapon() )
		{
			wait( 0.1 );
			continue;
		}

		// Allow people to get ammo off the wall for upgraded weapons
		player_has_weapon = player maps\_zombiemode_weapons::has_weapon_or_upgrade( zombie_weapon_upgrade );

		if( !player_has_weapon )
		{
			// else make the weapon show and give it
			if( player.score >= cost )
			{
				player maps\_zombiemode_score::minus_to_player_score( cost );
				player maps\_zombiemode_weapons::weapon_give( zombie_weapon_upgrade );
				playsoundatposition("mus_wonder_weapon_stinger", (0,0,0));
			}
			else
			{
				trigger play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 1 );

			}
		}
		else
		{
			// if the player does have this then give him ammo.
			if( player.score >= ammo_cost )
			{
				ammo_given = player maps\_zombiemode_weapons::ammo_give( zombie_weapon_upgrade );
				if( ammo_given )
				{
						player maps\_zombiemode_score::minus_to_player_score( ammo_cost ); // this give him ammo to early
				}
			}
			else
			{
				trigger play_sound_on_ent( "no_purchase" );
				player maps\_zombiemode_audio::create_and_play_dialog( "general", "no_money", undefined, 0 );
			}
		}
	}
}
