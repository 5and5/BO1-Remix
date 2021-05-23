#include clientscripts\_utility;
#include clientscripts\_music;
#include clientscripts\_zombiemode_weapons;
#include clientscripts\_filter;

main()
{
	level._uses_crossbow = true;
	level.use_freezegun_features = true;
	level.uses_tesla_powerup = true;
	
	//for clientsiding the risers
	level.riser_fx_on_client  = 1;
	level.riser_type = "snow";
	level.use_new_riser_water = 1;
	level.use_clientside_rock_tearin_fx = 1;
	level.use_clientside_board_fx = 1;
	
	
	// WW (02-17-11): Vision set
	// Special human gun visionsets are defined in the _zombiemode_weap_humangun::init();
	// Human gun uses priority 8 & 9. Black hole bomb uses priority 10
	level._coast_vision_set = "zombie_coast_2";
	level._coast_vision_set_priority = 1;
	
	// Visionset for "lighthouse_on" transition
	
	level._coast_power_burst_vision_set = "zombie_coast_powerOn";
	level._coast_power_burst_vision_set_priority = 5;
	
	level._coast_blizzard_vision_set = "zombie_coast_lighthouse";
	level._coast_blizzard_vision_set_priority = 2;
	
	level._coast_lighthouse_freak_out_set = "zombie_coast_rovingEye";
	level._coast_lighthouse_freak_out_set_priority = 7;
	
	//init the player zipline 
	clientscripts\zombie_coast_player_zipline::init_player_zipline_anims();
	clientscripts\zombie_coast_flinger::init_player_flinger_anims();

	init_clientflag_variables();
	include_weapons();

	PrecacheRumble( "explosion_generic" );

	// _load!
	clientscripts\_zombiemode::main();

	register_clientflag_callbacks();
	
	clientscripts\zombie_coast_fx::main();
	
	thread clientscripts\zombie_coast_amb::main();

	clientscripts\_zombiemode_deathcard::init();

	clientscripts\_sticky_grenade::main();
	clientscripts\_zombiemode_weap_humangun::init();
	clientscripts\_zombiemode_weap_sniper_explosive::init();

	clientscripts\_zombiemode_ai_director::init();

	register_zombie_types();

	level thread clientscripts\_zombiemode::register_sidequest( 43, 44 );
	
	// on player connect
	OnPlayerConnect_Callback( ::coast_player_connect );
	
	// on player spawn run this function
	OnPlayerSpawned_Callback( ::coast_player_spawned );
	
	// This needs to be called after all systems have been registered.
	thread waitforclient(0);
	
	// listens for power
	level thread coast_ZPO_listener();
	
	clientscripts\zombie_coast_lighthouse::main();
	
	// lighthouse morse code
	level thread solaris_flash();
	
	//vision set changes when fog rolls in /out
	level thread fog_visionset_handler();
	
	level thread setup_fx_anims();
	
}
/*------------------------------------
setup the variables for use with clientflags
------------------------------------*/
init_clientflag_variables()
{
	level._CF_PLAYER_ZIPLINE_RUMBLE_QUAKE = 0;
	level._CF_PLAYER_ZIPLINE_FAKE_PLAYER_SETUP = 1;

	
	level._COAST_FOG_BLIZZARD = 2;
	level._CF_PLAYER_FLINGER_FAKE_PLAYER_SETUP_PRONE =3;
	level._CF_PLAYER_FLINGER_FAKE_PLAYER_SETUP_STAND =4;
	
	// WW: Player flag for water frost
	level._CF_PLAYER_WATER_FROST = 5;
	level._CF_PLAYER_WATER_FREEZE = 6;
	level._CF_PLAYER_WATER_FROST_REMOVE = 7; // Forcibly remove the frost at spectator

	level._CF_PLAYER_ELECTRIFIED = 8;	// Player hit by director or electric zombie

	level._ZOMBIE_ACTOR_FLAG_ELECTRIFIED = 2;	// 1 is being used for facial anim...might be able to remove it
	level._ZOMBIE_ACTOR_FLAG_DIRECTOR_LIGHT = 3;	// controls the prop light fx
	level._ZOMBIE_ACTOR_FLAG_DIRECTORS_STEPS = 4; // proper footsteps for the director
	level._ZOMBIE_ACTOR_FLAG_DIRECTOR_DEATH = 5;	// controls the "death" fx
	level._ZOMBIE_ACTOR_FLAG_LAUNCH_RAGDOLL = 0;
}

