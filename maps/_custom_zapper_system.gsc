#include common_scripts\utility; 
#include maps\_utility;
#include maps\_zombiemode_utility;

init()
{	
	level._effect["zapper1"]					= loadfx("misc/fx_zombie_electric_trap1");
	level.trap_duration = 25;

	wait 1;

	thread add_zapper("zapper1", 1000, "enter_zone1");
	thread add_zapper("zapper2", 1000, "enter_zone4");
}
add_zapper(zapper_name, cost, flag)
{
	triggers = getentarray(zapper_name + "_trigger", "targetname");
	handles = getentarray(zapper_name + "_handle", "targetname");
	lights = getentarray(zapper_name + "_light", "targetname");
	damage_trigs = getentarray(zapper_name + "_damage", "targetname");
	fx_structs = getentarray(zapper_name + "_struct", "targetname");
	
	if(!isDefined(cost))
		cost = 1000;
	
	triggers wait_for_power(cost);

	if(isDefined(flag))
	{
		triggers handle_zapper_trigs(handles, "disable");
		zapper_light_red( lights );
		flag_wait( flag );
		triggers handle_zapper_trigs(handles, "enable");
	}
	zapper_light_green( lights );
	
	while(1)
	{
		wait 0.01;
		player = undefined;
		notifier_struct = spawnStruct();
		for(i=0;i<triggers.size;i++)
		{
			triggers[i] thread wait_until_zapper_trigged(notifier_struct);
		}
		notifier_struct waittill("trigger", player);
		notifier_struct delete();
		if( player.score < cost )
		{
			play_sound_at_pos( "no_purchase", player.origin );
			continue;
		}
		play_sound_at_pos( "purchase", player.origin );
		player maps\_zombiemode_score::minus_to_player_score( cost );
		triggers handle_zapper_trigs(handles, "disable");
		wait 0.7;
		zapper_light_red( lights );
		array_thread(fx_structs,::zapperFx,zapper_name);
		damage_trigs do_damage(zapper_name);
		wait(level.trap_duration);
		level notify(zapper_name + "_end");
		wait(level.trap_duration);
		triggers handle_zapper_trigs(handles, "enable");
		zapper_light_green( lights );
		wait 0.7;
	}
}
do_damage(name)
{
	for(i=0;i<self.size;i++)
		self[i] thread barrier_do_damage(name);
}
barrier_do_damage(name)
{
	level endon(name + "_end");

	while(1)
	{
		self waittill("trigger",who);

		if(isplayer(who) )
		{
			who thread player_elec_damage();
		}
		else
		{
			who thread zombie_elec_death( randomint(100) );
		}
	}
}
zapperFx(name)
{
	self.tag_origin = spawn("script_model",self.origin);
	self.tag_origin setmodel("tag_origin");
	playfxontag(level._effect["zapper1"],self.tag_origin,"tag_origin");
	self.tag_origin playsound("zmb_elec_start");
	self.tag_origin playloopsound("zmb_elec_loop");
	self thread play_electrical_sound();
	
	level waittill(name + "_end");
	for(i=0;i<self.size;i++)
	{
		self.tag_origin stoploopsound();
		self notify ("arc_done");
		self.tag_origin delete();
	}
}
play_electrical_sound()
{
	self endon ("arc_done");
	while(1)
	{	
		wait(randomfloatrange(0.1, 0.5));
		playsoundatposition("zmb_elec_arc", self.origin);
	}
}
handle_zapper_trigs(handles, type)
{
	for(i=0;i<self.size;i++)
	{
		if(type == "disable")
			self[i] disable_trigger();
		else if(type == "enable")
			self[i] enable_trigger();	
	}
	for(i=0;i<handles.size;i++)
	{
		if(type == "disable")
			handles[i] disable_zapper_switch();
		else if(type == "enable")
			handles[i] enable_zapper_switch();
	}
}
zapper_light_red( zapper_lights )
{
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_red");	

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}

		zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_red", 2, "script_model", zapper_lights[i].origin );
		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);
		playfxontag(level._effect["zapper_light_notready"],zapper_lights[i].fx,"tag_origin");
	}
}
zapper_light_green( zapper_lights )
{
	for(i=0;i<zapper_lights.size;i++)
	{
		zapper_lights[i] setmodel("zombie_zapper_cagelight_green");	

		if(isDefined(zapper_lights[i].fx))
		{
			zapper_lights[i].fx delete();
		}

		zapper_lights[i].fx = maps\_zombiemode_net::network_safe_spawn( "trap_light_green", 2, "script_model", zapper_lights[i].origin );
		zapper_lights[i].fx setmodel("tag_origin");
		zapper_lights[i].fx.angles = zapper_lights[i].angles+(-90,0,0);
		playfxontag(level._effect["zapper_light_ready"],zapper_lights[i].fx,"tag_origin");
	}
}
wait_for_power(cost)
{
	for(i=0;i<self.size;i++)
	{
		self[i] SetHintString( "Trap is currently unavailable" );
		self[i] SetCursorHint( "HINT_NOICON" );
	}
	flag_wait( "power_on" );
	
	for(i=0;i<self.size;i++)
		self[i] SetHintString( "Press & hold &&1 to activate the electric barrier [Cost: "+cost+"]" ); //&"ZOMBIE_BUTTON_BUY_TRAP"
}
enable_zapper_switch()
{
	self rotatepitch(-180,.5);
	self playsound("switch_flip");
}
disable_zapper_switch()
{
	self rotatepitch(180,.5);
	self playsound("switch_flip");
}
wait_until_zapper_trigged(struct)
{
	self waittill("trigger", who);
	struct notify("trigger", who);
}

