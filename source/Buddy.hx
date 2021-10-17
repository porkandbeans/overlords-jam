import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import lime.math.Vector2;

enum State
{
	IDLE;
	FOLLOW;
}

class Buddy extends FlxSprite
{
	var state(default, null):State;
	var playerDistance:Float;
	var playerPos:Vector2;
	var myPos:Vector2;

	public var fired:Bool = false;
	public var bullets:FlxTypedGroup<Bullet>;
	public var following:Bool;

	public function new(x, y, _state)
	{
		super(x, y);
		state = _state; // param to var
		makeGraphic(16, 16, FlxColor.BLUE);
		loadGraphic("assets/images/buddy.png");
		myPos = new Vector2();
		bullets = new FlxTypedGroup<Bullet>(20);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	/**
		Check distance to player, and change state to FOLLOW if close enough.

		HEY! as it turns out, FlxPoint has a distanceTo() method, so this was kinda redundant...

		But my question, if FlxPoint contains two Floats for X and Y, with a few useful methods, and lime contains Vector2 which basically does the same thing,
		why does FlxPoint exist at all? wouldn't it make more sense to use Vector2 instead of extending a whole bunch of children?
		@param  player  a Vector2 containing the player's co-ordinates (probably converted from a FlxPoint)
	**/
	public function checkPlayerDistance(player:Vector2)
	{
		myPos.x = this.x;
		myPos.y = this.y;
		playerDistance = Vector2.distance(myPos, player);
		if (playerDistance < 100)
		{
			state = FOLLOW;
		}
	}

	public function followPlayer(player:FlxPoint)
	{
		if (state == FOLLOW && playerDistance > 50)
		{
			FlxVelocity.moveTowardsPoint(this, player, 120);
		}
		else if (state == FOLLOW)
		{
			velocity.x = 0;
			velocity.y = 0;
		}
	}

	var shootAngle:Float;

	/**
		returns an angle:Float between the player and the mouse if following, and null if not
	**/
	public function shoot(player:FlxPoint, mouse:FlxPoint)
	{
		if (state == FOLLOW)
		{
			shootAngle = player.angleBetween(mouse);
			bullets.recycle(Bullet.new).buddyShoot(shootAngle, this.getMidpoint());
			return shootAngle;
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
			angle = pos1.angleBetween(pos2);
		}
	}

}