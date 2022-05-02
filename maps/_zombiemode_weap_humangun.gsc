#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;

#using_animtree( "generic_human" );

init()
{
	if ( !maps\_zombiemode_weapons::is_weapon_included( "humangun_zm" ) )
	{
		return;
	}

    level.insta_time = 0;

	level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE = 11;
	level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE = 11;//10

	level._ZOMBIE_ACTOR_FLAG_HUMANGUN_HIT_RESPONSE = 12;
	level._ZOMBIE_ACTOR_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE = 11;

	maps\_zombiemode::register_player_damage_callback( ::humangun_player_damage_response );
	maps\_zombiemode_spawner::register_zombie_damage_callback( ::humangun_zombie_damage_response );
	maps\_zombiemode_spawner::register_zombie_death_animscript_callback( ::humangun_zombie_death_response );

	precachemodel( "c_usa_pent_ciaagent_body" );
	precachemodel( "c_zom_head_human" );

	// WW (02-11-11): Array for humanized zombies
	level._zombie_using_humangun = true;
	level._zombie_human_array = [];

	set_zombie_var( "humangun_player_ignored_time",		10 );
	set_zombie_var( "humangun_zombie_explosion_delay",	5 );

	level._effect["humangun_viewmodel_reload"]			= LoadFX( "weapon/human_gun/fx_hgun_reload" );
	level._effect["humangun_viewmodel_reload_upgraded"]	= LoadFX( "weapon/human_gun/fx_hgun_reload_ug" );
	level._effect["humangun_glow_neck"]					= LoadFX( "weapon/human_gun/fx_hgun_1st_hit_glow_zombie" );
	level._effect["humangun_glow_neck_upgraded"]		= LoadFX( "weapon/human_gun/fx_hgun_1st_hit_glow_zombie_ug" );
	level._effect["humangun_glow_neck_critical"]		= LoadFX( "weapon/human_gun/fx_hgun_timer_glow_zombie_ug" );
	level._effect["humangun_glow_spine_upgraded"]		= LoadFX( "weapon/human_gun/fx_hgun_2nd_hit_glow_zombie_ug" );
	level._effect["humangun_explosion"]					= LoadFX( "weapon/human_gun/fx_hgun_explosion_ug" );
	level._effect["humangun_explosion_death_mist"]		= loadfx( "maps/zombie/fx_zmb_coast_jackal_death" );

	humangun_init_human_zombie_anims();

	level thread humangun_on_player_connect();
}