register_clientflag_callbacks()
{
	//zipline rumble quake
	register_clientflag_callback("player", level._CF_PLAYER_ZIPLINE_RUMBLE_QUAKE , clientscripts\zombie_coast_player_zipline::zipline_rumble_and_quake);
	register_clientflag_callback("player",level._CF_PLAYER_ZIPLINE_FAKE_PLAYER_SETUP, clientscripts\zombie_coast_player_zipline::zipline_player_setup);
	register_clientflag_callback("player",level._CF_PLAYER_FLINGER_FAKE_PLAYER_SETUP_PRONE, clientscripts\zombie_coast_flinger::flinger_player_setup_prone);
	register_clientflag_callback("player",level._CF_PLAYER_FLINGER_FAKE_PLAYER_SETUP_STAND, clientscripts\zombie_coast_flinger::flinger_player_setup_stand);
	

	register_clientflag_callback("player", level._COAST_FOG_BLIZZARD , clientscripts\zombie_coast_fx::coast_fog_blizzard);
	
	// coastal water frost
	register_clientflag_callback( "player", level._CF_PLAYER_WATER_FROST, ::coast_water_frost );
	register_clientflag_callback( "player", level._CF_PLAYER_WATER_FREEZE, ::coast_water_freeze );
	register_clientflag_callback( "player", level._CF_PLAYER_WATER_FROST_REMOVE, ::coast_water_frost_remove );

	register_clientflag_callback( "player",level._CF_PLAYER_ELECTRIFIED, ::coast_player_electrified);

	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_ELECTRIFIED, ::coast_zombie_electrified );
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_DIRECTOR_LIGHT, clientscripts\_zombiemode_ai_director::zombie_director_light_update);
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_DIRECTORS_STEPS, ::director_footsteps );
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_DIRECTOR_DEATH, clientscripts\_zombiemode_ai_director::zombie_director_death);
	
	register_clientflag_callback( "actor", level._ZOMBIE_ACTOR_FLAG_LAUNCH_RAGDOLL, clientscripts\zombie_coast_flinger::launch_zombie);


}

//------------------------------------------------------------------------------
register_zombie_types()
{
	//character\clientscripts\c_zom_cosmo_spetznaz::register_gibs();
	//character\clientscripts\c_zom_cosmo_scientist::register_gibs();
	//character\clientscripts\c_zom_cosmo_cosmonaut::register_gibs();
	character\clientscripts\c_zom_soldier::register_gibs();
	character\clientscripts\c_zom_scuba::register_gibs();
	character\clientscripts\c_zom_barechest::register_gibs();
}

include_weapons()
{
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "sticky_grenade_zm", false, true );
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
	include_weapon( "mpl_zm", false, true );
	include_weapon( "mpl_upgraded_zm", false );
	include_weapon( "pm63_zm", false, true );
	include_weapon( "pm63_upgraded_zm", false );
	include_weapon( "spectre_zm" );
	include_weapon( "spectre_upgraded_zm", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );

	//	Weapons - Dual Wield
  	include_weapon( "cz75dw_zm" );
  	include_weapon( "cz75dw_upgraded_zm", false );

	//	Weapons - Shotguns
	include_weapon( "ithaca_zm", false );						// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false);
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
	include_weapon( "fnfal_zm" );
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
	include_weapon( "m72_law_zm", false);
	include_weapon( "m72_law_upgraded_zm", false );
	include_weapon( "china_lake_zm", false );
	include_weapon( "china_lake_upgraded_zm", false );

	//	Weapons - Special
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );

	include_weapon( "humangun_zm" );
	include_weapon( "humangun_upgraded_zm", false );
	include_weapon( "sniper_explosive_zm" );
	include_weapon( "sniper_explosive_upgraded_zm", false );
	include_weapon( "zombie_nesting_dolls" );

	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );
}

disable_deadshot( i_local_client_num )
{
	// Wait until all the rendered objects are setup
	while ( !self hasdobj( i_local_client_num ) )
	{
		wait( 0.05 );
	}
	
	players = GetLocalPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( self == players[i] )
		{
			self clearalternateaimparams();
		}
	}
}

