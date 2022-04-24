#include common_scripts\utility; 
#include maps\_utility;
#include maps\_ambientpackage;
#include maps\_music;
#include maps\_busing;
main()
{
    level thread setup_meteor_audio();
}
setup_meteor_audio()
{
    wait(1);
    level.meteor_counter = 0;
    level.music_override = false;
    array_thread( GetEntArray( "meteor_egg_trigger", "targetname" ), ::meteor_egg );

}

play_music_easter_egg( player )
{   
    level.music_override = true;
    level thread maps\_zombiemode_audio::change_zombie_music( "egg1" );

    wait(4);
    
    if( IsDefined( player ) )
    {
        player maps\_zombiemode_audio::create_and_play_dialog( "eggs", "music_activate" );
    }
    
    wait(80);
    level.music_override = false;
    level thread maps\_zombiemode_audio::change_zombie_music( "wave_loop" );

    level thread setup_meteor_audio();
}

meteor_egg()
{  

    if( !isdefined( self ) )
    {   
        return;
    }	
    
    self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" ); 
    //self PlayLoopSound( "zmb_meteor_loop" );
        
    self waittill( "trigger", player );
    
    self StopLoopSound( 1 );
    player PlaySound( "zmb_meteor_activate" );
    
    player maps\_zombiemode_audio::create_and_play_dialog( "eggs", "meteors", undefined, level.meteor_counter );
        
    level.meteor_counter = level.meteor_counter + 1;
    
    if( level.meteor_counter == 3 )
    { 
        level thread play_music_easter_egg( player );
    }
}