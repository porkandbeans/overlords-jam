import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Bullet extends FlxSprite
{
	var SPEED = 180;
	var moveTo:FlxPoint;
	public var shooting:Bool = false;

	public function new()
	{
		super();
		loadGraphic("assets/images/bullet.png");
		// makeGraphic(6, 6, FlxColor.WHITE);
		// trace("bullet created");
	}

	/**
		shoot a bullet.
		@param	x	the x co-ord
		@param	t	the y co-ord
		@param	point	can be null for Bullets, must be declared for BadBullet
	**/
	public function shoot(x:Float, y:Float, point:FlxPoint)
	{
		shooting = false;
		this.x = x - 3;
		this.y = y - 3;
		alive = true;
		FlxVelocity.moveTowardsPoint(this, new FlxPoint(FlxG.mouse.getPosition().x + 10, FlxG.mouse.getPosition().y + 10), SPEED);
		//		FlxVelocity.moveTowardsMouse(this, SPEED);
		new FlxTimer().start(0.1, (timer) ->
		{
			shooting = true;
			timer.destroy();
		});
	}

	public function buddyShoot(angle:Float)
	{
		shooting = false;
		alive = true;
		angle -= 90;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), angle);
		new FlxTimer().start(0.01, (timer) ->
		{
			shooting = true;
			timer.destroy();
		});
	}
}