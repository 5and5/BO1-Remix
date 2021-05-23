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

main()
{
	include_weapons();
	level._uses_crossbow = true;

	// _load!
	clientscripts\_zombiemode::main();

	//println("Registering zombify");
	clientscripts\_utility::registerSystem("zombify", ::zombifyHandler);

	clientscripts\zombie_cod5_prototype_fx::main();
	thread clientscripts\zombie_cod5_prototype_amb::main();

	// This needs to be called after all systems have been registered.
	thread waitforclient(0);

	register_zombie_types();


	println("*** Client : zombie running...or is it chasing? Muhahahaha");
}

register_zombie_types()
{
	character\clientscripts\c_ger_honorguard_zt::register_gibs();	
}

include_weapons()
{
	include_weapon( "m1911_zm", false );						// colt
	include_weapon("python_zm", false);
	include_weapon("cz75_zm");
	include_weapon("g11_lps_zm", false);
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

	include_weapon( "zombie_m1carbine", false );
	include_weapon( "zombie_thompson", false );
	include_weapon( "zombie_kar98k", false );
	include_weapon( "kar98k_scoped_zombie", false );
	include_weapon( "stielhandgranate", false );
	include_weapon( "zombie_doublebarrel", false );
	include_weapon( "zombie_doublebarrel_sawed", false );
	include_weapon( "zombie_shotgun", false );
	include_weapon( "zombie_bar", false );

	include_weapon( "zombie_cymbal_monkey");

	include_weapon( "ray_gun_zm" );
	include_weapon( "thundergun_zm" );
	include_weapon( "m1911_upgraded_zm", false );
}