spectator_monitor(lcn)
{
	self endon("disconnect");
	
	en = self GetEntityNumber();
	
	while(1)
	{
		if(en != self GetEntityNumber())
		{
			IPrintLnBold("Spectator change?");
			level notify("spectator_change", lcn);
			en = self GetEntityNumber();
		}
		
		wait(0.1);
	}
}

// WW (02-17-11): Stuff that needs to run on the player at connect.
coast_player_connect( i_local_client_num )
{
	self endon( "disconnect" );
	
	// make sure the client has a snapshot from the server before continuing
	while( !ClientHasSnapshot( i_local_client_num ) )
	{
		wait( 0.05 );
	}

	self thread power_on_burst(i_local_client_num);
//	self thread spectator_monitor(i_local_client_num);

	// only client 0 works on this part
	if( i_local_client_num != 0 )
	{
		return;
	}
	
	self thread disable_deadshot( i_local_client_num );
	
	// flare effect
	self thread flare_effects( i_local_client_num );
	
	// run any functions on all the local players from the first local player
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] notify("stop_sunlight_flashing");		
		players[i] clientscripts\_zombiemode::zombie_vision_set_remove( level._coast_power_burst_vision_set, 0, i );

		players[i] thread coast_set_visionset( i );
		
		players[i] thread coast_reset_frost();

		players[i] thread clientscripts\_zombiemode_ai_director::zombie_director_aggro();
	}

	ResetSunlight();
	
}

// WW (02-17-11): Stuff that needs to run on the player at spawn.
coast_player_spawned( i_local_client_num )
{
	self endon( "disconnect" );
		
	// Wait until all the rendered objects are setup
	while ( !self hasdobj( i_local_client_num ) )
	{
		wait( 0.05 );
	}
	
//	self clear_frost_overlay();


	// only client 0 works on this part
	if( i_local_client_num != 0 )
	{
		return;
	}
	
	if ( !IsDefined( level.fog_triggers_active ) )
	{
		level.fog_triggers_active = [];
	}
	
	// run any functions on all the local players from the first local player
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread coast_set_visionset( i );
		
//		players[i] thread coast_reset_frost();
		
		if(!IsDefined(level.fog_triggers_active[i]))
		{
			if(i == 0)
			{
				players[i] thread clientscripts\zombie_coast_fx::coast_fog_triggers_init(i);
			}
			level.fog_triggers_active[i] = true;
		}

		players[i] thread clientscripts\_zombiemode_ai_director::zombie_director_aggro();
	}	
}

coast_reset_frost()
{
	self endon( "disconnect" );
	
//	PrintLn("C: coast reset frost " + self GetEntityNumber() );

	
	init_filter_frost( self );

	self._frost_opacity = 0.0;

	enable_filter_frost( self, 0, self._frost_opacity );

	set_filter_frost_opacity( self, 0, self._frost_opacity ); // remove frost filter from player

	disable_filter_frost( self, 0 );

	init_filter_frost( self );
}

// -------------------------------------------------------------------------------------------------------------
// controls the visionset for players
// -------------------------------------------------------------------------------------------------------------
coast_set_visionset( i_local_client_num )
{
	self endon( "disconnect" );
	
	// level waittill( "ZID" );
	
	self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._coast_vision_set, level._coast_vision_set_priority, 0.1, i_local_client_num );
}


// -------------------------------------------------------------------------------------------------------------
// controls the frost on the player
// -------------------------------------------------------------------------------------------------------------
coast_water_frost( local_client_num, set, newEnt )
{
	// this should only run on the player that is in the water, the other split screen player should fall out of this
	player = GetLocalPlayers()[ local_client_num ];
	if( player GetEntityNumber() != self GetEntityNumber() )
	{
		return;	// only do this for the player in the water
	}
	
	if(self IsSpectating())
	{
		return;	// Dont set frost overlays on spectating players.
	}

	if(IsDefined(newEnt) && newEnt)
	{
		return;
	}

	if( set )
	{
//		PrintLn("C: coast water frost set " + self GetEntityNumber() );

		self notify( "frost_invade" );
		self thread coast_water_frost_invade();
	}
	else
	{
//		PrintLn("C: coast water frost clear " + self GetEntityNumber() );

		self notify( "frost_retreat" );
		self thread coast_water_frost_retreat();
	}
	
}

clear_frost_overlay()
{
	self._frost_opacity = 0.0;	// Reset frost opacity...
	self notify("frost_invade");
	self notify("frost_retreat");	// Get rid of any visionset scripts that might still be running on the player.

//	PrintLn("C: Clear frost overlay " + self GetEntityNumber() );


	disable_filter_frost( self, 0 );
}

