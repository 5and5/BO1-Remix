// Test clientside script for zombie_temple

#include clientscripts\_utility;
#include clientscripts\_music;
#include clientscripts\_zombiemode_weapons;

main()
{
	level thread clientscripts\zombie_temple_ffotd::main_start();

	level._uses_crossbow = true;

	level._temple_vision_set = "zombie_temple";
	level._temple_vision_set_priority = 1;

	level._temple_caves_vision_set = "zombie_temple_caves";
	level._temple_caves_vision_set_priority = 2;

	level._temple_water_vision_set = "zombie_temple"; //"creek_1_water";

	level._temple_eclipse_vision_set = "zombie_temple_eclipse";
	level._temple_eclipse_vision_set_priority = 3;

	level._temple_caves_eclipse_vision_set = "zombie_temple_eclipseCave";
	level._temple_caves_eclipse_vision_set_priority = 3;

	init_client_flags();

	//Client side risers
	level.riser_fx_on_client  = 1;
	level.use_new_riser_water = 1;
	level.use_clientside_rock_tearin_fx = 1;
	level.use_clientside_board_fx = 1;

	// setup weapons
	include_weapons();

	// _load!
	clientscripts\_zombiemode::main();

	clientscripts\_zombiemode_spikemore::init();

	thread clientscripts\zombie_temple_fx::main();
	thread clientscripts\zombie_temple_amb::main();

	clientscripts\_zombiemode_ai_napalm::init_napalm_zombie();
	clientscripts\_zombiemode_ai_sonic::init_sonic_zombie();

	//Client side geyser anims
	clientscripts\zombie_temple_geyser::main();
	// Sticky Grenade
	clientscripts\_sticky_grenade::main();

	level thread power_watch();
	level thread waterfall_triggers_init();

	watch_power_water();

	// TODO when gibs are set up
	register_zombie_types();

	// on player connect
	OnPlayerConnect_Callback( ::temple_player_connect );

	// on player spawn run this function
	OnPlayerSpawned_Callback( ::temple_player_spawned );

//	_init_magic_box();
	_init_pap_indicators();

	register_flag_handlers();

	registerSystem("pap_indicator_spinners", ::temple_pap_monitor_spinners);

	level thread cave_vision_trigger_init();

	level thread temple_light_model_swap_init();

	level thread clientscripts\zombie_temple_ffotd::main_end();

	level thread sq_std_watcher();

	level thread waterfall_watcher();

	level thread timetravel_watcher();

	level thread crystal_sauce_monitor();

	level thread time_travel_vision();

	// This needs to be called after all systems have been registered.
	thread waitforclient(0);

	println("*** Client : zombie_temple running...");
}

init_client_flags()
{
	level._CF_ACTOR_IS_NAPALM_ZOMBIE = 0;
	level._CF_ACTOR_DO_NOT_USE = 1; //Someone is native code is setting this flag :(
	level._CF_ACTOR_NAPALM_ZOMBIE_EXPLODE = 2;
	level._CF_ACTOR_IS_SONIC_ZOMBIE = 3;
	level._CF_ACTOR_NAPALM_ZOMBIE_WET = 4;
	level._CF_ACTOR_CLIENT_FLAG_SPIKEMORE = 5;
	level._CF_ACTOR_RAGDOLL_IMPACT_GIB = 6;

	level._CF_PLAYER_GEYSER_FAKE_PLAYER_SETUP_PRONE = 0;
	level._CF_PLAYER_GEYSER_FAKE_PLAYER_SETUP_STAND = 1;
	level._CF_PLAYER_MAZE_FLOOR_RUMBLE = 3;

	level._CF_SCRIPTMOVER_CLIENT_FLAG_SPIKES = 3;
	level._CF_SCRIPTMOVER_CLIENT_FLAG_MAZE_WALL = 4;
	level._CF_SCRIPTMOVER_CLIENT_FLAG_SPIKEMORE = 5;

	level._CF_SCRIPTMOVER_CLIENT_FLAG_WEAKSAUCE_START = 6;
	level._CF_SCRIPTMOVER_CLIENT_FLAG_HOTSAUCE_START = 7;
	level._CF_SCRIPTMOVER_CLIENT_FLAG_SAUCE_END = 8;
	level._CF_SCRIPTMOVER_CLIENT_FLAG_WATER_TRAIL = 9;

}

register_flag_handlers()
{
	register_clientflag_callback("actor", level._CF_ACTOR_RAGDOLL_IMPACT_GIB, ::ragdoll_impact_watch_start );

	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_SPIKES, ::spike_trap_move);
	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_MAZE_WALL, ::maze_wall_move);
	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_WEAKSAUCE_START, ::crystal_weaksauce_start);
	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_HOTSAUCE_START, ::crystal_hotsauce_start);
	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_SAUCE_END, ::crystal_sauce_end);
	register_clientflag_callback("scriptmover", level._CF_SCRIPTMOVER_CLIENT_FLAG_WATER_TRAIL, ::water_trail_monitor);

	register_clientflag_callback( "player", level._CF_PLAYER_MAZE_FLOOR_RUMBLE, ::maze_floor_controller_rumble );
}

spike_trap_move(localClientNum, set, newEnt)
{
	spike_trap_move_spikes(localClientNum, set);
}

maze_wall_move(localClientNum, set, newEnt)
{
	clientscripts\zombie_temple_maze::maze_trap_move_wall(localClientNum, set);
}

delete_water_trail()
{
	realWait(1.2);

	for(i = 0; i < self.fx_ents.size; i ++)
	{
		self.fx_ents[i] Delete();
	}

	self.fx_ents = undefined;
}