#using_animtree( "generic_human" );
humangun_init_human_zombie_anims()
{
	// run cycles
	level.scr_anim["human_zombie"]["walk1"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["walk2"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["walk3"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["walk4"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["walk5"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["walk6"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["walk7"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["walk8"] = %ai_zombie_humangun_run_b;

	level.scr_anim["human_zombie"]["run1"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["run2"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["run3"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["run4"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["run5"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["run6"] = %ai_zombie_humangun_run_b;

	level.scr_anim["human_zombie"]["sprint1"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["sprint2"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["sprint3"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["sprint4"] = %ai_zombie_humangun_run_b;
	level.scr_anim["human_zombie"]["sprint5"] = %ai_zombie_humangun_run_a;
	level.scr_anim["human_zombie"]["sprint6"] = %ai_zombie_humangun_run_b;

//	// run cycles in prone
//	level.scr_anim["human_zombie"]["crawl1"] 	= %ai_zombie_crawl;
//	level.scr_anim["human_zombie"]["crawl2"] 	= %ai_zombie_crawl_v1;
//	level.scr_anim["human_zombie"]["crawl3"] 	= %ai_zombie_crawl_v2;
//	level.scr_anim["human_zombie"]["crawl4"] 	= %ai_zombie_crawl_v3;
//	level.scr_anim["human_zombie"]["crawl5"] 	= %ai_zombie_crawl_v4;
//	level.scr_anim["human_zombie"]["crawl6"] 	= %ai_zombie_crawl_v5;
//	level.scr_anim["human_zombie"]["crawl_hand_1"] = %ai_zombie_walk_on_hands_a;
//	level.scr_anim["human_zombie"]["crawl_hand_2"] = %ai_zombie_walk_on_hands_b;
//
//	level.scr_anim["human_zombie"]["crawl_sprint1"] 	= %ai_zombie_crawl_sprint;
//	level.scr_anim["human_zombie"]["crawl_sprint2"] 	= %ai_zombie_crawl_sprint_1;
//	level.scr_anim["human_zombie"]["crawl_sprint3"] 	= %ai_zombie_crawl_sprint_2;

	// tesla deaths
	if( !isDefined( level._zombie_tesla_death ) )
	{
		level._zombie_tesla_death = [];
	}
	level._zombie_tesla_death["human_zombie"] = [];
	level._zombie_tesla_death["human_zombie"][0] = %ai_zombie_tesla_death_a;
	level._zombie_tesla_death["human_zombie"][1] = %ai_zombie_tesla_death_b;
	level._zombie_tesla_death["human_zombie"][2] = %ai_zombie_tesla_death_c;
	level._zombie_tesla_death["human_zombie"][3] = %ai_zombie_tesla_death_d;
	level._zombie_tesla_death["human_zombie"][4] = %ai_zombie_tesla_death_e;

	if( !isDefined( level._zombie_tesla_crawl_death ) )
	{
		level._zombie_tesla_crawl_death = [];
	}
	level._zombie_tesla_crawl_death["human_zombie"] = [];
	level._zombie_tesla_crawl_death["human_zombie"][0] = %ai_zombie_tesla_crawl_death_a;
	level._zombie_tesla_crawl_death["human_zombie"][1] = %ai_zombie_tesla_crawl_death_b;

	// thundergun knockdowns and getups
	if( !isDefined( level._zombie_knockdowns ) )
	{
		level._zombie_knockdowns = [];
	}
	level._zombie_knockdowns["human_zombie"] = [];
	level._zombie_knockdowns["human_zombie"]["front"] = [];

	level._zombie_knockdowns["human_zombie"]["front"]["no_legs"] = [];
	level._zombie_knockdowns["human_zombie"]["front"]["no_legs"][0] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["no_legs"][1] = %ai_zombie_thundergun_hit_doublebounce;
	level._zombie_knockdowns["human_zombie"]["front"]["no_legs"][2] = %ai_zombie_thundergun_hit_forwardtoface;

	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"] = [];

	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][0] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][1] = %ai_zombie_thundergun_hit_doublebounce;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][2] = %ai_zombie_thundergun_hit_upontoback;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][3] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][4] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][5] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][6] = %ai_zombie_thundergun_hit_stumblefall;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][7] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][8] = %ai_zombie_thundergun_hit_doublebounce;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][9] = %ai_zombie_thundergun_hit_upontoback;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][10] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][11] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][12] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][13] = %ai_zombie_thundergun_hit_deadfallknee;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][14] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][15] = %ai_zombie_thundergun_hit_doublebounce;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][16] = %ai_zombie_thundergun_hit_upontoback;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][17] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][18] = %ai_zombie_thundergun_hit_armslegsforward;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][19] = %ai_zombie_thundergun_hit_forwardtoface;
	level._zombie_knockdowns["human_zombie"]["front"]["has_legs"][20] = %ai_zombie_thundergun_hit_flatonback;

	level._zombie_knockdowns["human_zombie"]["left"] = [];
	level._zombie_knockdowns["human_zombie"]["left"][0] = %ai_zombie_thundergun_hit_legsout_right;

	level._zombie_knockdowns["human_zombie"]["right"] = [];
	level._zombie_knockdowns["human_zombie"]["right"][0] = %ai_zombie_thundergun_hit_legsout_left;

	level._zombie_knockdowns["human_zombie"]["back"] = [];
	level._zombie_knockdowns["human_zombie"]["back"][0] = %ai_zombie_thundergun_hit_faceplant;

	if( !isDefined( level._zombie_getups ) )
	{
		level._zombie_getups = [];
	}
	level._zombie_getups["human_zombie"] = [];
	level._zombie_getups["human_zombie"]["back"] = [];

	level._zombie_getups["human_zombie"]["back"]["early"] = [];
	level._zombie_getups["human_zombie"]["back"]["early"][0] = %ai_zombie_thundergun_getup_b;
	level._zombie_getups["human_zombie"]["back"]["early"][1] = %ai_zombie_thundergun_getup_c;

	level._zombie_getups["human_zombie"]["back"]["late"] = [];
	level._zombie_getups["human_zombie"]["back"]["late"][0] = %ai_zombie_thundergun_getup_b;
	level._zombie_getups["human_zombie"]["back"]["late"][1] = %ai_zombie_thundergun_getup_c;
	level._zombie_getups["human_zombie"]["back"]["late"][2] = %ai_zombie_thundergun_getup_quick_b;
	level._zombie_getups["human_zombie"]["back"]["late"][3] = %ai_zombie_thundergun_getup_quick_c;

	level._zombie_getups["human_zombie"]["belly"] = [];

	level._zombie_getups["human_zombie"]["belly"]["early"] = [];
	level._zombie_getups["human_zombie"]["belly"]["early"][0] = %ai_zombie_thundergun_getup_a;

	level._zombie_getups["human_zombie"]["belly"]["late"] = [];
	level._zombie_getups["human_zombie"]["belly"]["late"][0] = %ai_zombie_thundergun_getup_a;
	level._zombie_getups["human_zombie"]["belly"]["late"][1] = %ai_zombie_thundergun_getup_quick_a;

	// freezegun deaths
	if( !isDefined( level._zombie_freezegun_death ) )
	{
		level._zombie_freezegun_death = [];
	}
	level._zombie_freezegun_death["human_zombie"] = [];
	level._zombie_freezegun_death["human_zombie"][0] = %ai_zombie_freeze_death_a;
	level._zombie_freezegun_death["human_zombie"][1] = %ai_zombie_freeze_death_b;
	level._zombie_freezegun_death["human_zombie"][2] = %ai_zombie_freeze_death_c;
	level._zombie_freezegun_death["human_zombie"][3] = %ai_zombie_freeze_death_d;
	level._zombie_freezegun_death["human_zombie"][4] = %ai_zombie_freeze_death_e;

	if( !isDefined( level._zombie_freezegun_death_missing_legs ) )
	{
		level._zombie_freezegun_death_missing_legs = [];
	}
	level._zombie_freezegun_death_missing_legs["human_zombie"] = [];
	level._zombie_freezegun_death_missing_legs["human_zombie"][0] = %ai_zombie_crawl_freeze_death_01;
	level._zombie_freezegun_death_missing_legs["human_zombie"][1] = %ai_zombie_crawl_freeze_death_02;

	// deaths
	if( !isDefined( level._zombie_deaths ) )
	{
		level._zombie_deaths = [];
	}
	level._zombie_deaths["human_zombie"] = [];
	level._zombie_deaths["human_zombie"][0] = %ch_dazed_a_death;
	level._zombie_deaths["human_zombie"][1] = %ch_dazed_b_death;
	level._zombie_deaths["human_zombie"][2] = %ch_dazed_c_death;
	level._zombie_deaths["human_zombie"][3] = %ch_dazed_d_death;


	if( !isDefined( level._zombie_humangun_react ) )
	{
		level._zombie_humangun_react = [];
	}

	level._zombie_humangun_react["zombie"] = [];

	level._zombie_humangun_react["zombie"][0] = %ai_zombie_humangun_react;
}


