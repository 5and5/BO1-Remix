#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_zombiemode_net;

#using_animtree( "generic_human" );

init()
{
    if ( !clientscripts\_zombiemode_weapons::is_weapon_included( "blundergat_zm" ) )
	{
		return;
	}

    level.blundergat_range = 900;
    level.blundergat_cylinder = 35;

    level thread blundergat_on_player_connect();
}


blundergat_on_player_connect()
{
    for( ;; )
    {
        level waittill( "connecting", player );
        player thread wait_for_blundergat_fired();
    }
}


wait_for_blundergat_fired()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );

    for( ;; )
    {
        self waittill( "weapon_fired" );
        currentweapon = self GetCurrentWeapon();
        if( ( currentweapon == "blundergat_zm" ) || ( currentweapon == "blundergat_upgraded_zm" ) )
        {
            self thread blundergat_fired(currentweapon);
        }
    }
}


blundergat_network_choke()
{
    if ( level.blundergat_network_choke_count != 0 && !(level.blundergat_network_choke_count % 4) )
    {
        wait_network_frame();
        //wait_network_frame();
        //wait_network_frame();
    }

    level.blundergat_network_choke_count++;
}


blundergat_fired(currentweapon)
{
    // ww: physics hit when firing
    PhysicsExplosionCylinder( self.origin, 600, 240, 1 );

    if ( !IsDefined( level.blundergat_knockdown_enemies ) )
    {
        level.blundergat_knockdown_enemies = [];
        level.blundergat_knockdown_gib = [];
        level.blundergat_fling_enemies = [];
        level.blundergat_fling_vecs = [];
    }

    self blundergat_get_enemies_in_range();

    //iprintlnbold( "flg: " + level.blundergat_fling_enemies.size + " gib: " + level.blundergat_gib_enemies.size + " kno: " + level.blundergat_knockdown_enemies.size );

    level.blundergat_network_choke_count = 0;
    for ( i = 0; i < level.blundergat_fling_enemies.size; i++ )
    {
        if(IsAI(level.blundergat_fling_enemies[i]))
        {
            level.blundergat_fling_enemies[i] thread blundergat_fling_zombie( self, level.blundergat_fling_vecs[i], i );
        }
    }

    level.blundergat_fling_enemies = [];
}


blundergat_get_enemies_in_range()
{
    view_pos = self GetWeaponMuzzlePoint();
    zombies = GetAiSpeciesArray( "axis", "all" );
    zombies = array_merge(zombies, get_players());
    zombies = get_array_of_closest( view_pos, zombies, undefined, undefined, level.zombie_vars["blundergat_knockdown_range"] );
    if ( !isDefined( zombies ) )
    {
        return;
    }

    fling_range_squared = level.blundergat_range * level.blundergat_range;
    cylinder_radius_squared = level.blundergat_cylinder * level.blundergat_cylinder;

    forward_view_angles = self GetWeaponForwardDir();
    end_pos = view_pos + vector_scale( forward_view_angles, level.blundergat_range );

    for ( i = 0; i < zombies.size; i++ )
    {
        if ( !IsDefined( zombies[i] ) || !IsAlive( zombies[i] ) )
        {
            // guy died on us
            continue;
        }

        test_origin = zombies[i] GetCentroid();
        test_range_squared = DistanceSquared( view_pos, test_origin );


        normal = VectorNormalize( test_origin - view_pos );
        dot = VectorDot( forward_view_angles, normal );
        if ( 0 > dot )
        {
            // guy's behind us
            zombies[i] blundergat_debug_print( "dot", (1, 0, 0) );
            continue;
        }

        radial_origin = PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );
        if ( DistanceSquared( test_origin, radial_origin ) > cylinder_radius_squared )
        {
            // guy's outside the range of the cylinder of effect
            zombies[i] blundergat_debug_print( "cylinder", (1, 0, 0) );
            continue;
        }

        if ( !zombies[i] DamageConeTrace( view_pos, self ) && !BulletTracePassed( view_pos, test_origin, false, undefined ) && !SightTracePassed( view_pos, test_origin, false, undefined ) )
        {
            // guy can't actually be hit from where we are
            zombies[i] blundergat_debug_print( "cone", (1, 0, 0) );
            continue;
        }

        if ( test_range_squared < fling_range_squared )
        {

            level.blundergat_fling_enemies[level.blundergat_fling_enemies.size] = zombies[i];
        }
    }
}

blundergat_debug_print( msg, color )
{
    // iPrintLn(msg);
}


blundergat_fling_zombie( player, fling_vec, index )
{
    if( !IsDefined( self ) || !IsAlive( self ) )
    {
        // guy died on us
        return;
    }

    self DoDamage( self.health + 666, player.origin, player );

    if ( self.health <= 0 )
    {
        player maps\_zombiemode_score::player_add_points( "blundergat_fling", 50 );
        self.blundergat_death = true;

    }
}

is_blundergat_damage()
{
    return IsDefined( self.damageweapon ) && (self.damageweapon == "blundergat_zm" || self.damageweapon == "blundergat_upgraded_zm") && (self.damagemod != "MOD_GRENADE" && self.damagemod != "MOD_GRENADE_SPLASH");
}


enemy_killed_by_blundergat()
{
    return ( IsDefined( self.blundergat_death ) && self.blundergat_death == true );
}
