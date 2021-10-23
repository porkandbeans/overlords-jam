import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import haxe.Timer;

var overlord:Overlord;
var timer:FlxTimer;
var plrf:Player;
var tmrf:FlxTilemap;
var plstate:Sacrifice;

class SacEnemySpawn extends FlxObject
{
	/**public function new(x, y, pl:Player, tm:FlxTilemap, playState:Sacrifice)
		{
			super(x, y);
			overlord = new Overlord(this.x, this.y, pl, SACRIFICE, tm);
			plrf = pl;
			tmrf = tm;
			plstate = playState;
			timer = new FlxTimer();
			plstate.add(overlord);
			plstate.overlords.add(overlord);

			overlord.setPlayPoints(plstate.pp1, plstate.pp2, plstate.returnPoint);
		}

		override public function update(elapsed)
		{
			super.update(elapsed);
			if (overlord != null && !overlord.alive)
			{
				overlord = null;
				timer.start(4, (tim) ->
				{
					overlord = new Overlord(this.x, this.y, plrf, SACRIFICE, tmrf);
					plstate.add(overlord);
					plstate.overlords.add(overlord);

					overlord.setPlayPoints(plstate.pp1, plstate.pp2, plstate.returnPoint);
				});
			}
		}

		// i think this literally just needs to be a FlxPoint where the enemy can respawn
	**/
}