humangun_on_player_connect()
{
	for( ;; )
	{
		level waittill( "connecting", player );
		player thread wait_for_humangun_fired();
        player thread maps\_custom_hud::instakill_timer_hud();
	}
}


wait_for_humangun_fired()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );

	/*for( ;; )
	{
		self waittill( "weapon_fired" );
		currentweapon = self GetCurrentWeapon();
		if( ( currentweapon == "humangun_zm" ) || ( currentweapon == "humangun_upgraded_zm" ) )
		{
			self thread humangun_fired( currentweapon == "humangun_upgraded_zm" );

			view_pos = self GetTagOrigin( "tag_flash" ) - self GetPlayerViewHeight();
			view_angles = self GetTagAngles( "tag_flash" );
//			playfx( level._effect["humangun_smoke_cloud"], view_pos, AnglesToForward( view_angles ), AnglesToUp( view_angles ) );
		}
	}*/

	for( ;; )
    {
        self waittill("missile_fire", grenade, weapon);

        if(weapon == "humangun_zm" || weapon == "humangun_upgraded_zm")
        {
            self thread humangun_radius_damage(grenade, weapon);
        }
    }
}

humangun_radius_damage(grenade, weapon)
{
    upgraded = weapon == "humangun_upgraded_zm";

    grenade waittill_not_moving();
    grenade_origin = grenade.origin;

    closest = undefined;
    dist = 64 * 64;
    zombs = GetAiSpeciesArray( "axis", "all" );
    players = get_players();
    ents = array_combine(zombs, players);
    ents = get_array_of_closest(grenade_origin, ents);
    valid_ents = [];
    valid_players = [];
    valid_zombs = [];
    for (i = 0; i < ents.size; i++)
    {
        // out of range, all other ents will be also
        if(DistanceSquared(grenade_origin, ents[i].origin) > dist)
        {
            break;
        }

        if(!ents[i] DamageConeTrace(grenade_origin, self))
        {
            continue;
        }

        valid_ents[valid_ents.size] = ents[i];
        if(IsPlayer(ents[i]))
        {
            valid_players[valid_players.size] = ents[i];
        }
        else
        {
            valid_zombs[valid_zombs.size] = ents[i];
        }

        // only need 1 of each max
        if(valid_players.size > 0 && valid_zombs.size > 0)
        {
            break;
        }
    }

    if(valid_ents.size > 0)
    {
        closest = valid_ents[0];
        // HACK - sometimes chooses player when it should choose zombie when both are close
        if(valid_players.size > 0 && valid_zombs.size > 0 && valid_ents[0] != valid_zombs[0])
        {
            if(DistanceSquared(grenade_origin, valid_players[0].origin) < 32 * 32)
            {
                closest = valid_players[0];
            }
            else
            {
                closest = valid_zombs[0];
            }
        }
    }

    if(IsDefined(closest))
    {
        if(IsPlayer(closest))
        {
            closest thread humangun_player_hit_response( self, upgraded );
        }
        else if(IsAI(closest))
        {
            if(IsDefined(closest.animname) && closest.animname == "director_zombie")
            {
                closest thread maps\_zombiemode_ai_director::director_humangun_hit_response( upgraded );
            }
            else
            {
                closest thread humangun_zombie_hit_response_internal( "MOD_IMPACT", weapon, self );
            }
        }
    }
}