// -- This controls the frost on the player's screen
coast_water_frost_invade()
{
	self endon( "frost_retreat" );
	
	if( !IsDefined( self._frost_opacity ) )
	{
		self._frost_opacity = 0.0;
	}
	
	start_opacity = 0.0;
	final_opacity = 1.0; 
	time_to_max = 30000;
	self._frost_curr_time = 0;
	
	startTime = GetRealTime();
	nextTime = GetRealTime();
	
	if( self._frost_opacity > 0 )
	{
		self._frost_curr_time = self._frost_opacity * time_to_max;
	}
	
	init_filter_frost( self );

	// turn on the filter
	enable_filter_frost( self, 0, self._frost_opacity );
	
	// loop up to the frost overlay max
	while( 1 )
	{
		if(!IsDefined(self))	// Player torn down
		{
			return;
		}
		
		diff = nextTime - startTime;
		
		self._frost_opacity = self._frost_curr_time / time_to_max; 
		
		if( self._frost_opacity < start_opacity )
		{
			self._frost_opacity = start_opacity;
		}
		if( self._frost_opacity > final_opacity )
		{
			self._frost_opacity = final_opacity;
		}
		
		self._frost_curr_time += diff;
		//PrintLn( "OPACITY: " + self._frost_opacity );
		set_filter_frost_opacity( self, 0, self._frost_opacity );
		
		startTime = GetRealTime();
		wait( 0.1 );
		nextTime = GetRealTime();
	}
}

coast_water_frost_retreat()
{
	self endon( "frost_invade" );
	
	// this should eliminate bunny hopping causing the overlay to pop in and out
	wait( 0.5 );
	
	time_to_max = 30000;
	
	startTime = GetRealTime();
	nextTime = GetRealTime();
	
	if( !IsDefined( self._frost_opacity ) )
	{
		self._frost_opacity = 0.5;
	}
	opacity = 0.5;
	inc = 0.01;
	
	while( self._frost_opacity > 0 )
	{
		diff = nextTime - startTime;
		
		self._frost_opacity = self._frost_curr_time / time_to_max; 
		
		self._frost_curr_time -= diff;
		//PrintLn( "&&&& OPACITY: " + self._frost_opacity );
		set_filter_frost_opacity( self, 0, self._frost_opacity );
		startTime = GetRealTime();
		wait( 0.1 );
		nextTime = GetRealTime();
		
		if( self._frost_opacity <= 0 )
		{
			break;
		}
	}
	
	// remove frost filter from player
	disable_filter_frost( self, 0 );
}

coast_water_frost_remove( local_client_num, set, newEnt )
{
	player = GetLocalPlayers()[ local_client_num ];
	if( player GetEntityNumber() != self GetEntityNumber() )
	{
		return;	// only do this for the player in the water
	}
	
	if(self IsSpectating())
	{
		return;	// Dont set frost overlays on spectating players.
	}	
	
	
	if( set )
	{
//		PrintLn("C: water frost remove " + self GetEntityNumber() );
		self notify("frost_retreat");
		self._frost_opacity = 0;
		disable_filter_frost( self, 0 );
	}
}

// -------------------------------------------------------------------------------------------------------------
// controls the freeze fx on the player
// -------------------------------------------------------------------------------------------------------------
coast_water_freeze( local_client_num, set, newEnt )
{
	if ( local_client_num != 0 )
	{
		return;
	}

	if( set )
	{
		players = getlocalplayers();
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];
			if ( player GetEntityNumber() != self GetEntityNumber() )
			{
				self coast_water_play_all_torso_damage_fx( i );
			}
		}
	}
	else
	{
		players = getlocalplayers();
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			self coast_water_end_all_torso_damage_fx( i );
			if ( player GetEntityNumber() != self GetEntityNumber() )
			{
				PlayFX( i, level._effect[ "freezegun_shatter" ], self.origin );
				PlaySound( 0, "wpn_freezegun_shatter_zombie", self.origin );
			}
			else if( player GetEntityNumber() == self GetEntityNumber() )
			{
				players[i]._frost_curr_time = 0;
			}
		}
	}
}

