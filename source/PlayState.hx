package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
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
	var bullets:FlxTypedGroup<Bullet>;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);

		mouse = FlxG.mouse;
		mousePos = new FlxPoint();
		map = new FlxOgmo3Loader("assets/data/Overlords_tilemap_project.ogmo", "assets/data/leveldata.json");
		tilemap = map.loadTilemap("assets/images/tilemap/tiles.png", "new_layer");
		tilemap.follow();
		add(tilemap);
		
		// declare which blocks are solid and collide with stuff
		tilemap.setTileProperties(1, FlxObject.NONE);
		tilemap.setTileProperties(2, FlxObject.ANY);

		map.loadEntities(placeEntities, "ents");

		// helper group for bullets and recycling them
		bullets = new FlxTypedGroup<Bullet>(30);
		
		add(bullets);
		add(player); // player goes on top of the tilemap, so add after
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "playerSpawn":
				player.x = entity.x;
				player.y = entity.y;
				return;
		}
	}

	override public function update(elapsed:Float)
	{
		mousePos = mouse.getPosition();
		player.getAngleAndRotate(mousePos);
		FlxG.collide(player, tilemap);
		FlxG.collide(bullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.camera.follow(player, TOPDOWN, 1);
		super.update(elapsed);
		shootListen();
	}

	/**
		Listens for left mouse click, and shoots a bullet towards the mouse pointer from the player's midpoint
	**/
	function shootListen()
	{
		if (mouse.justPressed)
		{
			bullets.recycle(Bullet.new).shoot(player.getMidpoint().x, player.getMidpoint().y);
		}
	}
}
