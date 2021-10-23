import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;


class OverlordSpawn extends FlxObject
{
	var ready:Bool = true;
	var pl:Player;
	var overlord:Overlord;

	public function new(x, y, player:Player)
	{
		super(x, y);
		pl = player;
	}

	function spawnOverlord()
	{
		// only null because Survival mode overlords don't need this reference
		overlord = new Overlord(x, y, pl, SURVIVAL, null);
		// stateGroup.add(overlord);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ready)
		{
			ready = false;
			new FlxTimer().start(10, (timer) ->
			{
				spawnOverlord();
			});
		}
	}

	public function getOverlord()
	{
		if (overlord != null)
		{
			return overlord;
		}
		else
		{
			return null;
		}
	}

	public function done()
	{
		ready = true;
		overlord = null;
	}
}