coast_water_end_all_torso_damage_fx( localclientnum )
{
	entnum = self GetEntityNumber();
	if ( isdefined( level.freezegun_damage_torso_fx ) && isdefined( level.freezegun_damage_torso_fx[localclientnum] ) && isdefined( level.freezegun_damage_torso_fx[localclientnum][entNum] ) )
	{
		deletefx( localclientnum, level.freezegun_damage_torso_fx[localclientnum][entNum], true );
		level.freezegun_damage_torso_fx[localclientnum][entNum] = undefined;
	}
}


coast_water_play_all_torso_damage_fx( localclientnum )
{
	if ( !IsDefined( level.freezegun_damage_torso_fx ) )
	{
		level.freezegun_damage_torso_fx = [];
	}
	if ( !IsDefined( level.freezegun_damage_torso_fx[localClientNum] ) )
	{
		level.freezegun_damage_torso_fx[localClientNum] = [];
	}

	entnum = self GetEntityNumber();
	if ( IsDefined( level.freezegun_damage_torso_fx[localclientnum][entNum] ) )
	{
		return;
	}
	
	level.freezegun_damage_torso_fx[localclientnum][entNum] = PlayFxOnTag( localclientnum, level._effect[ "waterfreeze" ], self, "tag_origin" );
}

// -------------------------------------------------------------------------------------------------------------
// player fx when hit by director or electric zombie
// -------------------------------------------------------------------------------------------------------------
coast_player_play_electric_fx( localclientnum )
{
	if ( !IsDefined( level.player_electric_fx ) )
	{
		level.player_electric_fx = [];
	}

	if ( IsDefined( level.player_electric_fx[ localclientnum ] ) )
	{
		return;
	}

	level.player_electric_fx[ localclientnum ] = PlayFxOnTag( localclientnum, level._effect[ "buff_electrified" ], self, "J_SpineLower" );
}

coast_player_end_electric_fx( localclientnum )
{
	if(IsDefined(level.player_electric_fx[ localclientnum ]))
	{
		deletefx( localclientnum, level.player_electric_fx[ localclientnum ], true );
		level.player_electric_fx[ localclientnum ] = undefined;
	}
}

coast_player_electrified( local_client_num, set, newEnt )
{
	if ( local_client_num != 0 )
	{
		return;
	}
	
	player = GetLocalPlayers()[ local_client_num ];

	if( set )
	{
		players = getlocalplayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( player GetEntityNumber() != self GetEntityNumber() )
			{
				//println( "**************** player electrified " + i );
				coast_player_play_electric_fx( i );
			}
			else
			{
				self PlayRumbleOnEntity( local_client_num, "explosion_generic" );
			}
		}
	}
	else
	{
		players = getlocalplayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( player GetEntityNumber() != self GetEntityNumber() )
			{
				coast_player_end_electric_fx( i );
			}
		}
	}
}

// -------------------------------------------------------------------------------------------------------------
// play electric fx when zombies are buffed
// -------------------------------------------------------------------------------------------------------------
coast_zombie_electrified( local_client_num, int_set, actor_new )
{
	self endon( "death" );
	self endon( "entityshutdown" );

	if ( local_client_num != 0 )
	{
		return;
	}

	players = GetLocalPlayers();
	ent_num = self GetEntityNumber();

	for( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( !IsDefined( player._zombie_elec_fx ) )
		{
			player._zombie_elec_fx = [];
		}

		if ( IsDefined( player._zombie_elec_fx[ent_num] ) )
		{
			DeleteFx( i, player._zombie_elec_fx[ent_num] );
			player._zombie_elec_fx[ent_num] = undefined;
		}

		if ( int_set )
		{
			player._zombie_elec_fx[ent_num] = PlayFXOnTag( i, level._effect[ "buff_electrified" ], self, "J_SpineLower" );
		}
	}
}

// -------------------------------------------------------------------------------------------------------------
// waits for power to be hit, anything that needs to start at that point should go here
// -------------------------------------------------------------------------------------------------------------
// fires off threads after power is hit
coast_ZPO_listener()
{
	while( 1 )
	{
		level waittill( "ZPO" );
		level._power_on = true;
		
		players = GetLocalPlayers();
		for( i = 0; i < players.size; i++ )
		{
			players[i] thread coast_power_on();
		}
	}
}