humangun_fired( upgraded )
{
}


humangun_player_ignored_timer_cleanup( upgraded )
{

	if ( !upgraded )
	{
		self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE );
	}
	else
	{
		self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
	}

	self.point_split_receiver = undefined;
	self.point_split_keep_percent = undefined;
	self.personal_instakill = false;

	self.humangun_player_ignored_timer = 0;
	self notify( "humangun_player_ignored_timer_done" );
}


humangun_player_ignored_timer_clear( upgraded )
{
	self endon( "humangun_player_ignored_timer_done" );
	self endon( "disconnect" );

	self waittill_any( "player_downed", "spawned_spectator" );

	humangun_player_ignored_timer_cleanup( upgraded );
}


humangun_player_ignored_timer( owner, upgraded )
{
	self endon( "humangun_player_ignored_timer_done" );
	self endon( "player_downed" );
	self endon( "spawned_spectator" );
	self endon( "disconnect" );

	self thread humangun_player_ignored_timer_clear( upgraded );
	self thread humangun_player_effects_audio();

	self.ignoreme = false;

	self.point_split_receiver = owner;
	if ( !upgraded )
	{
		self.point_split_keep_percent = 1;
		self.personal_instakill = true;

		self setclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE );
	}
	else
	{
		self.point_split_keep_percent = 1;
		self.personal_instakill = true;

		self setclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
	}

	enemy_zombies = GetAiSpeciesArray( "axis", "all" );
	for ( i = 0; i < enemy_zombies.size; i++ )
	{
		if ( isdefined( enemy_zombies[i].favoriteenemy ) && self == enemy_zombies[i].favoriteenemy )
		{
			enemy_zombies[i].zombie_path_timer = 0;
		}
	}

	self.humangun_player_ignored_timer = level.total_time + (level.zombie_vars["humangun_player_ignored_time"]);

	while ( level.total_time < self.humangun_player_ignored_timer )
	{
        if( level.total_time + 1 > self.humangun_player_ignored_timer)
        {
            self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_HIT_RESPONSE );
            self clearclientflag( level._ZOMBIE_PLAYER_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
        }
		wait .05;
	}

	self.ignoreme = false;
	humangun_player_ignored_timer_cleanup( upgraded );
}



