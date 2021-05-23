// Test clientside script for mak

#include clientscripts\_utility;
#include clientscripts\_music;
#include clientscripts\_zombiemode_weapons;

zombie_monitor(clientNum)
{
	self endon("disconnect");
	self endon("zombie_off");
	
	while(1)
	{
		if(isdefined(self.zombifyFX))
		{
			playfx(clientNum, level._effect["zombie_grain"], self.origin);
		}
		realwait(0.1);		
	}
}

zombifyHandler(clientNum, newState, oldState)
{
	player = getlocalplayers()[clientNum];
		
	if(newState == "1")
	{
		if(!isdefined(player.zombifyFX))	// We're not already in zombie mode.
		{
			player.zombifyFX = 1;
			player thread zombie_monitor(clientNum);	// thread a monitor on it.
			println("Zombie effect on");
		}
	}
	else if(newState == "0")
	{
		if(isdefined(player.zombifyFX))		// We're already in zombie mode.
		{
				player.zombifyFX = undefined;
				self notify("zombie_off");	// kill the monitor thread
				println("Zombie effect off");
		}
	}
}

factory_ZPO_listener()
{
	while(1)
	{
		level waittill("ZPO");	// Zombie Power On!
		
		level notify( "revive_on" );
		level notify( "fast_reload_on" );
		level notify( "doubletap_on" );
		level notify( "jugger_on" );
		level notify( "pl1" );
	}
}

main()
{
	include_weapons();

	level._uses_crossbow = true;

	clientscripts\_lights::register_light_type("light_electric", ::triggered_lights_think);

	// _load!
	clientscripts\_zombiemode::main();

	//println("Registering zombify");
	clientscripts\_utility::registerSystem("zombify", ::zombifyHandler);

	clientscripts\zombie_cod5_factory_teleporter::main();

	clientscripts\zombie_cod5_factory_fx::main();
	
	// use _waw version of the tesla script as we're using the waw tesla weapon

	thread clientscripts\zombie_cod5_factory_amb::main();

	// This needs to be called after all systems have been registered.
	thread waitforclient(0);

	register_zombie_types();

	level thread factory_ZPO_listener();

	println("*** Client : zombie running...or is it chasing? Muhahahaha");
	
}

register_zombie_types()
{
	character\clientscripts\c_ger_honorguard_zt::register_gibs();	
}

include_weapons()
{
	include_weapon("m1911_zm", false);
	include_weapon("python_zm", false);
	include_weapon("cz75_zm");
	include_weapon("g11_lps_zm");
	include_weapon("famas_zm");
	include_weapon("spectre_zm");
	include_weapon("cz75dw_zm");
	include_weapon("spas_zm", false);
	include_weapon("hs10_zm", false);
	include_weapon("aug_acog_zm");
	include_weapon("galil_zm");
	include_weapon("commando_zm");
	include_weapon("fnfal_zm");
	include_weapon("dragunov_zm", false);
	include_weapon("l96a1_zm", false);
	include_weapon("rpk_zm");
	include_weapon("hk21_zm");
	include_weapon("m72_law_zm", false);
	include_weapon("china_lake_zm", false);
	include_weapon("zombie_cymbal_monkey");
	include_weapon("crossbow_explosive_zm");
	include_weapon("knife_ballistic_zm");
	include_weapon("knife_ballistic_bowie_zm", false);

	include_weapon("m1911_upgraded_zm", false);
	include_weapon("python_upgraded_zm", false);
	include_weapon("cz75_upgraded_zm", false);
	include_weapon("g11_lps_upgraded_zm", false);
	include_weapon("famas_upgraded_zm", false);
	include_weapon("spectre_upgraded_zm", false);
	include_weapon("cz75dw_upgraded_zm", false);
	include_weapon("spas_upgraded_zm", false);
	include_weapon("hs10_upgraded_zm", false);
	include_weapon("aug_acog_mk_upgraded_zm", false);
	include_weapon("galil_upgraded_zm", false);
	include_weapon("commando_upgraded_zm", false);
	include_weapon("fnfal_upgraded_zm", false);
	include_weapon("dragunov_upgraded_zm", false);
	include_weapon("l96a1_upgraded_zm", false);
	include_weapon("rpk_upgraded_zm", false);
	include_weapon("hk21_upgraded_zm", false);
	include_weapon("m72_law_upgraded_zm", false);
	include_weapon("china_lake_upgraded_zm", false);
	include_weapon("crossbow_explosive_upgraded_zm", false);
	include_weapon("knife_ballistic_upgraded_zm", false);
	include_weapon("knife_ballistic_bowie_upgraded_zm", false);


	// Bolt Action
	include_weapon( "zombie_kar98k", false );
	include_weapon( "zombie_kar98k_upgraded", false );

	// Semi Auto
	include_weapon( "zombie_m1carbine", false );
	include_weapon( "zombie_m1carbine_upgraded", false );
	include_weapon( "zombie_gewehr43", false );
	include_weapon( "zombie_gewehr43_upgraded", false );

	// Full Auto
	include_weapon( "zombie_stg44", false );
	include_weapon( "zombie_stg44_upgraded", false );
	include_weapon( "zombie_thompson", false );
	include_weapon( "zombie_thompson_upgraded", false );
	include_weapon( "mp40_zm", false );
	include_weapon( "mp40_upgraded_zm", false );
	include_weapon( "zombie_type100_smg", false );
	include_weapon( "zombie_type100_smg_upgraded", false );

	// Grenade
	include_weapon( "stielhandgranate", false );

	// Shotgun
	include_weapon( "zombie_doublebarrel", false );
	include_weapon( "zombie_doublebarrel_upgraded", false );
	include_weapon( "zombie_shotgun", false );
	include_weapon( "zombie_shotgun_upgraded", false );

	include_weapon( "zombie_fg42", false );
	include_weapon( "zombie_fg42_upgraded", false );

	// Special
	include_weapon( "ray_gun_zm", true );
	include_weapon( "ray_gun_upgraded_zm", false );
	include_weapon( "tesla_gun_zm", true );
	include_weapon( "tesla_gun_upgraded_zm", false );
	include_weapon( "zombie_cymbal_monkey", true );

	//bouncing betties
	include_weapon("mine_bouncing_betty", false);

}

triggered_lights_think(light_struct)
{		
	level waittill( "pl1" );	// power lights on

	// Turn the lights on
	if ( IsDefined( self.script_float ) )
	{
		clientscripts\_lights::set_light_intensity( light_struct, self.script_float );
	}
	else
	{
		clientscripts\_lights::set_light_intensity( light_struct, 1.5 );
	}	
}


