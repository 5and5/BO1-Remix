//
// file: zombie_ww_amb.csc
// description: clientside ambient script for zombie_ww: setup ambient sounds, etc.
//
#include clientscripts\_utility; 
#include clientscripts\_ambientpackage;
#include clientscripts\_music;
#include clientscripts\_busing;
#include clientscripts\_audio;
main()
{
 
    //**** AMBIENT PACKAGES/ROOMS ****\\
    
    //spawn
 	declareAmbientRoom( "spawn_room" );
 	declareAmbientPackage( "spawn_room" );
 	setAmbientRoomTone( "spawn_room", "amb_theater_bg" );
 	setAmbientRoomReverb ("spawn_room","zmb_theater_main_room", 1, 1);
        addAmbientElement( "spawn_room", "amb_wind_howl", 15, 60, 50, 150 );
        setAmbientRoomContext( "spawn_room", "ringoff_plr", "indoor" );

    //power
	declareAmbientRoom( "power_room" );
	declareAmbientPackage( "power_room" );
	setAmbientRoomTone( "power_room", "amb_theater_bg" );
	setAmbientRoomReverb ("power_room","zmb_theater_lobby", 1, 1);
	    addAmbientElement( "power_room", "amb_wood_groan", 15, 60, 50, 150 ); //2d_wood
	    setAmbientRoomContext( "power_room", "ringoff_plr", "indoor" );

    //outside
	declareAmbientRoom( "outside" );
	declareAmbientPackage( "outside" );
	setAmbientRoomTone( "outside", "theater_amb_loop" );
	setAmbientRoomReverb ("outside","zmb_theater_alleyway", 1, 1);
        addAmbientElement( "outside", "2d_wood", 15, 60, 50, 150 );
        setAmbientRoomContext( "outside", "ringoff_plr", "outdoor" );                                                           
// 	//Default Ambient Package
        activateAmbientPackage( 0, "outside", 0 );
        activateAmbientRoom( 0, "outside", 0 );

	declareMusicState("WAVE");
		musicAliasloop("2d_wood", 4, 2);	
		
	declareMusicState( "SILENCE" );
	    musicAlias("null", 1 );	

	//THREADED FUNCTIONS
	thread power_on_all();	
}
//POWER ON
power_on_all()
{
	level waittill( "pl1" );
	//Post power ambience
}