humangun_player_effects_audio_cleanup_on_disconnect( sound_ent_humangun )
{
	self endon( "player_downed" );
	self endon( "spawned_spectator" );
	self endon( "humangun_player_ignored_timer_done" );

	self waittill( "disconnect" );

	sound_ent_humangun StopLoopSound( 2 );
	wait(2);
	sound_ent_humangun Delete();
}

humangun_player_effects_audio()
{
	self endon( "disconnect" );

    if( !IsDefined( self.humangun_effects_audio_isplaying ) )
    {
        self.humangun_effects_audio_isplaying = false;
    }

    if( !self.humangun_effects_audio_isplaying )
    {
        sound_ent_humangun = Spawn( "script_origin", self.origin );
        sound_ent_humangun LinkTo( self );
        sound_ent_humangun PlayLoopSound( "zmb_humangun_effect_loop", .5 );
        self thread humangun_player_effects_audio_cleanup_on_disconnect( sound_ent_humangun );

	    self waittill_any( "player_downed", "spawned_spectator", "humangun_player_ignored_timer_done" );

        self.humangun_effects_audio_isplaying = false;

	    sound_ent_humangun StopLoopSound( 2 );
	    wait(2);
	    sound_ent_humangun Delete();
	}
}


humangun_player_hit_response( owner, upgraded )
{

	if ( !isdefined( self.humangun_player_ignored_timer ) )
	{
		self.humangun_player_ignored_timer = 0;
	}

	if ( self.humangun_player_ignored_timer )
	{
		self.humangun_player_ignored_timer += (level.zombie_vars["humangun_player_ignored_time"]);
	}
	else
	{
		self thread humangun_player_ignored_timer( owner, upgraded );
	}
}


humangun_player_damage_response( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, modelIndex, psOffsetTime )
{
	if ( !self is_humangun_damage( sMeansOfDeath, sWeapon ) || self maps\_laststand::player_is_in_laststand() )
	{
		return -1; // did nothing
	}

	self thread humangun_player_hit_response( eAttacker, sWeapon == "humangun_upgraded_zm" );

	return 0;
}


humangun_zombie_damage_watcher( player )
{
	self endon( "death" );

	while ( true )
	{
		self waittill( "damage", amount, attacker );

		if ( isdefined( attacker ) && isAI( attacker ) )
		{
			player maps\_zombiemode_score::player_add_points( "damage", "MOD_MELEE", "left_hand", self.isdog );
		}
	}
}


humangun_zombie_death_watcher( player )
{
	self waittill( "death" );

	if ( isdefined( self.attacker ) && isAI( self.attacker ) )
	{
		player maps\_zombiemode_score::player_add_points( "death", "", "" );
	}
}


humangun_zombie_1st_hit_response_client_notify( upgraded )
{
	if ( self.gibbed )
	{
		// have to delay slightly to make sure the new model is set so the bone counts are finalized,
		// otherwise the effect plays at the wrong spot on the human
		wait_network_frame();
	}

	if ( !upgraded )
	{
		self setclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_HIT_RESPONSE );
	}
	else
	{
		self setclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
	}
}


humangun_zombie_get_destination_point_origin()
{
	if ( IsDefined( level._humangun_escape_override ) && check_point_in_active_zone( level._humangun_escape_override.origin ) )
	{
		// human belongs to the lighthouse if the setup is complete
		return level._humangun_escape_override.origin;
	}

	struct_array_human_spots = getstructarray( "struct_humangun_dest", "targetname" );
	struct_array_active_human_spots = [];

	for ( i = 0; i < struct_array_human_spots.size; i++ )
	{
		// check to see if the spot is in an active zone
		if ( check_point_in_active_zone( struct_array_human_spots[i].origin ) )
		{
			// if it is add it to the active array
			struct_array_active_human_spots = add_to_array( struct_array_active_human_spots, struct_array_human_spots[i], false );
		}
	}

	if ( struct_array_active_human_spots.size == 0 )
	{
/#
		iprintlnbold( "no escape structs in a playable area!" );
#/
		return self.origin;
	}

	// pick the closest point
	destination_point = getClosest( self.origin, struct_array_active_human_spots );
	return destination_point.origin;
}