water_trail_monitor(localClientNum, set, newEnt)
{
	if(localClientNum != 0)
	{
		return;
	}

	if(set)
	{
		players = getlocalplayers();

		self.fx_ents = [];

		for(i = 0; i < players.size; i ++)
		{
			self.fx_ents[i] = spawn(i, (0,0,0), "script_model");
			self.fx_ents[i] SetModel("tag_origin");
			self.fx_ents[i] LinkTo(self, "tag_origin");
			PlayFXOnTag(i,	level._effect["fx_crystal_water_trail"], self.fx_ents[i], "tag_origin");
		}
	}
	else
	{
		if(IsDefined(self.fx_ents))
		{
			self thread delete_water_trail();
		}
	}
}

crystal_weaksauce_start(localClientNum, set, newEnt)
{
	if(localClientNum != 0)
	{
		return;
	}

	if(!set)
	{
		return;
	}

	s = spawnstruct();
	s.fx = "fx_weak_sauce_trail";
	s.origin = self.origin + (0,0,134);

	level._crystal_sauce_start = s;
}

crystal_hotsauce_start(localClientNum, set, newEnt)
{
	if(localClientNum != 0)
	{
		return;
	}

	if(!set)
	{
		return;
	}

	s = spawnstruct();
	s.fx = "fx_hot_sauce_trail";
	s.origin = self.origin + (0,0,134);

	level._crystal_sauce_start = s;

}

crystal_sauce_end(localClientNum, set, newEnt)
{
	if(localClientNum != 0)
	{
		return;
	}

	if(!set)
	{
		return;
	}

	level._crystal_sauce_end = self.origin;

	if(self.model == "p_ztem_crystal_and_holder")
	{
		level._crystal_sauce_end += ( 0, 0, 134 );
	}
}

crystal_trail_runner(localClientNum, fx_name, dest)
{
	PrintLn("Running " + fx_name + " from " + self.origin + " to " + dest);
	PlayFXOnTag( localClientNum, level._effect[ fx_name ], self, "tag_origin" );

	self playloopsound( "evt_sq_bag_crystal_bounce_loop", .05 );
	self MoveTo(dest, 0.5);
	self waittill("movedone");

	self Delete();
}

crystal_sauce_monitor()
{
	waitforallclients();
	num_players = getlocalplayers().size;

	while(1)
	{
		realWait(0.016);
		if(!IsDefined(level._crystal_sauce_start) || !IsDefined(level._crystal_sauce_end))
		{
			continue;
		}

		for(i = 0; i < num_players; i ++)
		{
			e = spawn(i, level._crystal_sauce_start.origin, "script_model");
			e SetModel("tag_origin");
			e thread crystal_trail_runner(i, level._crystal_sauce_start.fx, level._crystal_sauce_end);
		}

		level._crystal_sauce_start = undefined;
		level._crystal_sauce_end = undefined;
	}
}

power_watch()
{
	level.power = false;
	level waittill("ZPO");
	level.power = true;

	level thread start_generator_movement();
}

timetravel_watcher()
{
	level._in_eclipse = false;

	level thread eclipse_watcher();
	level thread daybreak_watcher();

	level thread my_eclipse_watcher();
	level thread my_daybreak_watcher();
}

time_travel_vision()
{
	level waittill("time_travel");	// initial set - ignore

	while(1)
	{
		level waittill("time_travel");

		setdvarfloat("r_poisonFX_debug_amount", 0);
		setdvar("r_poisonFX_debug_enable", 1);
		setdvarfloat("r_poisonFX_pulse", 2);
		setdvarfloat("r_poisonFX_warpX", -.3);
		setdvarfloat("r_poisonFX_warpY", .15);
		setdvarfloat("r_poisonFX_dvisionA", 0);
		setdvarfloat("r_poisonFX_dvisionX", 0);
		setdvarfloat("r_poisonFX_dvisionY", 0);
		setdvarfloat("r_poisonFX_blurMin", 0);
		setdvarfloat("r_poisonFX_blurMax", 3);

		delta = 0.064;
		amount = 1;
		setdvarfloat("r_poisonFX_debug_amount", amount);

		realWait(1.75);

		while(amount > 0)
		{
			amount = Max(amount  - delta, 0);

			setdvarfloat("r_poisonFX_debug_amount", amount);
			wait(0.016);
		}

		setdvarfloat("r_poisonFX_debug_amount", 0);
		setdvar("r_poisonFX_debug_enable", 0);

	}
}

eclipse_watcher()
{
	while(1)
	{
		level waittill("ec", lcn);		// Eclipse.
		if( IsDefined( lcn ) && lcn != 0 )
		{
			continue;
		}
		level._in_eclipse = true;
		level notify("time_travel", level._in_eclipse);

		clientscripts\_fx::activate_exploder(402);
		clientscripts\_fx::deactivate_exploder(401);

		players = getlocalplayers();

		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?

		for( i = 0; i < players.size; i ++)
		{
			players[i] thread temple_set_eclipse_visionset( i );

			if(IsDefined(players[i]._in_cave) && players[i]._in_cave)
			{
				players[i] thread temple_set_visionset_caves( i );
			}
		}

		SetSunlight( 0.5426, 0.6538, 0.7657);
		setsaveddvar("r_lightTweakSunLight", 11);
		level thread strobe_sky_and_transition(1.0);
		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?

	}
}

my_eclipse_watcher()
{
	while(1)
	{
		level waittill("eclipse");		// Eclipse.

		level notify("time_travel", level._in_eclipse);

		clientscripts\_fx::activate_exploder(402);
		clientscripts\_fx::deactivate_exploder(401);

		players = getlocalplayers();

		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?

		for( i = 0; i < players.size; i ++)
		{
			players[i] thread temple_set_eclipse_visionset( i );

			if(IsDefined(players[i]._in_cave) && players[i]._in_cave)
			{
				players[i] thread temple_set_visionset_caves( i );
			}
		}

		SetSunlight( 0.5426, 0.6538, 0.7657);
		setsaveddvar("r_lightTweakSunLight", 11);
		level thread strobe_sky_and_transition(1.0);
		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?
	}
}

