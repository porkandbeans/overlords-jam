import Random;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

enum EnemyState
{
	IDLE;
	ATTACKING;
}

enum Gamemode
{
	SURVIVAL;
	SACRIFICE;
}

enum PlayMode
{
	PLAY;
	RETURN;
	WAIT;
}

class Overlord extends FlxSprite
{
	public var mode(default, null):Gamemode;
	public var playMode(default, null):PlayMode;
	var state(default, null):EnemyState;
	var newAngle:Float;
	var timer:FlxTimer;
	var shootTimer:FlxTimer;
	var bullets:FlxTypedGroup<BadBullet>;
	var player:Player;
	var buddies:FlxTypedGroup<Buddy>;
	var spawnPoint:FlxPoint;
	var playPoint1:FlxPoint;
	var playPoint2:FlxPoint;
	var playPoint:FlxPoint;
	var returnPoint:FlxPoint;
	var tileMap:FlxTilemap;

	public function new(x:Float, y:Float, _player:Player, _mode:Gamemode, map:FlxTilemap)
	{
		super(x, y);
		mode = _mode;
		state = IDLE;
		timer = new FlxTimer();
		shootTimer = new FlxTimer();
		spawnPoint = new FlxPoint(x, y);
		respawnTimer = new FlxTimer();
		tileMap = map;
		// makeGraphic(16, 16, FlxColor.BLACK);
		loadGraphic("assets/images/overlord.png");
		if (mode == SURVIVAL)
		{
			playMode = WAIT;
		}
		else
		{
			playMode = PLAY;
		}

		/*timer.start(3, (timer) ->
		{
			// random movements
			moveIdle();
		}, 0);
		 */
		player = _player;
		buddies = new FlxTypedGroup<Buddy>();
		health = 20;
		playPoint = new FlxPoint();
		new FlxTimer().start(5, (tim) ->
		{
			trace("I am alive: " + alive);
			trace("My health: " + health);
			trace("My current state: " + playMode);
			trace("I am at: " + this.x + " | " + this.y);
			trace("I am visible: " + visible);
		}, 0);
	}

	/**
		set the points the overlords will go back and forth from during sacrifice mode
		@param	pt1	playPoint1
		@param	pt2	playPoint2
		@param	pt3	return point (go home to score)
	**/
	public function setPlayPoints(pt1:FlxPoint, pt2:FlxPoint, pt3:FlxPoint)
	{
		playPoint1 = pt1;
		playPoint2 = pt2;
		returnPoint = pt3;
	}

	public function loadBullets(_bulls:FlxTypedGroup<BadBullet>)
	{
		bullets = _bulls;
	}

	/**
		add a new buddy to the group
	**/
	public function addBuddy(buddy:Buddy)
	{
		buddies.add(buddy);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (mode == SACRIFICE)
		{
			setPlayMode();
			sacMovement();
		}
		else
		{
			moveIdle();
		}
		if (alive)
		{
			lookForPlayer();
		}
	}

	function setPlayMode()
	{
		if (buddies.countLiving() <= 0) // do we have no buddies?
		{
			if (getMidpoint().distanceTo(playPoint) > 100) // are we 50 pixels away from the playPoint?
			{
				// go get a buddy
				playMode = PLAY;
			}
			else
			{
				// wander around until you get one
				playMode = WAIT;
			}
		}
		else // we have more than 0 buddies
		{
			if (tileMap.ray(getMidpoint(), returnPoint)) // can we see the return point?
			{
				if (getMidpoint().distanceTo(returnPoint) < 10) // are we already at it?
				{
					// wander around, stay close
					playMode = WAIT;
				}
				else
				{ // we're more than 10 pixels away from it

					playMode = RETURN; // go to it
				}
			}
			else if (tileMap.ray(getMidpoint(), playPoint)) // we can't see the return point, but can we see our chosen playPoint?
			{
				// go to it
				playMode = PLAY;
			}
			else
			{
				// wander around for a bit until we get somewhere
				playMode = WAIT;
			}
		}
	}

	var playPointTrigger:Bool = true;

