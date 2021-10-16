package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState
{
	var player:Player;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);
		add(player);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