strobe_sky_and_transition(end_val)
{

	val = end_val;

	delay = 0.016;

	for(i = 0; i < 10; i ++)
	{
		SetSavedDvar( "r_skyTransition", val);
		val = 1.0 - val;

		realWait(delay);

		delay = delay * 1.1;
	}

	step = 1 / 120;

	val = 1 - end_val;

	if(val == 0)
	{
		step *= -1;
	}

	for(i = 0; i < 120; i ++)
	{
		SetSavedDvar( "r_skyTransition", val );
		val -= step;
		wait(0.016);
	}

	SetSavedDvar( "r_skyTransition", end_val );


}

daybreak_watcher()
{
	while(1)
	{
		level waittill("db", lcn);		// Daybreak.
		if( IsDefined( lcn ) && lcn != 0 )
		{
			continue;
		}
		level._in_eclipse = false;
		level notify("time_travel", level._in_eclipse);

		clientscripts\_fx::activate_exploder(401);
		clientscripts\_fx::deactivate_exploder(402);

		players = getlocalplayers();

		for( i = 0; i < players.size; i ++)
		{
			players[i] thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_eclipse_vision_set, 2.0, i );
			players[i] thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_caves_eclipse_vision_set, 2.0, i );
		}

		if(IsDefined(players[0]._in_cave) && players[0]._in_cave)
		{
			clientscripts\zombie_temple_fx::cave_fog_on(); //Can this work with split screen?
		}
		else
		{
			clientscripts\zombie_temple_fx::cave_fog_off(); //Can this work with split screen?
		}

		setsaveddvar("r_lightTweakSunLight", 13);

		if(!IsDefined(level.first_sky_trans))
		{
			level.first_sky_trans = false;
			SetSavedDvar( "r_skyTransition", 0.0 );
		}
		else
		{
			level thread strobe_sky_and_transition(0.0);
		}

		ResetSunlight();
	}
}

my_daybreak_watcher()
{
	while(1)
	{
		level waittill("daybreak");		// Daybreak.

		level._in_eclipse = false;
		level notify("time_travel", level._in_eclipse);

		clientscripts\_fx::activate_exploder(401);
		clientscripts\_fx::deactivate_exploder(402);

		players = getlocalplayers();

		for( i = 0; i < players.size; i ++)
		{
			players[i] thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_eclipse_vision_set, 2.0, i );
			players[i] thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_caves_eclipse_vision_set, 2.0, i );
		}

		if(IsDefined(players[0]._in_cave) && players[0]._in_cave)
		{
			clientscripts\zombie_temple_fx::cave_fog_on(); //Can this work with split screen?
		}
		else
		{
			clientscripts\zombie_temple_fx::cave_fog_off(); //Can this work with split screen?
		}

		setsaveddvar("r_lightTweakSunLight", 13);

		if(!IsDefined(level.first_sky_trans))
		{
			level.first_sky_trans = false;
			SetSavedDvar( "r_skyTransition", 0.0 );
		}
		else
		{
			level thread strobe_sky_and_transition(0.0);
		}

		ResetSunlight();
	}
}

start_generator_movement()
{
	players = GetLocalPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		ent = GetEnt(i, "power_generator", "targetname");
		ent thread generator_move();
	}
}

generator_move()
{
	offsetAngle = 0.25;
	rotTime = 0.1;
	total = 0;
	self RotateRoll(0 - offsetAngle, rotTime);
	while ( true )
	{
		self waittill("rotatedone");
		self RotateRoll(offsetAngle * 2, rotTime);
		self waittill("rotatedone");
		self RotateRoll(0 - offsetAngle * 2, rotTime);
	}
}

watch_power_water()
{
	level thread water_wheel_watch("wwr", "water_wheel_right", 120, 2.2);
	level thread water_wheel_watch("wwl", "water_wheel_left", 120, 1.8);

}

water_wheel_watch(waitFor, entName, rotate, time)
{
	level waittill(waitFor);

	players = GetLocalPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		wheel = GetEnt(i, entName, "targetname");
		wheel thread rotateWheel(rotate,time);
	}
}

