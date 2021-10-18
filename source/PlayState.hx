package;

import Buddy.State;
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
	var bullets:FlxTypedGroup<Bullet>; // specific type group for player bullets
	var bulletsg:FlxGroup; // checking for overlaps and contains both player and friendly buddy bullets
	var buddyBullets:FlxGroup; // only contains friendly buddy bullets
	var buddies:FlxTypedGroup<Buddy>;
	var playerVector:Vector2;
	var activeFollowers:Int;
	var overlords:FlxTypedGroup<Overlord>;
	var badBullets:FlxGroup; // contains both evil buddy bullets and overlord bullets
	var buddyBadBullets:FlxGroup; // contains only enemy buddy bullets
	var hud:Hud;
	var hearts:FlxTypedGroup<Heart>;
	var buddySpawns:FlxTypedGroup<BuddySpawn>;
	var overlordSpawns:FlxTypedGroup<OverlordSpawn>;

	override public function create()
	{
		super.create();
		player = new Player(FlxG.width / 2, FlxG.height / 2);
		playerVector = new Vector2(); // defined in update()

		mouse = FlxG.mouse;
		mousePos = new FlxPoint();
		map = new FlxOgmo3Loader("assets/data/Overlords_tilemap_project.ogmo", "assets/data/arena.json");
		FlxG.collide(player, tilemap);
		FlxG.collide(bullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.collide(buddyBullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.collide(tilemap, badBullets, (til, bul) ->
		{
			bul.kill();
		});
		FlxG.collide(tilemap, buddyBadBullets, (til, bul) ->
		{
			bul.kill();
		});
		FlxG.collide(buddies, buddies);
		FlxG.collide(tilemap, overlords);
		tilemap = map.loadTilemap("assets/images/tilemap/tiles.png", "new_layer");
		tilemap.follow();
		add(tilemap);
		
		// declare which blocks are solid and collide with stuff
		tilemap.setTileProperties(1, FlxObject.NONE); // floor
		tilemap.setTileProperties(2, FlxObject.ANY); // wall
		tilemap.setTileProperties(3, FlxObject.NONE); // floor
		tilemap.setTileProperties(4, FlxObject.NONE); // floor
		// tilemap.setTileProperties(5, FlxObject.NONE); // floor with red stain

		// helper group for bullets and recycling them
		bullets = new FlxTypedGroup<Bullet>();
		bulletsg = new FlxGroup();
		bulletsg.add(bullets);
		buddies = new FlxTypedGroup<Buddy>();
		buddyBullets = new FlxGroup();
		badBullets = new FlxGroup();
		buddyBadBullets = new FlxGroup();
		hearts = new FlxTypedGroup<Heart>();
		buddySpawns = new FlxTypedGroup<BuddySpawn>();
		overlordSpawns = new FlxTypedGroup<OverlordSpawn>();

		overlords = new FlxTypedGroup<Overlord>();

		hud = new Hud();
		// add(hud); add after everything else

		map.loadEntities(placeEntities, "ents");
		
		add(bullets);
		add(player); // player goes on top of the tilemap, so add after
		add(buddies);
		buddies.forEach((buddy:Buddy) ->
		{
			addBuddyBullets(buddy);
		});
		add(overlords);
		overlords.forEach((ols) ->
		{
			instanceOlBulls(ols);
		});
		add(hearts);
		add(buddySpawns);
		add(overlordSpawns);
		add(hud);
	}

	function addBuddyBullets(buddy:Buddy)
	{
		add(buddy.bullets);
		add(buddy.badBullets);
		buddyBullets.add(buddy.bullets);
		buddyBadBullets.add(buddy.badBullets);
		badBullets.add(buddy.badBullets);
		bulletsg.add(buddy.bullets);
	}

	function instanceOlBulls(ol:Overlord)
	{
		var baddieBullets = new FlxTypedGroup<BadBullet>();
		ol.loadBullets(baddieBullets);
		add(baddieBullets);
		badBullets.add(baddieBullets);
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
				buddies.add(new Buddy(entity.x, entity.y, player, overlords));
				return;
			case "overlord":
				overlords.add(new Overlord(entity.x, entity.y, player));
				return;
			case "buddySpawn":
				buddySpawns.add(new BuddySpawn(entity.x, entity.y, player, overlords));
				return;
			case "overlordSpawn":
				overlordSpawns.add(new OverlordSpawn(entity.x, entity.y, player));
				return;
		}
	}
	var buddyMult:Int;
	override public function update(elapsed:Float)
	{
		mousePos = mouse.getPosition();
		player.getAngleAndRotate(mousePos);
		collidesAndOverlaps();
		FlxG.camera.follow(player, TOPDOWN, 1);
		super.update(elapsed);
		shootListen();
		buddyMult = 0;
		buddies.forEach((buddy:Buddy) ->
		{
			buddy.checkPlayerDistance();
			buddy.followPlayer(player.getMidpoint());
			buddy.rotateAndLookAt(player.getMidpoint(), mouse.getPosition());
			if (buddy.alive && buddy.state == FOLLOW)
			{
				buddyMult++;
			}
		});
		// set multiplier equal to the number of following buddies
		hud.setMult(buddyMult);

		buddySpawns.forEach((spawner) ->
		{
			if (spawner.getBuddy() != null)
			{
				buddies.add(spawner.getBuddy());
				addBuddyBullets(spawner.getBuddy());
			}
		});

		overlordSpawns.forEach((olSpawn) ->
		{
			if (olSpawn.getOverlord() != null)
			{
				overlords.add(olSpawn.getOverlord());
				instanceOlBulls(olSpawn.getOverlord());
				olSpawn.done();
			}
		});

		gameOverCheck();
	}

	function gameOverCheck()
	{
		if (player.health <= 0)
		{
			player.kill();
			buddies.forEach((bud) ->
			{
				if (bud.state == FOLLOW)
				{
					bud.kill();
				}

				hud.gameOver();
			});
		}
	}

	function collidesAndOverlaps()
	{
		FlxG.collide(player, tilemap);
		FlxG.collide(bullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.collide(buddyBullets, tilemap, (bul, til) ->
		{
			bul.kill();
		});
		FlxG.collide(tilemap, badBullets, (til, bul) ->
		{
			bul.kill();
		});
		FlxG.collide(tilemap, buddyBadBullets, (til, bul) ->
		{
			bul.kill();
		});
		FlxG.collide(buddies, buddies);
		FlxG.collide(tilemap, overlords);
		FlxG.overlap(badBullets, player, (bul, pla) ->
		{
			// trace("player's just been hit by a badBullet");
			if (bul.shooting)
			{
				bul.kill();
				pla.health--;
				hud.updateBar(pla.health);
			}
		});
		FlxG.overlap(buddies, bulletsg, (bud, bul) ->
		{
			if (bud.state == State.EVIL && bul.shooting)
			{
				// trace("evil buddy just shot by friendly bullet");
				bul.kill();
				bud.health--;
				if (bud.health <= 0)
				{
					bud.kill();
				}
			}
		});

		FlxG.overlap(bulletsg, overlords, (bul, ol) ->
		{
			if (bul.shooting)
			{
				var pos = new Vector2(ol.x, ol.y);
				// trace("overlord just shot by friendly bullet");
				ol.shot();
				bul.kill();
				if (!ol.alive)
				{
					hud.incScore(2);
					if (Random.int(0, 3) == 3)
					{
						var heart = new Heart(pos.x, pos.y);
						add(heart);
						hearts.add(heart);
					}
				}
			}
		});
		FlxG.overlap(player, hearts, (pl:Player, ht:Heart) ->
		{
			if (player.health < 20)
			{
				ht.get(pl);
				hud.updateBar(pl.health);
			}
			
		});
		FlxG.overlap(buddies, badBullets, (bud, bul) ->
		{
			if (bud.state == FOLLOW)
			{
				bul.kill();
				bud.health--;
				if (bud.health <= 0)
				{
					bud.kill();
				}
			}
		});
	}

	/**
		Listens for left mouse click, and shoots a bullet towards the mouse pointer from the player's midpoint
	**/
	function shootListen()
	{
		if (mouse.justPressed)
		{
			bullets.recycle(Bullet.new).shoot(player.getMidpoint().x, player.getMidpoint().y, null);
			buddies.forEach((buddy:Buddy) ->
			{
				buddy.shoot(player.getMidpoint(), mouse.getPosition());
			});
		}
	}
}