// -------------------------------------------------------------------------------------------------------------
// world reaction for the power being turned on
// -------------------------------------------------------------------------------------------------------------
coast_power_on()
{
	self endon( "disconnect" );
	
	if(!isDefined(self GetLocalClientNumber()))
	{
		return;
	}
	
	// in split screen only the main player should do this or it will happen twice
	if( self GetLocalClientNumber() != 0 )
	{
		return;
	}
	
	// set the vision set on the players for the kit
	
	level notify("power_on_burst");
	
	// change around the sun direction
	level coast_sun_light_flashes(self);
		
}

power_on_burst(lcn)
{
	self endon("disconnect");
	
//	lcn = self getlocalclientnumber();
//		int_client_num = playeRs[i] GetLocalClientNumber();
	while(1)
	{
		level waittill("power_on_burst");
		self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._coast_power_burst_vision_set, level._coast_power_burst_vision_set_priority, 0.1, lcn);
		wait( 0.1 );
		self thread clientscripts\_zombiemode::zombie_vision_set_remove( level._coast_power_burst_vision_set, 6.0, lcn );
	}
}

// -------------------------------------------------------------------------------------------------------------
// flickers the sun light to show the power has been turned on
// -------------------------------------------------------------------------------------------------------------
coast_sun_light_flashes(player)
{
	player endon("entityshutdown");
	player endon("stop_sunlight_flashing");
	
	SetSunLight( .6, .6, .6 ); 
	wait(.05);
	
              
	SetSunLight( .8, .8, .8 );
	wait(0.1);
	

	SetSunLight( .4, .4, .4 );
	wait(0.05);
	
	
	SetSunLight( .7, .7, .7 );
	wait(0.1);
	
	
	SetSunLight( 2, 2, 2 ); 
	wait(0.15);
	
	SetSunLight( 1.5, 1.5, 1.5 ); 
	wait(0.2);
	
             
	SetSunLight( .7, .7, .7 );
	wait(0.1);
	

	SetSunLight( 2, 2, 2);
	wait(0.2);
	
	
	SetSunLight( 1, 1, 1 );
	wait(0.1);
	

	SetSunLight( 2, 2, 2 ); 
	wait(0.05);
	
	SetSunLight( .7, .7, .7 );
	wait(0.1);
	
	
	SetSunLight( 2.2, 2.2, 2.2 ); 
	wait(0.15);
	
	
	SetSunLight( 2, 2, 2 ); 
	wait(0.05);
	
             
	SetSunLight( 1, 1, 1 );
	wait(0.05);
	

	SetSunLight( 1.2, 1.2, 1.2 );
	wait(0.1);
	
	
	SetSunLight( 1.5, 1.5, 1.5 );
	wait(0.15);
	

	SetSunLight( 1, 1, 1 ); 
	wait(0.1);
	
	             
	SetSunLight( .8,.8, .8 );
	wait(0.05);
	

	SetSunLight( .4, .4, .4 );
	wait(0.1);
	
	SetSunLight( 1.2, 1.2, 1.2 ); 
	wait(0.1);
	
	             
	SetSunLight( 2, 2, 2 );
	wait(0.7);
	

	SetSunLight( .4, .4, .4 );
	wait(0.1);
	
	
	SetSunLight( .5, .5, .5 );
	wait(0.3);
	

	SetSunLight( .3, .3, .3 ); 
	wait(0.1);
	
	// reset sun light
	ResetSunlight();
}