rotateWheel(rotate, time)
{
	spinUpTime = time - 0.5;
	self RotatePitch(rotate, time, spinUpTime, 0.1);
	self waittill("rotatedone");
	while( true )
	{
		self RotatePitch(rotate, time, 0, 0);
		self waittill("rotatedone");
	}
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

water_gush_debug()
{
	scale = 0.1;
	offset = (0,0,0);

	dir = AnglesToForward(self.angles);

	for(i = 0; i < 5; i ++)
	{
		Print3d(self.origin + offset, "+", (60,60,255), 1, scale, 10);
		scale *= 1.7;
		offset += dir * 6;
	}
}

waterfall_watcher()
{
	targets = getstructarray("sq_sad", "targetname");

	while(1)
	{
		level waittill("WF");

		for(i = 0; i < 4; i ++)
		{
			if(!isDefined(level._sq_std_status) || !isDefined(level._sq_std_status[i]) )
			{
				continue;
			}
			if(level._sq_std_status[i] == 0)
			{
//				targets[i] thread water_gush_debug();
					clientscripts\_fx::activate_exploder(120 + i);
			}

			wait(0.25);
		}
	}
}

sq_std_watcher()
{
	PrintLn("watcher : start");
	waitforallclients();
	PrintLn("watcher : post wfac");
	players = getlocalplayers();

	level waittill("SR");

	PrintLn("watcher : post SR");

	targets = getstructarray("sq_sad", "targetname");

	PrintLn("Client : Threading sq_std_struct_watcher on " + targets.size + " structs.");

	for(i = 0; i < targets.size; i ++)
	{
		targets[i] thread sq_std_struct_watcher(players.size);
	}
}

sq_std_watch_for_restart(num_local_players)
{
	level waittill("SR");

	if(IsDefined(level._sq_std_array[self.script_int - 1]))
	{
		for(i = 0; i < level._sq_std_array[self.script_int - 1].size; i ++)
		{
			if(IsDefined(level._sq_std_array[self.script_int - 1][i]))
			{
				level._sq_std_array[self.script_int - 1][i] Delete();
			}
		}

		level._sq_std_array[self.script_int - 1] = undefined;
	}

	level._sq_std_status[self.script_int - 1] = 0;

	self thread sq_std_struct_watcher(num_local_players);
}

sq_struct_debug()
{
	level endon("SR");
	level endon("ksd");

	while(1)
	{
		Print3D(self.origin, "+", (255,0,0),1);
		wait(0.1);
	}
}

sq_std_struct_watcher(num_local_players)
{
	if(!IsDefined(level._sq_std_array))
	{
		level._sq_std_array = [];
		level._sq_std_status = [];

		for(i = 0; i < 4; i ++)
		{
			level._sq_std_status[i] = 0;
		}
	}

	level endon("SR");
	self thread sq_std_watch_for_restart(num_local_players);

	while(1)
	{
		level waittill("S"+self.script_int);

		PrintLn("*** Client : Got S " +self.script_int);

		self thread sq_struct_debug();

		level._sq_std_status[self.script_int - 1] = 1;

		level._sq_std_array[self.script_int - 1] = [];

		for(i = 0; i < num_local_players; i ++)
		{
			e = spawn(i, self.origin, "script_model");
			e.angles = self.angles;
			e SetModel("p_ztem_spikemore_spike");
			level._sq_std_array[self.script_int - 1][level._sq_std_array[self.script_int - 1].size] = e;
		}
	}
}

//Stuff that needs to run on the player at connect.
temple_player_connect( i_local_client_num )
{
	self endon( "disconnect" );

	// make sure the client has a snapshot from the server before continuing
	while( !ClientHasSnapshot( i_local_client_num ) )
	{
		wait( 0.05 );
	}

	while ( !self hasdobj( i_local_client_num ) )
	{
		wait( 0.05 );
	}

	self thread clientscripts\_swimming::set_swimming_vision_set( level._temple_water_vision_set );

	if ( GetLocalPlayers().size == 1 )
	{
		//players track how close they are to napalm zombie so they can fade up the flame overlay
		self thread clientscripts\_zombiemode_ai_napalm::player_napalm_radius_overlay_fade();
	}

	//watch for arms assignment
	self thread init_arms();

	// only client 0 works on this part
	if( i_local_client_num != 0 )
	{
		return;
	}

	thread floating_boards_init();

	self thread disable_deadshot(i_local_client_num);

	// run any functions on all the local players from the first local player
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread temple_set_visionset( i );
	}
}

//Stuff that needs to run on the player at spawn.
temple_player_spawned( i_local_client_num )
{
	self endon( "disconnect" );

	// Wait until all the rendered objects are setup
	while ( !self hasdobj( i_local_client_num ) )
	{
		wait( 0.05 );
	}

	// only client 0 works on this part
	if( i_local_client_num != 0 )
	{
		return;
	}

	// run any functions on all the local players from the first local player
	players = GetLocalPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] thread temple_set_visionset( i );
		players[i] thread temple_remove_visionset_caves(i);
	}
}

//Order needs to match server
init_arms()
{
	wait 5;
	switch( self.model )
	{
		case "c_usa_dempsey_body":
			// Dempsey
			self.viewmodel = "viewmodel_usa_pow_arms";
			break;
		case "c_rus_nikolai_body":
			// Nikolai
			self.viewmodel = "viewmodel_rus_prisoner_arms";
			break;
		case "c_jap_takeo_body":
			// Takeo
			self.viewmodel = "viewmodel_vtn_nva_standard_arms";
			break;
		case "c_ger_richtofen_body":
			// Richtofen
			self.viewmodel = "viewmodel_usa_hazmat_arms";
			break;
		default:
			println("Model " + self.model + "does not have matching view model");
			break;
	}
}

cave_vision_trigger_init()
{
	caveTrigger = getent(0, "cave_vision_trig","targetname");
	if(isDefined(caveTrigger))
	{
		caveTrigger thread cave_vision_trigger_watch();
	}

}
cave_vision_trigger_watch()
{
	while(1)
	{
		self waittill("trigger", who);

		if(who IsLocalPlayer())
		{
			who = GetLocalPlayers()[who GetLocalClientNumber()];
			self thread trigger_thread(who, ::cave_vision_on, ::cave_vision_off);
		}
	}
}

cave_vision_on(player)
{
	if(!player IsPlayer())
	{
		return;
	}

	i_local_client_num = player GetLocalClientNumber();
	player._in_cave = true;
	player temple_set_visionset_caves( i_local_client_num );

	if(level._in_eclipse)
	{
		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?
	}
	else
	{
		clientscripts\zombie_temple_fx::cave_fog_on(); //Can this work with split screen?
	}
}

cave_vision_off(player)
{
	if( !IsDefined( player ) )
	{
		// drop out since the player is no longer valid
		return;
	}

	player._in_cave = false;

	if(!player IsPlayer())
	{
		return;
	}

	i_local_client_num = player GetLocalClientNumber();

	player temple_remove_visionset_caves(i_local_client_num);

	if(level._in_eclipse)
	{
		clientscripts\zombie_temple_fx::eclipse_fog_on(); //Can this work with split screen?
	}
	else
	{
		clientscripts\zombie_temple_fx::cave_fog_off(); //Can this work with split screen?
	}
}