humangun_zombie_1st_hit_response( upgraded, player )
{
	// turn off find flesh
	self notify( "stop_find_flesh" );
	self notify( "zombie_acquire_enemy" );
	self OrientMode( "face default" );
	self.ignoreall = true;

	self.team = "allies";
	self.aiteam = "allies";
	self.airank = undefined;
	self.name = undefined;
	self.activatecrosshair = false;

	if ( isdefined( player ) )
	{
		self.owner = player;
		self thread humangun_zombie_damage_watcher( player );
		self thread humangun_zombie_death_watcher( player );
	}

	self.zombie_faller_should_drop = true;
	self.humangun_zombie_1st_hit_response = true;
	self notify( "humangun_zombie_1st_hit_response" );
	if ( upgraded )
	{
		self.humangun_zombie_1st_hit_was_upgraded = true;
	}

	self thread humangun_zombie_1st_hit_response_client_notify( upgraded );

	// model swap
	self DetachAll();
	self.hatModel = undefined;
	self setmodel( "c_usa_pent_ciaagent_body" );
	self Attach( "c_zom_head_human", "" );

	// fix up previous gibs, and don't let them gib after this
	self.has_legs = true;
	self AllowedStances( "prone", "crouch", "stand" );
	self.gibbed = true;
	death_anims = level._zombie_deaths[self.animname];
	self.deathanim = random(death_anims);

	//remove any electrical effects
	if(isDefined(level._func_humangun_check))
	{
		self [[level._func_humangun_check]]();
	}

	//AUDIO
	self PlayLoopSound( "zmb_humangun_effect_loop" );
	self thread audio_wait_for_death();
	self thread audio_human_screams();

	if ( !is_true( self.completed_emerging_into_playable_area ) )
	{
		self waittill( "completed_emerging_into_playable_area" );

		// turn off find flesh
		self notify( "stop_find_flesh" );
		self notify( "zombie_acquire_enemy" );
		self OrientMode( "face default" );
		self.ignoreall = true;
	}

	// don't start reacting until traverse is done
	if ( is_true( self.is_traversing ) )
	{
		self waittill( "zombie_end_traverse" );
	}

	level._zombie_human_array = add_to_array( level._zombie_human_array, self, false );
	enemy_zombies = GetAiSpeciesArray( "axis", "all" );
	for ( i = 0; i < enemy_zombies.size; i++ )
	{
		if ( !isdefined( enemy_zombies[i].enemyoverride ) && isdefined( enemy_zombies[i].favoriteenemy ) )
		{
			if ( DistanceSquared( enemy_zombies[i].origin, self.origin ) < DistanceSquared( enemy_zombies[i].origin, enemy_zombies[i].favoriteenemy.origin ) )
			{
				enemy_zombies[i].zombie_path_timer = 0;
			}
		}
	}

	// for now use the taunt as a reaction
	react_anim = random( level._zombie_humangun_react[self.animname] );
	self animscripted( "zombie_react", self.origin, self.angles, react_anim, "normal", undefined, 1, 0.4 );
	waittill_notify_or_timeout( "death", getanimlength( react_anim ) );

	if ( isalive( self ) )
	{
		self.animname = "human_zombie";
		maps\_zombiemode_spawner::set_zombie_run_cycle( "sprint" );

		// send ai to a point
		self SetGoalPos( self humangun_zombie_get_destination_point_origin() );

		if ( is_true( self.humangun_zombie_2nd_hit_response ) )
		{
			return;
		}
		else
		{
			self endon( "humangun_zombie_2nd_hit_response" );
		}

		self waittill_any( "goal", "bad_path", "death" );
	}

	level._zombie_human_array = array_remove( level._zombie_human_array, self );
	if ( !upgraded )
	{
		self clearclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_HIT_RESPONSE );
	}
	else
	{
		self clearclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_UPGRADED_HIT_RESPONSE );
	}

	if ( isalive( self ) && !IsDefined( level._humangun_escape_override ) ) // any human that is the lighthouse's should not die
	{
		self.water_damage = true;
		self DoDamage( self.health + 10, self.origin );
	}
}