// -------------------------------------------------------------------------------------------------------------
// distant lighthouse message
// -------------------------------------------------------------------------------------------------------------
// build the code
flash_setup()
{
	message = [];
	
	message[0] = [];
	message[0] = array( 0, 1, 0, 0 );
	
	message[1] = [];
	message[1] = array( 0 );

	message[2] = [];
	message[2] = array( 0, 0, 1, 0 );
	
	message[3] = [];
	message[3] = array( 1 );
	
	message[4] = "Hyena";

	message[5] = [];
	message[5] = array( 0, 0, 0 );

	message[6] = [];
	message[6] = array( 0, 1, 0, 0 );

	message[7] = [];
	message[7] = array( 1, 1, 1 );

	message[8] = [];
	message[8] = array( 0, 1, 1 );

	message[9] = "Dog";

	message[10] = [];
	message[10] = array( 1, 1, 0, 0, 1, 1 );

	message[11] = "Sam";
	
	message[12] = [];
	message[12] = array( 0, 1, 0 );

	message[13] = [];
	message[13] = array( 0, 0 );

	message[14] = [];
	message[14] = array( 1, 1, 0 );

	message[15] = [];
	message[15] = array( 0, 0, 0, 0 );
	
	message[16] = [];
	message[16] = array( 1 );
	
	message[17] = "Thief";
	
	message[18] = [];
	message[18] = array( 0, 0, 1, 0 );
	
	message[19] = [];
	message[19] = array( 0, 0, 1 );
	
	message[20] = [];
	message[20] = array( 0, 1, 0, 0 );
	
	message[21] = [];
	message[21] = array( 0, 1, 0, 0 );
	
	message[22] = "Director";
	
	message[23] = [];
	message[23] = array( 1, 1, 0, 0, 1, 1 );	

	message[24] = "Cheaters";
	
	message[25] = [];
	message[25] = array( 0, 0, 1, 1, 1 );
	
	message[26] = "Never";
	
	message[27] = [];
	message[27] = array( 0, 1, 0 );
	
	message[28] = [];
	message[28] = array( 0, 0 );
	
	message[29] = [];
	message[29] = array( 1, 1, 0 );
	
	message[30] = [];
	message[30] = array( 0, 0, 0, 0 );
	
	message[31] = [];
	message[31] = array( 1 );
	
	message[32] = "Prosper";
	
	message[33] = [];
	message[33] = array( 0, 1, 0, 1, 0, 1 );
	
	return message;
	
}


solaris_flash()
{
	level endon( "slc" ); // Stop Lighthouse Code
	
	// objects
	light_struct = getstruct( "struct_musical_chairs_lighthouse", "targetname" );
	level._light_message = 0;
	light_fx_spot = undefined;
	if( !IsDefined( light_struct ) )
	{
		return;
	}
	
	level thread stop_muscial_chair_message( level._light_message );
	
	message = flash_setup();
	
	level waittill( "lmc" ); // Lighthouse Morse Code
	
	while( level._light_message == 0 )
	{
		// loop through the message
		for( i = 0; i < message.size; i++ ) 
		{
			
			if( IsArray( message[i] ) )
			{
				for( j = 0; j < message[i].size; j++ )
				{
					players = GetLocalPlayers();
					for( k = 0; k < players.size; k++ ) // make sure it shows up for both players in split screen
					{
						if(!players[k] IsSpectating())
						{
							players[k] solaris_ball( k, light_struct.origin );
						}
						
						//light_fx_spot = Spawn( k, light_struct.origin, "script_model" );
						//light_fx_spot SetModel( "tag_origin" );
						//PlayFXOnTag( k, level._effect[ "lighthouse_morse_code" ], light_fx_spot, "tag_origin" );
					}

					if( message[i][j] == 0 )
					{
						players = GetLocalPlayers();
						for( m = 0; m < players.size; m++ )
						{
							if(!players[m] isspectating())
							{
								players[m] thread solaris_howl( m, message[i][j] );
							}
						}
						// light_fx_spot PlaySound( 0, "zmb_beepbadoopbadeep" );
						wait( 0.2 );
					}
					else if( message[i][j] == 1 )
					{
						players = GetLocalPlayers();
						for( n = 0; n < players.size; n++ )
						{
							if(!players[n] IsSpectating())
							{
								players[n] thread solaris_howl( n, message[i][j] );
							}
						}
						// light_fx_spot PlaySound( 0, "zmb_beepbadeepbadoop" );
						wait( 0.6 );
					}
					
					players = GetLocalPlayers();
					for( l = 0; l < players.size; l++ )
					{
						// light_fx_spot Delete();
						if(!players[l] IsSpectating())
						{
							players[l] solaris_destroy();
						}
					}
					
					wait( 0.2 );
					
				}
				
				wait( 0.6 );
			}
			else
			{
				wait( 1.4 );
			}
			
		}
	}
}

solaris_ball( localClientNum, vec_origin )
{
	if( !IsDefined( self._fx_array ) )
	{
		self._fx_array = [];
	}
	
	temp_spot = Spawn( localClientNum, vec_origin, "script_model" );
	temp_spot SetModel( "tag_origin" );
	
	PlayFXOnTag( localClientNum, level._effect[ "lighthouse_morse_code" ], temp_spot, "tag_origin" );
	
	self._fx_array = add_to_array( self._fx_array, temp_spot, false );
}