// -------------------------------------------------------------------------------------------------------------
// controls the visionset for players
// -------------------------------------------------------------------------------------------------------------
temple_set_visionset( i_local_client_num )
{
	self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._temple_vision_set, level._temple_vision_set_priority, 0.1, i_local_client_num );
}

temple_set_eclipse_visionset( i_local_client_num )
{
	self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._temple_eclipse_vision_set, level._temple_eclipse_vision_set_priority, 0.1, i_local_client_num );
}

temple_set_visionset_caves( i_local_client_num )
{
	println("***** Vision: Set Caves *****");
	self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._temple_caves_vision_set, level._temple_caves_vision_set_priority, 2.0, i_local_client_num );

	if(level._in_eclipse)
	{
		self thread clientscripts\_zombiemode::zombie_vision_set_apply( level._temple_caves_eclipse_vision_set, level._temple_caves_eclipse_vision_set_priority, 2.0, i_local_client_num );
	}
}

temple_remove_visionset_caves(i_local_client_num)
{
	println("***** Vision: Remove Caves *****");
	self thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_caves_vision_set, 2.0, i_local_client_num );

	if(level._in_eclipse)
	{
		self thread clientscripts\_zombiemode::zombie_vision_set_remove( level._temple_caves_eclipse_vision_set, 2.0, i_local_client_num );
	}
}

include_weapons()
{
	include_weapon( "frag_grenade_zm", false );
	include_weapon( "sticky_grenade_zm", false, true );
	include_weapon( "spikemore_zm", false, true );

	//	Weapons - Pistols
	include_weapon( "m1911_zm", false );						// colt
	include_weapon( "m1911_upgraded_zm", false );
	include_weapon( "python_zm", false );								// 357
	include_weapon( "python_upgraded_zm", false );
	include_weapon( "cz75_zm" );
    include_weapon( "cz75_upgraded_zm", false );

	//	Weapons - Semi-Auto Rifles
	include_weapon( "m14_zm", false, true );					// gewehr43
	include_weapon( "m14_upgraded_zm", false );

	//	Weapons - Burst Rifles
	include_weapon( "m16_zm", false, true );
	include_weapon( "m16_gl_upgraded_zm", false );
	include_weapon( "g11_lps_zm" );
	include_weapon( "g11_lps_upgraded_zm", false );
	include_weapon( "famas_zm" );
	include_weapon( "famas_upgraded_zm", false );

	//	Weapons - SMGs
	include_weapon( "ak74u_zm", false, true );					// thompson, mp40, bar
	include_weapon( "ak74u_upgraded_zm", false );
	include_weapon( "mp5k_zm", false, true );
	include_weapon( "mp5k_upgraded_zm", false );
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
	include_weapon( "ithaca_zm", false, true );					// shotgun
	include_weapon( "ithaca_upgraded_zm", false );
	include_weapon( "rottweil72_zm", false, true );
	include_weapon( "rottweil72_upgraded_zm", false );
	include_weapon( "spas_zm", false );
	include_weapon( "spas_upgraded_zm", false );
	include_weapon( "hs10_zm", false );
	include_weapon( "hs10_upgraded_zm", false );

	//	Weapons - Assault Rifles
	include_weapon( "aug_acog_zm", true );
	include_weapon( "aug_acog_mk_upgraded_zm", false );
	include_weapon( "galil_zm" );
	include_weapon( "galil_upgraded_zm", false );
	include_weapon( "commando_zm" );
	include_weapon( "commando_upgraded_zm", false );
	include_weapon( "fnfal_zm" );
	include_weapon( "fnfal_upgraded_zm", false );

	//	Weapons - Sniper Rifles
	include_weapon( "dragunov_zm", false );							// ptrs41
	include_weapon( "dragunov_upgraded_zm", false );
	include_weapon( "l96a1_zm", false );
	include_weapon( "l96a1_upgraded_zm", false );

	//	Weapons - Machineguns
	include_weapon( "rpk_zm" );									// mg42, 30 cal, ppsh
	include_weapon( "rpk_upgraded_zm", false );
	include_weapon( "hk21_zm" );
	include_weapon( "hk21_upgraded_zm", false );

	//	Weapons - Misc
	include_weapon( "m72_law_zm", false );
	include_weapon( "m72_law_upgraded_zm", false );
	include_weapon( "china_lake_zm", false );
	include_weapon( "china_lake_upgraded_zm", false );
	
	//	Weapons - Special
	include_weapon( "zombie_cymbal_monkey" );
	include_weapon( "ray_gun_zm" );
	include_weapon( "ray_gun_upgraded_zm", false );

	include_weapon( "crossbow_explosive_zm" );
	include_weapon( "crossbow_explosive_upgraded_zm", false );
	include_weapon( "knife_ballistic_zm", true );
	include_weapon( "knife_ballistic_upgraded_zm", false );
	include_weapon( "knife_ballistic_bowie_zm", false );
	include_weapon( "knife_ballistic_bowie_upgraded_zm", false );

	// Custom weapons
	include_weapon( "ppsh_zm" );
	include_weapon( "ppsh_upgraded_zm", false );
	include_weapon( "stoner63_zm" );
	include_weapon( "stoner63_upgraded_zm",false );
	include_weapon( "ak47_zm" );
 	include_weapon( "ak47_upgraded_zm", false);

}


register_zombie_types()
{
	character\clientscripts\c_viet_zombie_female_body::register_gibs();
	character\clientscripts\c_viet_zombie_female_body_alt::register_gibs();
	character\clientscripts\c_viet_zombie_nva1::register_gibs();
	character\clientscripts\c_viet_zombie_nva1_alt::register_gibs();
	character\clientscripts\c_viet_zombie_sonic::register_gibs();
	character\clientscripts\c_viet_zombie_vc::register_gibs();
}

/////////////////////////////////////////////////////////////////////////////////////////