//*****************************************************************************
// From _zombiemode_traps
//*****************************************************************************
zombie_elec_death(flame_chance)
{	
	self endon("death");
	
	self.marked_for_death = true;

	if ( IsDefined( self.animname ) && self.animname != "zombie_dog" )
	{
		// 10% chance the zombie will burn, a max of 6 burning zombs can be going at once
		// otherwise the zombie just gibs and dies
		if( (flame_chance > 90) && (level.burning_zombies.size < 6) )
		{
			level.burning_zombies[level.burning_zombies.size] = self;
			self thread zombie_flame_watch();
			self playsound("ignite");
			self thread animscripts\zombie_death::flame_death_fx();
			wait( randomfloat(1.25) );
		}
		else
		{
			refs[0] = "guts";
			refs[1] = "right_arm"; 
			refs[2] = "left_arm"; 
			refs[3] = "right_leg"; 
			refs[4] = "left_leg"; 
			refs[5] = "no_legs";
			refs[6] = "head";
			self.a.gib_ref = refs[randomint(refs.size)];
			
			playsoundatposition("zmb_zombie_arc", self.origin);
			
			if(randomint(100) > 50 )
			{
				self thread electroctute_death_fx();
				self thread play_elec_vocals();
			}
			
			wait(randomfloat(1.25));
			self playsound("zmb_zombie_arc");
		}
	}

	// custom damage
	level notify( "trap_kill", self );
	self dodamage(self.health + 666, self.origin);
}
player_elec_damage()
{	
	self endon("death");
	self endon("disconnect");
	
	if( !IsDefined(level.elec_loop) )
	{
		level.elec_loop = 0;
	}	
	
	if( !isDefined(self.is_burning) && !self maps\_laststand::player_is_in_laststand() )
	{
		self.is_burning = 1;		
		self setelectrified(1.25);
		
		if(level.elec_loop == 0)
		{	
			elec_loop = 1;
			self playsound("zmb_zombie_arc");
		}
		
		if(self hasperk("specialty_flakjacket"))
		{
			wait(.1);
		}
		else if(!self hasperk("specialty_armorvest") || self.health - 100 < 1)
		{
			radiusdamage(self.origin,10,self.health + 100,self.health + 100);
		}
		else
		{
			self dodamage(50, self.origin);
			wait(.1);
		}
		self.is_burning = undefined;
	}
}
zombie_flame_watch()
{
	self waittill("death");
	self stoploopsound();
	level.burning_zombies = array_remove_nokeys(level.burning_zombies,self);
}
play_elec_vocals()
{
	if( IsDefined (self) )
	{
		org = self.origin;
		wait(0.15);
		playsoundatposition("zmb_elec_vocals", org);
		playsoundatposition("zmb_zombie_arc", org);
		playsoundatposition("zmb_exp_jib_zombie", org);
	}
}
electroctute_death_fx()
{
	self endon( "death" );

	if (isdefined(self.is_electrocuted) && self.is_electrocuted )
	{
		return;
	}

	self.is_electrocuted = true;
	
	self thread electrocute_timeout();
		
	// JamesS - this will darken the burning body
	//self StartTanning(); 
	if(self.team == "axis")
	{
		level.bcOnFireTime = gettime();
		level.bcOnFireOrg = self.origin;
	}
	
	PlayFxOnTag( level._effect["elec_torso"], self, "J_SpineLower" );
	self playsound ("zmb_elec_jib_zombie");
	wait 1;

	tagArray = []; 
	tagArray[0] = "J_Elbow_LE"; 
	tagArray[1] = "J_Elbow_RI"; 
	tagArray[2] = "J_Knee_RI"; 
	tagArray[3] = "J_Knee_LE"; 
	tagArray = array_randomize( tagArray ); 

	PlayFxOnTag( level._effect["elec_md"], self, tagArray[0] ); 
	self playsound ("zmb_elec_jib_zombie");

	wait 1;
	self playsound ("zmb_elec_jib_zombie");

	tagArray[0] = "J_Wrist_RI"; 
	tagArray[1] = "J_Wrist_LE"; 
	if( !IsDefined( self.a.gib_ref ) || self.a.gib_ref != "no_legs" )
	{
		tagArray[2] = "J_Ankle_RI"; 
		tagArray[3] = "J_Ankle_LE"; 
	}
	tagArray = array_randomize( tagArray ); 

	PlayFxOnTag( level._effect["elec_sm"], self, tagArray[0] ); 
	PlayFxOnTag( level._effect["elec_sm"], self, tagArray[1] );
}
electrocute_timeout()
{
	self endon ("death");
	self playloopsound("fire_manager_0");
	// about the length of the flame fx
	wait 12;
	self stoploopsound();
	if (isdefined(self) && isalive(self))
	{
		self.is_electrocuted = false;
		self notify ("stop_flame_damage");
	}
	
}