	function sacMovement()
	{
		if (playMode == WAIT)
		{
			moveIdle();
		}
		else if (playMode == PLAY)
		{
			if (playPointTrigger)
			{
				playPointTrigger = false;
				timer.start(3, (tim) ->
				{
					playPointTrigger = true;
					setPlayPoint();
				});
			}

			FlxVelocity.moveTowardsPoint(this, playPoint, 100);
		}
		else if (playMode == RETURN)
		{
			FlxVelocity.moveTowardsPoint(this, returnPoint, 100);
		}
		else
		{
			trace("Unexpected overlord playMode: " + playMode);
		}
	}

	var decideMovement:Bool = true;

	function setPlayPoint()
	{
		if (Random.int(1, 100) <= 50) // I had it 0 to 1, but they really seemed to favor one point over the other
		{
			trace("I chose point 1");
			playPoint = playPoint1;
		}
		else
		{
			trace("I chose point 2");
			playPoint = playPoint2;
		}
	}

	function moveIdle()
	{
		if (decideMovement)
		{
			decideMovement = false;
			timer.start(3, (timer) ->
			{
				if (playMode == WAIT)
				{
					decideMovement = true;
					newAngle = Random.float(-180, 180);
					velocity.set(100, 0);
					velocity.rotate(FlxPoint.weak(0, 0), newAngle);
					angle = newAngle;
				}
			}, 0);
		}
	}

	var playerDistance:Float;
	var buddyAngle:Float;

	/**
		get the distance between here and the player, if the player is within range, shoot stuff at them.
		Also, tell the buddies to rotate AT MY ANGLE - not directly at the player.
	**/
	function lookForPlayer()
	{
		playerDistance = getMidpoint().distanceTo(player.getMidpoint());

		if (player.alive && playerDistance < 200)
		{
			// rotate to face the player
			getAngleAndRotate(player.getMidpoint());
			buddies.forEach((bud) ->
			{
				// set the buddy's angle to the angle between this overlord and the player
				buddyAngle = getMidpoint().angleBetween(player.getMidpoint());
				bud.lookAtAngle(buddyAngle);
			});

			//  shoot bullets at the player
			if (canShoot)
			{
				bullets.recycle(BadBullet.new).shoot(getMidpoint().x, getMidpoint().y, player.getMidpoint());
				buddies.forEach((bud) ->
				{
					if (bud.alive)
					{
						bud.badShoot(buddyAngle);
					}
				});
				canShoot = false;
				shootTimer.start(1, (timer) ->
				{
					canShoot = true;
				});
			}
		}
		else
		{
			// player's gone out of range, look in the direction you're moving
			angle = newAngle;
		}
	}
	var xdistance:Float;
	var ydistance:Float;
	var c2:Float;
	var toDegs:Float;

	public function getAngleAndRotate(player:FlxPoint)
	{
		xdistance = getMidpoint().x - player.x;
		ydistance = getMidpoint().y - player.y;

		// pythagorean theorum (a^2 + b^2 = c^2)
		c2 = ((xdistance * xdistance) + (ydistance * ydistance));

		// get the inverse tangent by passing the adjacent and opposite sides of the triangle to Math.atan2(), then (thanks GeoKureli) convert the radians into degrees
		toDegs = 180 / Math.PI * Math.atan2(ydistance, xdistance);

		set_angle(toDegs + 180); // NOW LOOK AT IT!!!
	}
	public function shot()
	{
		health--;
		if (health <= 0)
		{
			kill();
		}
	}
	var respawnTimer:FlxTimer;

	override public function kill()
	{
		if (mode == SURVIVAL)
		{
			super.kill();
		}
		else if (mode == SACRIFICE)
		{
			// reset(spawnPoint.x, spawnPoint.y);
			// playMode = WAIT;
			/*alive = false;
				visible = false;
			 */
			super.kill();
			decideMovement = true;
			buddies.clear();
			respawnTimer.start(4, (timer) ->
			{
				trace("OVERLORD RESPAWN");
				reset(spawnPoint.x, spawnPoint.y);
				health = 20;
				// player.x = this.x;
				// player.y = this.y;
				// health = 20;
			});
		}
	}
	var canShoot:Bool = true;
	public function gameEnd()
	{
		super.kill();
	}
}