_init_magic_box()
{
	level._custom_box_monitor = ::temple_box_monitor;

	level._box_locations = array( "waterfall_upper_chest",
		                          "blender_chest",
								  "pressure_chest",
								  "bridge_chest",
								  "caves_water_chest",
								  "power_chest",
								  "caves1_chest",
								  "caves2_chest",
								  "caves3_chest"
								  );

	OnPlayerConnect_Callback( ::_init_indicators );

	level.cachedInfo = [];
	level.initialized = [];
}

_init_indicators( clientNum )
{
	structs = GetStructArray("magic_box_indicator", "targetname");
	for ( i = 0; i < structs.size; i++ )
	{
		s = structs[i];
		if ( !IsDefined( s.viewModels ) )
		{
			s.viewModels = [];
		}

		s.viewModels[clientNum] = undefined;
	}

	level.initialized[clientNum] = true;

	keys = GetArrayKeys(level.cachedInfo);
	for ( i = 0; i < keys.size; i++ )
	{
		key = keys[i];
		state = level.cachedInfo[key];
		temple_box_monitor(i, state, "");
	}

}

temple_box_monitor(clientNum, state, oldState)
{
	if ( !IsDefined(level.initialized[clientNum]) )
	{
		//print( "Cached(" + clientNum + "): " + state);
		level.cachedInfo[clientNum] = state;
		return;
	}

	//println( "TBM(" + clientNum + "): state: " + state );



	switch ( state )
	{
	case "fire_sale":
		_all_locations(clientNum);
		break;

	case "moving":
		level thread _random_location(clientNum);
		break;

		// the box is in a position, so only turn on those indicators
	default:
		level notify("location_set"+clientNum);
		_setup_location(clientNum, state);

		break;
	}
}

_delete_location( clientNum, location )
{
	structs = GetStructArray(location, "script_noteworthy");
	array_thread( structs, ::_setup_view_model, clientNum, undefined );
}

_delete_all_locations(clientNum)
{
	for ( i = 0; i < level._box_locations.size; i++ )
	{
		location = level._box_locations[i];
		_delete_location(clientNum, location);
	}
}

_show_location( clientNum, location )
{
	structs = GetStructArray(location, "script_noteworthy" );
	array_thread( structs, ::_setup_view_model, clientNum, "zt_map_knife" );
}

_setup_location( clientNum, location )
{
	_delete_all_locations(clientNum);

	_show_location(clientNum, location);
}

_setup_view_model( clientNum, viewModel )
{
	if ( IsDefined( self.viewModels[clientNum] ) )
	{
		self.viewModels[clientNum] Delete();
		self.viewModels[clientNum] = undefined;
	}

	if ( IsDefined( viewModel ) )
	{
		self.viewModels[clientNum] = spawn( clientNum, self.origin, "script_model");
		self.viewModels[clientNum].angles = self.angles;
		self.viewModels[clientNum] SetModel(viewModel);
	}
}

_random_location(clientNum)
{
	level endon("location_set"+clientNum);

	index = 0;
	while ( true )
	{
		location = level._box_locations[index];
		_setup_location( clientNum, location );
		index++;

		if ( index >= level._box_locations.size )
		{
			index = 0;
		}

		wait(0.25);
	}
}

_all_locations(clientNum)
{
	for ( i = 0; i < level._box_locations.size; i++ )
	{
		location = level._box_locations[i];
		_show_location( clientNum, location );
	}
}

///////////////////////////////////////////////////////////////////////////////////

_init_pap_indicators()
{
	waitforallclients();

	local_players = getlocalplayers();
	for(index=0;index<local_players.size;index++)
	{
		level thread _init_pap_spinners(index);
		level thread _set_num_visible_spinners(index, 0);
	}
}

temple_pap_monitor_spinners(clientNum, state, oldState)
{
	getlocalplayers()[clientNum] _set_num_visible_spinners(clientNum, int(state));
}

power( base, exp )
{
	assert( exp >= 0 );

	if ( exp == 0 )
	{
		return 1;
	}

	return base * power( base, exp - 1 );
}

_set_num_visible_spinners(clientNum, num)
{
 	//println("Spinners: " + clientNum + " num: " + num );

	for(i=3;i>=0;i--)
	{
		pow = power(2,i);
		if(num>=pow)
		{
			num -= pow;

			//println("Spin To Start: " + clientNum + " Spinners" + i + "=" + self.spinners[i].size );
			array_thread(level.spinners[clientNum][i], ::spin_to_start);
		}
		else
		{
			//println("Spin Forever: " + clientNum + " Spinners" + i + "=" + level.info[clientNum].spinners[i].size );
			array_thread(level.spinners[clientNum][i], ::spin_forever);
		}
	}
}


////////////////
//	SPEAR TRAP
////////////////
spike_trap_move_spikes(localClientNum, active)
{
	if(!isDefined(self.spears))
	{
		//Will set self.spikes
		self set_trap_spears(localClientNum);
	}
	spears = self.spears;

	if(isDefined(spears))
	{
		for(i=0;i<spears.size;i++)
		{
			playSound = i==0; //Only play sound for the first spear
			spears[i] thread spear_init(localClientNum);
 			spears[i] thread spear_move(localClientNum, active, playSound);
		}

	}
}

set_trap_spears(localClientNum)
{
	allSpears = GetEntArray(localClientNum,"spear_trap_spear","targetname");

	self.spears = [];
	//This only works because all the spear trap rows are aligned on the y-axis
	for(i=0;i<allSpears.size;i++)
	{
		spear = allSpears[i];
		if(isDefined(spear.assigned) && spear.assigned)
		{
			continue;
		}

		delta = abs(self.origin[0] - spear.origin[0]);
		if(abs(self.origin[0] - spear.origin[0]) < 21)
		{
			spear.assigned = true;
			self.spears[self.spears.size] = spear;
		}
	}
}

