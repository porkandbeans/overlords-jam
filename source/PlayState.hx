package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	var player:Player;
	var mouse:FlxMouse;
	var mousePos:FlxPoint;
	var map:FlxOgmo3Loader;
	var tilemap:FlxTilemap;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);

		mouse = FlxG.mouse;
		mousePos = new FlxPoint();
		map = new FlxOgmo3Loader("assets/data/Overlords_tilemap_project.ogmo", "assets/data/leveldata.json");
		tilemap = map.loadTilemap("assets/images/tilemap/tiles.png", "new_layer");
		add(tilemap);

		add(player); // player goes on top of the tilemap, so add after
	}

	override public function update(elapsed:Float)
	{
		mousePos = mouse.getPosition();
		player.getAngleAndRotate(mousePos);
		super.update(elapsed);
	}
}
