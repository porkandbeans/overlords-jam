import Buddy.State;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import haxe.display.Display.Package;
import lime.math.Vector2;

/**
	Class loaded as a PlayState for Sacrifice mode, extends PlayState
**/
class Sacrifice extends PlayState
{
	var playerSpawn:FlxPoint;
	var sacSpawns:FlxTypedGroup<SacEnemySpawn>;
	var blueGoals:FlxTypedGroup<FlxObject>;
	var redGoals:FlxTypedGroup<FlxObject>;
	var goalSound:FlxSound;

	public var returnPoint:FlxPoint;
	public var pp1:FlxPoint;
	public var pp2:FlxPoint;

	override public function create()
	{
		playerSpawn = new FlxPoint();
		sacSpawns = new FlxTypedGroup<SacEnemySpawn>(3);
		blueGoals = new FlxTypedGroup<FlxObject>();
		redGoals = new FlxTypedGroup<FlxObject>();
		pp1 = new FlxPoint(0, 0);
		pp2 = new FlxPoint();
		returnPoint = new FlxPoint();
		super.create();
		remove(hud);
		hud = new Hud(true);
		add(hud);
		add(blueGoals);
		add(redGoals);
		overlords.forEach((ol) ->
		{
			ol.setPlayPoints(pp1, pp2, returnPoint);
		});

		goalSound = FlxG.sound.load("assets/sounds/goal.wav", 1);
	}

	var gameOver:Bool = false;
	var playerDead = false;

	/**
		in Sacrifice mode, the difference is that it checks for score instead of whether or not the player is alive.

		First to 30, spawns a whole bunch of buddies when the player wins. Kills the player when they lose and doesn't let them respawn.
	**/
	override function gameOverCheck()
	{
		if (!gameOver)
		{
			if (hud.redTeamScore >= 30)
			{
				gameOver = true;
				player.kill();
				playerDead = true;
				hud.lostGame();
			}
			else if (hud.score >= 30)
			{
				gameOver = true;
				new FlxTimer().start(0.1, (tim) ->
				{
					var buddyCounter:Int = 0;
					blueGoals.forEach((gol:FlxObject) ->
					{
						buddyCounter++;
						if (buddyCounter < 50)
						{
							var bud = new Buddy(gol.x, gol.y, player, overlords);
							buddies.add(bud);
							addBuddyBullets(bud);
						}
					});
					hud.winGame();
				});
			}
		}
		if (player.health <= 0 && !playerDead)
		{
			player.kill();
			player.health = 20;
			new FlxTimer().start(4, (tim) ->
			{
				player.reset(playerSpawn.x, playerSpawn.y);
			});

			// set all following buddies to idle
			buddies.forEach((bud) ->
			{
				if (bud.state == FOLLOW)
				{
					bud.setIdle();
				}
			});
		}
	}

	/**
		some stuff redacted here and added
	**/
	override function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "playerSpawn":
				player.x = entity.x;
				player.y = entity.y;
				playerSpawn.x = entity.x;
				playerSpawn.y = entity.y;
				return;
			case "buddySpawn":
				buddySpawns.add(new BuddySpawn(entity.x, entity.y, player, this));
				return;
			case "sacEnemySpawn":
				overlords.add(new Overlord(entity.x, entity.y, player, SACRIFICE, tilemap));
				return;
			case "playPoint":
				if (pp1.x == 0)
				{
					pp1.x = entity.x;
					pp1.y = entity.y;
				}
				else
				{
					pp2.x = entity.x;
					pp2.y = entity.y;
				}
				return;

			case "returnPoint":
				returnPoint.x = entity.x;
				returnPoint.y = entity.y;
				return;
		}
	}

	/**
		No painzones here but instead I used the layer in Ogmo to place the red team and blue team goals
	**/
	override function placePainzone(entity:EntityData)
	{
		if (entity.name == "sacBlueGoal")
		{
			blueGoals.add(new FlxObject(entity.x, entity.y, 16, 16));
			return;
		}
		else if (entity.name == "sacRedGoal")
		{
			redGoals.add(new FlxObject(entity.x, entity.y, 16, 16));
			return;
		}
	}

	/**
		this did some important stuff so I couldn't just get rid of it, but I stopped the points from multiplying based on the following buddies
		I also had to un-spaghetti some stuff here
	**/
	override function setMultiplier()
	{
		buddies.forEach((buddy:Buddy) ->
		{
			buddy.checkPlayerDistance();
			// buddy.followPlayer();
			buddy.rotateAndLookAt(player.getMidpoint(), mouse.getPosition());
		});
	}

	/**
		yeah I still hate this
	**/
	override function collidesAndOverlaps()
	{
		FlxG.collide(player, tilemap); // player collides with map
		FlxG.collide(bullets, tilemap, (bul, til) -> // player bullets collide with map
		{
			bul.kill();
		});
		FlxG.collide(buddyBullets, tilemap, (bul, til) -> // buddy bullets colliding with map
		{
			bul.kill();
		});
		FlxG.collide(tilemap, badBullets, (til, bul) -> // enemy bullets colliding with map
		{
			bul.kill();
		});
		FlxG.collide(tilemap, buddyBadBullets, (til, bul) -> // evil buddy bullets on map
		{
			bul.kill();
		});
		FlxG.collide(buddies, buddies); // buddies collide with each other
		FlxG.collide(tilemap, overlords); // overlords collide with map
		
		// === PLAYER HIT BY A BULLET ===
		FlxG.overlap(badBullets, player, (bul, pla) ->
		{
			painSound.play(true);
			hud.flashOverlay();
			if (bul.shooting)
			{
				bul.kill();
				pla.health--;
				hud.updateBar(pla.health);
			}
		});

		// === WHEN PLAYER SHOOTS BUDDIES ===
		FlxG.overlap(buddies, bulletsg, (bud, bul) ->
		{
			if (bud.state == State.EVIL && bul.shooting)
			{
				budHit.play(true);
				// trace("evil buddy just shot by friendly bullet");
				bul.kill();
				bud.health--;
				if (bud.health <= 0)
				{
					bud.kill();
				}
			}
		});

		// === WHEN PLAYER SHOOTS ENEMIES ===
		FlxG.overlap(bulletsg, overlords, (bul, ol) ->
		{
			if (bul.shooting && ol.alive)
			{
				hitsound.play(true);
				ol.shot();
				bul.kill();
			}
		});
		// === PLAYER PICKS UP A HEART ===
		FlxG.overlap(player, hearts, (pl:Player, ht:Heart) ->
		{
			if (player.health < 20)
			{
				ht.get(pl);
				hud.updateBar(pl.health);
			}
		});
		// === BUDDY SHOT BY ENEMY BULLET ===
		FlxG.overlap(buddies, badBullets, (bud, bul) ->
		{
			if (bud.state == FOLLOW)
			{
				budHit.play(true);
				bul.kill();
				bud.health--;
				if (bud.health <= 0)
				{
					bud.kill();
				}
			}
		});

		// === PLAYER SCORED ===
		FlxG.overlap(buddies, blueGoals, (bud, goal) ->
		{
			if (!gameOver && bud.alive)
			{
				goalSound.play(true);
				bud.kill();
				hud.incScore(1);
			}
		});

		// === ENEMY SCORED ===
		FlxG.overlap(buddies, redGoals, (bud, goal) ->
		{
			if (bud.alive)
			{
				hud.redScore();
				bud.kill();
			}
		});
	}
}