spear_init(localClientNum)
{
	if(!isDefined(self.init) || !self.init)
	{
		self.moveDistMin = 90;
		self.moveDistMax = 120;
		self.start = self.origin;
		self.moveDir = -1 * AnglesToRight(self.angles);
		self.init = true;
	}
}

spear_move(localClientNum, active, playSound)
{
	if(active)
	{
		if(playSound)
		{
			play_sound_in_space(0,"evt_spiketrap_warn", self.origin);
		}
		moveDist = RandomFloatRange(self.moveDistMin, self.moveDistMax);
		endPos = self.start + (self.moveDir*moveDist);

		PlayFX(localClientNum, level._effect["punji_dust"], endPos );

		playsound(0, "evt_spiketrap", self.origin );

		moveTime = randomFloatRange(.08, .22);
		self MoveTo( endPos, moveTime);
	}
	else
	{
		if(playSound)
		{
			playSound(0,"evt_spiketrap_retract",self.origin);
		}
		moveTime = randomFloatRange(.1, .2);
		self MoveTo( self.start, moveTime);
	}
}

floating_boards_init()
{
	boards = [];
	players = GetLocalPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		boards = array_combine( boards, GetEntArray(i, "plank_water", "targetname"));
	}

	array_thread(boards, ::float_board);
}

float_board()
{
	wait(RandomFloat(1.0));
	self.start_origin = self.origin;
	self.start_angles = self.angles;
	self.moment_move = self.origin;
	self thread board_bob();
	self thread board_rotate();
	//self thread board_move();
}

board_bob()
{
	dist = RandomFloatRange(2.5,3.0);
	moveTime = RandomFloatRange(3.5,4.5);

	minZ = self.start_origin[2] - dist;
	maxZ = self.start_origin[2] + dist;

	while ( true )
	{

		toZ = minZ - self.origin[2];
		self MoveZ(toZ, moveTime);
		self waittill("movedone");
		toZ = maxZ - self.origin[2];
		self MoveZ(toZ, moveTime);
		self waittill("movedone");
	}
}

board_rotate()
{
	while ( true )
	{
		yaw = RandomFloatRange(-360.0, 360.0);
		self RotateYaw(yaw, RandomFloatRange(60.0, 90.0));
		self waittill("rotatedone");
	}
}

board_move()
{
	dist = RandomFloatRange(20.0,30.0);
	moveTime = RandomFloatRange(5.0, 10.0);

	while ( true )
	{
		yaw = RandomFloatRange(0,360.0);
		toVector = AnglesToForward((0,yaw,0));
		//println("TOV: " + toVector[0] + " " + toVector[1] + " " + toVector[2]);
		newLoc = self.start_origin + toVector * dist;

		toX = newLoc[0] - self.origin[0];
		//println("TOX: " + toX);
		self MoveX(toX, moveTime);
		toY = newLoc[1] - self.origin[1];
		self MoveY(toY, moveTime);
		//println("TOY: " + toY);
		//wait(moveTime);
	}
}

_init_pap_spinners(cNum)
{
	if(!isDefined(level.spinners))
	{
		level.spinners = [];
	}

	if(level.spinners.size<=cNUm)
	{
		level.spinners[level.spinners.size] = array([], [], [], []);
	}

	println("***Client " + cNum + " Init Spinners");

	for(i=0; i<level.spinners[cNum].size;i++)
	{
		spinners = getEntArray(cNum, "pap_spinner" + (i+1), "targetname");
		//println("***Client " + cNum + " Spinners" + i + "=" +spinners.size);
		array_thread(spinners, ::init_spinner, i+1);
		level.spinners[cNum][i] = spinners;
	}
}

init_spinner(listNum)
{
	self.spinner = listNum;
	self.startAngles = self.angles;

	self.spin_sound = "evt_pap_spinner0" + listNum;
	self.spin_stop_sound = "evt_pap_timer_stop";

	//Random the rotators at start
	self.angles = (0, 90*(listNum-1) + randomFloatRange(10,80), 0);
}

//spinners_wait_for_power()
//{
//	level waittill("ZPO");
//
//	//Spin all spinners
//	for(i=0;i<level.spinners.size;i++)
//	{
//		for(j=0;j<level.spinners[i].size;j++)
//		{
//			level.spinners[i][j] thread spin_forever();
//		}
//	}
//}
spin_forever()
{
	if(!level.power)
	{
		return;
	}
	if(isDefined(self.spin_forever) && self.spin_forever)
	{
		return;
	}
	self.spin_forever = true;
	self.spin_to_start = false;
	self notify("stop_spinning");

	self endon("death");
	self endon("stop_spinning");

	spinTime = self	spinner_get_spin_time();

	// Start the looping sound
	self start_spinner_sound();

	//First turn accelerates
	self rotateYaw(360, spinTime, .25);
	self waittill("rotatedone");
	while(1)
	{
		self rotateYaw(360, spinTime);
		self waittill("rotatedone");
	}
}
spinner_get_spin_time()
{
	spinTime = 1.7; // spinner = 1
	if(self.spinner == 2)
	{
		spinTime = 1.5;
	}
	else if(self.spinner == 3)
	{
		spinTime = 1.2;
	}
	else if(self.spinner == 4)
	{
		spinTime = 0.8;
	}

	return spinTime;
}
spin_to_start()
{
	if(!level.power)
	{
		return;
	}

	if(isDefined(self.spin_to_start) && self.spin_to_start)
	{
		return;
	}
	self.spin_forever = false;
	self.spin_to_start = true;

	self notify("stop_spinning");

	self endon("death");
	self endon("stop_spinning");

	endYaw = self.startAngles[1];
	currentYaw = self.angles[1];

	deltaYaw = endYaw - currentYaw;
	while(deltaYaw<0)
	{
		deltaYaw+=360;
	}

	spinTime = self spinner_get_spin_time();
	spinTime *= (deltaYaw/360);

	if(spinTime > 0)
	{
		self rotateYaw(deltaYaw, spinTime, 0.0);
		self waittill("rotatedone");
	}

	// Play spinner stop sound
	self stop_spinner_sound();

	self.angles = self.startAngles;
}