humangun_zombie_2nd_hit_response( player )
{
	self notify( "humangun_zombie_2nd_hit_response" );

	self.humangun_zombie_2nd_hit_response = true;
	self setclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_HIT_RESPONSE );

	self thread play_humangun_upgraded_effect_audio();

	self waittill_any_or_timeout( level.zombie_vars["humangun_zombie_explosion_delay"], "humangun_zombie_3rd_hit_response", "goal", "bad_path", "death" );

	player notify( "stuntman_achieved" );
	level._zombie_human_array = array_remove( level._zombie_human_array, self );
	radiusDamage( self.origin, 180, 10000, 10000, player, "MOD_PROJECTILE_SPLASH", "humangun_upgraded_zm" );

	// prevent them freezing the water, sice they were turned to mist
	self.water_damage = false;

	self hide();
	self clearclientflag( level._ZOMBIE_ACTOR_FLAG_HUMANGUN_HIT_RESPONSE );

	wait ( 0.4 );
	self delete();
}

play_humangun_upgraded_effect_audio()
{
    self PlaySound( "zmb_humangun_effect_timer" );
    self waittill_any_or_timeout( level.zombie_vars["humangun_zombie_explosion_delay"], "humangun_zombie_3rd_hit_response", "goal", "bad_path", "death" );
    self PlaySound( "zmb_humangun_effect_explosion" );
}
audio_wait_for_death()
{
    self waittill( "death" );
    if( IsDefined( self ) )
    {
    	self StopLoopSound( 1 );
    }

}

audio_human_screams()
{
	self endon ("death");
	self endon ("explode");
	self endon( "lighthouse_owned" );
	variant = undefined;
	last_variant = undefined;
	wait (.5);
	while (1)
	{
		variant = randomintrange(0,8);
		if (isdefined (last_variant) && variant == last_variant)
		{
			wait (.05);
			continue;
	  }
		self playsound ("vox_zmb_human_scream_" + variant, "screaming_done");
		last_variant = variant;
		self waittill ("screaming_done");
		wait (.25);
	}
}


humangun_zombie_hit_response_internal( mod, damageweapon, player )
{
	if ( !self is_humangun_damage( mod, damageweapon ) )
	{
		if ( !is_true( self.humangun_zombie_1st_hit_response ) )
		{
			return false;
		}
		else
		{
			return true; // no points for attacking the human
		}
	}

	upgraded = damageweapon == "humangun_upgraded_zm";
	if ( IsDefined( self.humangun_hit_response ) )
	{
		self thread [[ self.humangun_hit_response ]]( upgraded );
		return true;
	}

	if ( !is_true( self.humangun_zombie_1st_hit_response ) )
	{
		self thread humangun_zombie_1st_hit_response( upgraded, player );
		if ( IsDefined( player ) && IsPlayer( player ) )
		{
			player thread humangun_play_zombie_hit_vox();
		}
	}
	else if ( is_true( self.humangun_zombie_1st_hit_was_upgraded ) && upgraded )
	{
		if ( !is_true( self.humangun_zombie_2nd_hit_response ) )
		{
			self thread humangun_zombie_2nd_hit_response( player );
		}
		else
		{
			self notify( "humangun_zombie_3rd_hit_response" );
		}
	}

	return true;
}


humangun_zombie_damage_response( mod, hit_location, hit_origin, player, amount )
{
	return humangun_zombie_hit_response_internal( mod, self.damageweapon, player );
}


humangun_zombie_death_response()
{
	if ( is_true( self.humangun_zombie_1st_hit_response ) && IsDefined( self.attacker ) && IsPlayer( self.attacker ) )
	{
		self.nuked = true; // tricks the system into not awarding points if the player kills him
	}

	return false;
}


humangun_debug_print( msg, color )
{
/#
	if ( !GetDvarInt( #"scr_humangun_debug" ) )
	{
		return;
	}

	if ( !isdefined( color ) )
	{
		color = (1, 1, 1);
	}

	Print3d(self.origin + (0,0,60), msg, color, 1, 1, 40); // 10 server frames is 1 second
#/
}


is_humangun_damage( mod, weapon )
{
	return ("MOD_IMPACT" == mod && IsDefined( weapon ) && (weapon == "humangun_zm" || weapon == "humangun_upgraded_zm"));
}


humangun_play_zombie_hit_vox()
{
    rand = RandomIntRange(0,101);

    if( rand >= 20 )
    {
        self maps\_zombiemode_audio::create_and_play_dialog( "kill", "human" );
    }
}
