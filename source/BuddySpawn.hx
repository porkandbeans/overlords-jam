import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;

class BuddySpawn extends FlxObject
{
	var ready:Bool = true;
	var pl:Player;
	var ols:FlxTypedGroup<Overlord>;
	var buddy:Buddy;

	public function new(x, y, player:Player, overlords:FlxTypedGroup<Overlord>)
	{
		super(x, y);
		pl = player;
		ols = overlords;
	}

	function spawnBuddy()
	{
		buddy = new Buddy(this.x, this.y, pl, ols);
	}

	public function getBuddy()
	{
		if (buddy != null)
		{
			return buddy;
		}
		else
		{
			return null;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ready)
		{
			ready = false;
			new FlxTimer().start(10, (timer) ->
			{
				spawnBuddy();
			});
		}

		if (buddy != null && buddy.state != IDLE)
		{
			ready = true;
			buddy = null;
		}
	}
}