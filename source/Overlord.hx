import Random;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

enum EnemyState
{
	IDLE;
	ATTACKING;
}

class Overlord extends FlxSprite
{
	var state(default, null):EnemyState;
	var newAngle:Float;
	var timer:FlxTimer;
	var shootTimer:FlxTimer;
	var bullets:FlxTypedGroup<BadBullet>;
	var player:Player;
	var buddies:FlxTypedGroup<Buddy>;

	public function new(x:Float, y:Float, _player:Player)
	{
		super(x, y);
		state = IDLE;
		timer = new FlxTimer();
		shootTimer = new FlxTimer();
		// makeGraphic(16, 16, FlxColor.BLACK);
		loadGraphic("assets/images/overlord.png");

		timer.start(3, (timer) ->
		{
			// random movements
			moveIdle();
		}, 0);
		player = _player;
		buddies = new FlxTypedGroup<Buddy>();
		health = 20;
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
		lookForPlayer();
	}

	function moveIdle()
	{
		newAngle = Random.float(-180, 180);

		velocity.set(100, 0);
		velocity.rotate(FlxPoint.weak(0, 0), newAngle);
		angle = newAngle;
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

		if (playerDistance < 500)
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
	var canShoot:Bool = true;
}