solaris_howl( localClientNum, int_lenght )
{
	fx_array = self._fx_array;
	
	if(!IsDefined(fx_array))
	{
		return;
	}
	
	if( int_lenght )
	{
		for( i = 0; i < fx_array.size; i++ )
		{
			fx_array[i] PlaySound( localClientNum, "zmb_beepbadeepbadoop" );
		}
	}
	else
	{
		for( i = 0; i < fx_array.size; i++ )
		{
			fx_array[i] PlaySound( localClientNum, "zmb_beepbadoopbadeep" );
		}
	}
}

solaris_destroy()
{
	temp_array = self._fx_array;
	
	if(!IsDefined(self._fx_array))
	{
		return;
	}
	
	for( i = 0; i < temp_array.size; i++ )
	{
		if(IsDefined(self._fx_array[i]))
		{
			self._fx_array[i] Delete();
		}
	}
	
	self._fx_array = [];
}


stop_muscial_chair_message( i_light_message )
{
	level waittill( "slc" );
	
	i_light_message = 1;
	
}

director_footsteps(localClientNum, set, newEnt)
{
	self.footstepPrepend = "fly_step_director_";
}


fog_visionset_handler()
{
	while(1)
	{
		level waittill("FI");
		players = getlocalplayers();
		for(i=0;i<players.size;i++)
		{
			if(!players[i] IsSpectating())
			{
				players[i] thread clientscripts\_zombiemode::zombie_vision_set_apply( level._coast_blizzard_vision_set, level._coast_blizzard_vision_set_priority, 5,players[i] GetLocalClientNumber()  );
			}
		}
		level waittill("FO");
		players = getlocalplayers();
		for(i=0;i<players.size;i++)
		{
			if(!players[i] IsSpectating())
			{
				players[i] thread clientscripts\_zombiemode::zombie_vision_set_remove( level._coast_blizzard_vision_set, 5, players[i] GetLocalClientNumber() );
			}
		}
	}
}


flare_effects( local_client )
{
	// only client 0 works on this part
	if( local_client != 0 )
	{
		return;
	}
	
	// grabbin flares
	flares = GetEntArray( local_client, "coast_flare", "targetname" );
	
	if( !IsDefined( flares ) )
	{
		return; // avoid a script error if the bsp isn't up to date
	}
	
	// start all of them up
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		// now go through the flares
		for( j = 0; j < flares.size; j++ )
		{
			if( IsDefined( flares[j].script_int ) && flares[j].script_int == 1 ) // play the fx without the d-light
			{
				PlayFXOnTag( i, level._effect[ "flare_no_dlight" ], flares[j], "tag_fx" );
			}
			else if( IsDefined( flares[j].script_int ) && flares[j].script_int == 0 ) // play the fx with the d-light
			{
				PlayFXOnTag( i, level._effect[ "flare" ], flares[j], "tag_fx" );
			}
			else // if unknown just play the dlight to at least show it is working
			{
				PlayFXOnTag( i, level._effect[ "flare" ], flares[j], "tag_fx" );
			}
		}
	}
}


setup_fx_anims()
{
	waitforallclients();
	players = getlocalplayers();
	for(i=0;i<players.size;i++)
	{
		players[i] thread fxanim_init(i);
	}
}


#using_animtree("fxanim_props_dlc3");
fxanim_init( localClientNum )
{
	
	level.fxanims = [];
	level.fxanims["hook_anim"]		= %fxanim_zom_ship_crane01_hook_anim;
	level.fxanims["boat_anim"]		= %fxanim_zom_ship_lifeboat_anim;

	fxanims = GetEntArray( localClientNum, "fxanim", "targetname" );
	array_thread( fxanims, ::fxanim_think );
}

fxanim_think()
{
	anim_name = self.script_noteworthy;

	if ( !IsDefined( anim_name ) )
	{
//		println( "*** ClientScripts: fxanim at origin: '" + self.origin + "'" + " has no animation name on script_noteworthy" );
		return;
	}

	if ( !IsDefined( level.fxanims[anim_name] ) )
	{
//		println( "*** ClientScripts: Unknown fxanim: '" + anim_name + "'" );
		return;
	}

	if ( !IsDefined ( self.speed ) )
	{
		self.speed = 1;
	}
	if ( self.speed < 1 )
	{
		self.speed = 1;
	}

	wait_time = RandomFloatRange( 1, 2 );
	wait( wait_time );

	self UseAnimTree( #animtree );
	self SetAnim( level.fxanims[anim_name], 1.0, 0.0, self.speed );
}