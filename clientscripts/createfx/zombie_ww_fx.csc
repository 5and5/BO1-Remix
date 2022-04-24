main()
{	
	precache_createfx_fx();
	spawn_my_fx();
	clientscripts\_fx::reportNumEffects();
}

precache_createfx_fx()
{
}

spawn_my_fx()
{
    ent = clientscripts\_fx::createOneshotEffect( "fac_snow" );
    ent.v[ "origin" ] = (4800, 5700, 35);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    // ent.v[ "type" ] = "exploder";
    // ent.v[ "exploder" ] = 202;
    ent.v[ "fxid" ] = "fac_snow";
    ent.v[ "delay" ] = -15;

    ent = clientscripts\_fx::createOneshotEffect( "fx_smoke_plume_sm_fast_blk" );
    ent.v[ "origin" ] = (5265.5, 5248.2, 441);
    ent.v[ "angles" ] = ( -120, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_smoke_plume_sm_fast_blk";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_smoke_plume_sm_fast_blk" );
    ent.v[ "origin" ] = (3917.5, 5522.2, 512);
    ent.v[ "angles" ] = ( -120, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_smoke_plume_sm_fast_blk";
    ent.v[ "delay" ] = 0;

        ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4800, 6710, 32);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4424, 4426, -22);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

        ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4815, 3960, -38);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

        ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4408, 3514, -54);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;


        ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (5000, 4370, 18);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

        ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4264, 4018, -70);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

            ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4456, 4858, 2);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (5564, 6728.75, 47);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (4232, 6578, 34);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_fog_zombie_amb" );
    ent.v[ "origin" ] = (5951, 4487, 128);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_fog_zombie_amb";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_pent_tinhat_light" );
    ent.v[ "origin" ] = (5448.8, 5239.3, 233);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_pent_tinhat_light";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "fx_pent_tinhat_light" );
    ent.v[ "origin" ] = (5648.8, 5241.3, 233);
    ent.v[ "angles" ] = ( 0, 0, 0 );
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "fx_pent_tinhat_light";
    ent.v[ "delay" ] = 0;

    ent = clientscripts\_fx::createOneshotEffect( "kw_overhead" );
    ent.v[ "origin" ] = (5627.25, 5292.05, 108);
    ent.v[ "angles" ] = ( 0, 257.8, 0);
    ent.v[ "type" ] = "oneshotfx";
    ent.v[ "fxid" ] = "kw_overhead";
    ent.v[ "delay" ] = 0;
} 
