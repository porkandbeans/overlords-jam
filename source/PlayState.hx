package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxPoint;

class PlayState extends FlxState
{
	var player:Player;
	var mouse:FlxMouse;
	var mousePos:FlxPoint;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);
		add(player);
		mouse = FlxG.mouse;
		mousePos = new FlxPoint();
	}

	override public function update(elapsed:Float)
	{
		mousePos = mouse.getPosition();
		player.getAngleAndRotate(mousePos);
		super.update(elapsed);
	}
}
