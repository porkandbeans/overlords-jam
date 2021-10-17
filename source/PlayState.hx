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
import lime.math.Vector2;

class PlayState extends FlxState
{
	var player:Player;
	var mouse:FlxMouse;
	var mousePos:FlxPoint;
	var map:FlxOgmo3Loader;
	var tilemap:FlxTilemap;
	var bullets:FlxTypedGroup<Bullet>;
	var buddyBullets:FlxGroup;
	var buddies:FlxTypedGroup<Buddy>;
	var playerVector:Vector2;
	var activeFollowers:Int;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);
		playerVector = new Vector2(); // defined in update()

		mouse = FlxG.mouse;
		mousePos = new FlxPoint();
		map = new FlxOgmo3Loader("assets/data/Overlords_tilemap_project.ogmo", "assets/data/leveldata.json");
		tilemap = map.loadTilemap("assets/images/tilemap/tiles.png", "new_layer");
		tilemap.follow();
		add(tilemap);
		
		// declare which blocks are solid and collide with stuff
		tilemap.setTileProperties(1, FlxObject.NONE);
		tilemap.setTileProperties(2, FlxObject.ANY);

		// helper group for bullets and recycling them
		bullets = new FlxTypedGroup<Bullet>(30);
		buddies = new FlxTypedGroup<Buddy>();
		buddyBullets = new FlxGroup();

		map.loadEntities(placeEntities, "ents");
		
		add(bullets);
		add(player); // player goes on top of the tilemap, so add after
		add(buddies);
		buddies.forEach((buddy:Buddy) ->
		{
			add(buddy.bullets);
			buddyBullets.add(buddy.bullets);
		});
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "playerSpawn":
				player.x = entity.x;
				player.y = entity.y;
				return;
			case "buddy":
				buddies.add(new Buddy(entity.x, entity.y, IDLE));
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
		FlxG.collide(buddyBullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.collide(buddies, buddies);
		FlxG.camera.follow(player, TOPDOWN, 1);
		super.update(elapsed);
		shootListen();
		playerVector.x = player.getMidpoint().x;
		playerVector.y = player.getMidpoint().y;

		buddies.forEach((buddy:Buddy) ->
		{
			buddy.checkPlayerDistance(playerVector);
			buddy.followPlayer(player.getMidpoint());
			buddy.rotateAndLookAt(player.getMidpoint(), mouse.getPosition());
		});
	}

	/**
		Listens for left mouse click, and shoots a bullet towards the mouse pointer from the player's midpoint
	**/
	function shootListen()
	{
		if (mouse.justPressed)
		{
			bullets.recycle(Bullet.new).shoot(player.getMidpoint().x, player.getMidpoint().y);
			buddies.forEach((buddy:Buddy) ->
			{
				buddy.shoot(player.getMidpoint(), mouse.getPosition());
			});
		}
	}
}
