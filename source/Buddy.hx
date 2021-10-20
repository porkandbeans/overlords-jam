import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.math.Vector2;

enum State
{
	IDLE;
	FOLLOW;
	EVIL;
}

class Buddy extends FlxSprite
{
	public var state(default, null):State;

	var player:Player;
	var overlords:FlxTypedGroup<Overlord>;
	var playerDistance:Float;
	var playerPos:Vector2;
	var myPos:Vector2;
	var master:Overlord;
	var myMidpoint:FlxPoint;
	var mouse = FlxG.mouse;
	var speed = 120;

	public var fired:Bool = false;
	public var bullets:FlxTypedGroup<Bullet>;
	public var badBullets:FlxTypedGroup<BadBullet>;
	public var following:Bool;

	public function new(x, y, _player:Player, _overlords:FlxTypedGroup<Overlord>)
	{
		super(x, y);
		player = _player;
		overlords = _overlords;
		state = IDLE; // param to var
		makeGraphic(16, 16, FlxColor.BLUE);
		loadGraphic("assets/images/buddy.png");
		myPos = new Vector2();
		bullets = new FlxTypedGroup<Bullet>(20);
		badBullets = new FlxTypedGroup<BadBullet>(10);
		myMidpoint = new FlxPoint();
		health = 3;
		randMoveTimer = new FlxTimer();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		myMidpoint = getMidpoint();
		if (state == EVIL && master.alive == false)
		{
			// oh no, my master is dead!
			overlords.remove(master);
			master = null;
			state = IDLE;
			health = 3;
			loadGraphic("assets/images/buddy.png");
			velocity.x = 0;
			velocity.y = 0;
		}
		else if (state == EVIL)
		{
			checkOverlordDistance(master);
			followOverlord();
		}
		else if (state == IDLE)
		{
			velocity.x = 0;
			velocity.y = 0;
			overlords.forEach((ol) ->
			{
				checkOverlordDistance(ol);
			});
		}
		updateSprite();
	}

	function updateSprite()
	{
		if (state == EVIL)
		{
			if (health == 3)
			{
				loadGraphic("assets/images/buddy_evil.png");
				return;
			}
			else if (health == 2)
			{
				loadGraphic("assets/images/buddy_evil_2.png");
				return;
			}
			else if (health == 1)
			{
				loadGraphic("assets/images/buddy_evil_1.png");
				return;
			}
		}
		else if (state == FOLLOW)
		{
			if (health == 3)
			{
				loadGraphic("assets/images/buddy_follow.png");
				return;
			}
			else if (health == 2)
			{
				loadGraphic("assets/images/buddy_follow_1.png");
				return;
			}
			else
			{
				loadGraphic("assets/images/buddy_follow_2.png");
				return;
			}
		}
	}

	/**
		Check distance to player, and change state to FOLLOW if close enough.

		HEY! as it turns out, FlxPoint has a distanceTo() method, so this was kinda redundant...

		But my question, if FlxPoint contains two Floats for X and Y, with a few useful methods, and lime contains Vector2 which basically does the same thing,
		why does FlxPoint exist at all? wouldn't it make more sense to use Vector2 instead of extending a whole bunch of children?
		@param  player  a Vector2 containing the player's co-ordinates (probably converted from a FlxPoint)
	**/
	public function checkPlayerDistance()
	{
		playerDistance = getMidpoint().distanceTo(player.getMidpoint());
		if (state == IDLE && playerDistance < 100)
		{
			state = FOLLOW;
			loadGraphic("assets/images/buddy_follow.png");
		}
	}

	//	distance to master
	var olDistance:Float;

	public function checkOverlordDistance(overlord:Overlord)
	{
		// get my own midpoint, then get the distance to the overlord's midpoint
		olDistance = getMidpoint().distanceTo(overlord.getMidpoint());
		if (olDistance < 100 && state == IDLE)
		{
			state = EVIL;
			loadGraphic("assets/images/buddy_evil.png");
			master = overlord;
			master.addBuddy(this);
		}
	}

	public function followPlayer(player:FlxPoint)
	{
		// trace("following player");
		checkPlayerDistance();
		if (state == FOLLOW && playerDistance > 50)
		{
			FlxVelocity.moveTowardsPoint(this, player, speed);
		}
		else if (state == FOLLOW)
		{
			unstuck();
		}
	}

	public function followOverlord()
	{
		if (state == EVIL && olDistance > 50)
		{
			FlxVelocity.moveTowardsPoint(this, master.getMidpoint());
		}
		else if (state == EVIL)
		{
			unstuck();
		}
	}

	// angle between the player and the mouse pointer
	var shootAngle:Float;

	/**
		returns an angle:Float between the player and the mouse if following, and null if not
	**/
	public function shoot(_player:FlxPoint, mouse:FlxPoint)
	{
		if (state == FOLLOW && alive && player.alive)
		{
			var bullet = bullets.recycle(Bullet.new);
			if (!player.slow)
			{
				shootAngle = _player.angleBetween(mouse);
				bullet.reset(myMidpoint.x, myMidpoint.y);
				bullet.buddyShoot(shootAngle);
				return shootAngle;
			}
			else
			{
				bullet.shoot(myMidpoint.x, myMidpoint.y, null);
				return null;
			}
			
		}
		else if (state == EVIL)
		{
			return null;
		}
		else
		{
			return null;
		}
	}

	public function rotateAndLookAt(pos1:FlxPoint, pos2:FlxPoint)
	{
		if (state == FOLLOW)
		{
			if (!player.slow)
			{
				angle = pos1.angleBetween(pos2);
			}
			else
			{
				angle = myMidpoint.angleBetween(mouse.getPosition());
			}
			
		}
	}

	public function lookAtAngle(_ang:Float)
	{
		angle = _ang;
	}

	public function badShoot(_ang:Float)
	{
		// recycle a new BadBullet from the group, call buddyShoot on it and give it the angle and my midPoint
		var bullet = badBullets.recycle(BadBullet.new);
		bullet.reset(myMidpoint.x, myMidpoint.y);
		bullet.buddyShoot(_ang);
	}

	var randMoveTimer:FlxTimer;
	var chooseDir:Bool = true;
	public function unstuck()
	{
		if (chooseDir)
		{
			chooseDir = false;
			randMoveTimer.start(0.3, (timer) ->
			{
				chooseDir = true;
				velocity.x = Random.float(-1, 1) * speed;
				velocity.y = Random.float(-1, 1) * speed;
			});
		}
	}
}