start_spinner_sound()
{
	self playloopsound( self.spin_sound );
}

stop_spinner_sound()
{
	self stoploopsound();
	self playsound( 0, self.spin_stop_sound );
}

temple_light_model_swap_init()
{
	// precache all the models first

	level waittill("ZPO");

	// allow the water wheels to spin up a bit
	realwait(4.5);

	level notify( "pl1" );  // power lights on


	players = getlocalplayers();

	for( i = 0; i < players.size; i++ )
	{
		light_models = GetEntArray( i,  "model_lights_on", "targetname" );

		for ( x = 0; x < light_models.size; x++ )
		{
			light = light_models[x];
			if ( IsDefined(light.script_string) )
			{
				light SetModel(light.script_string);
			}
			else if ( light.model == "p_ztem_power_hanging_light_off" )
			{
				light SetModel("p_ztem_power_hanging_light");
			}
			else if ( light.model == "p_lights_cagelight02_off" )
			{
				light SetModel("p_lights_cagelight02_on");
			}
		}
	}
}
ragdoll_impact_watch_start(localClientNum, set, newEnt)
{
	if(set)
	{
		self thread ragdoll_impact_watch(localClientNum);
	}
}
ragdoll_impact_watch(localClientNum)
{
	self endon("entityshutdown");

	//println("^2 ragdoll_impact_watch");

	waitTime = .016; //update rate (seconds)
	gibSpeed = 500; //units/sec

	prevOrigin = self.origin;
	realwait(waitTime);

	prevVel = self.origin - prevOrigin;
	prevSpeed = length(prevVel);
	prevOrigin = self.origin;
	realwait(waitTime);

	firstloop = true;
	while(1)
	{
		vel = self.origin - prevOrigin;
		speed = length(vel);

		//println("^2 vel: " + vel + " vs " +prevVel);
		//println("^2 speed Delta: " + (speed - prevSpeed) + "(" + speed + "-" + prevSpeed + ")");

		//Gib if our speed slows suddenly
		if(speed<prevSpeed*.5 && prevSpeed>gibSpeed*waitTime)
		{
			//println("^1 Gib" );
			dir = VectorNormalize(prevVel);
			self gib_ragdoll(localClientNum, dir);
			break;
		}

		if(prevSpeed<gibSpeed*waitTime && !firstloop)
		{
			//println("^2 No Gib" );
			break;
		}

		prevOrigin = self.origin;
		prevVel = vel;
		prevSpeed = speed;
		firstloop = false;
		realwait(waitTime);
	}
}

gib_ragdoll(localClientNum, hitDir)
{
	if(is_mature())
	{
		waterHeight = GetWaterHeight(self.origin);
		//println("^2 Water Height: " + waterHeight);
		//println("^2 Zombie Height: " + self.origin[2]);
		if((waterHeight+10) < self.origin[2])
		{
			playFx(localClientNum, level._effect[ "rag_doll_gib_mini" ], self.origin, hitDir*-1);
		}
		else
		{
			//println("^2 Gib FX skipped, under water");
		}
	}
}


maze_floor_controller_rumble( localClientNum, set, newEnt )
{
	// if it isn't the player who should get the rumble then exit
	player = getlocalplayers()[ localClientNum ];

	if( player GetEntityNumber() != self GetEntityNumber() )
	{
		return;
	}

	if( set )
	{
		// start the rumble on the player
		self thread maze_rumble_while_floor_shakes( localClientNum );
	}
	else
	{
		// clear the rumble on the player
		self notify( "stop_maze_rumble" );
		self StopRumble( localClientNum, "slide_rumble" );
	}

}

maze_rumble_while_floor_shakes( int_client_num )
{
	self endon( "stop_maze_rumble" );

	while( IsDefined( self ) )
	{
		self PlayRumbleOnEntity( int_client_num, "slide_rumble" );
		wait( 0.05 );
	}
}

//------------------------------------------------------------------------------
// DCS: setting up fog change for Enricco when entering waterfall
//------------------------------------------------------------------------------
waterfall_triggers_init()
{
	waitforallclients();
	trigs = GetEntArray(0, "waterfall_fog_change","targetname");

	if(!IsDefined(trigs))
	return;

	for ( i = 0; i < trigs.size; i++ )
	{
		trigs[i] thread waterfall_fog_trigger();
	}
}
waterfall_fog_trigger()
{
	while(1)
	{
		self waittill("trigger", who);

		if(who IsLocalPlayer())
		{
	    start_dist = 257.581;
	    half_dist = 3581.88;
	    half_height = 461.457;
	    base_height = -652.425;
    	fog_r = 0.0784314;
  	  fog_g = 0.129412;
	    fog_b = 0.105882;
	    fog_scale = 5.97369;
			sun_col_r = 1;
			sun_col_g = 0.380392;
			sun_col_b = 0.109804;
	    sun_dir_x = -0.893398;
	    sun_dir_y = -0.219239;
	    sun_dir_z = 0.392141;
	    sun_start_ang = 11.4807;
	    sun_stop_ang = 91.2748;
	    time = 2;
	    max_fog_opacity = 0.590773;

			println("*** Client : changing to waterfall fog");

			setVolFogForClient(who GetLocalClientNumber(),start_dist, half_dist, half_height, base_height, fog_r, fog_g, fog_b, fog_scale,
			sun_col_r, sun_col_g, sun_col_b, sun_dir_x, sun_dir_y, sun_dir_z, sun_start_ang,
			sun_stop_ang, time, max_fog_opacity);
		}
	}
}
