package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		// camera zoom is defined here
		addChild(new FlxGame(400, 400, PlayState));
	}
}
