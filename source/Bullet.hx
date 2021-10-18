import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;

class Bullet extends FlxSprite
{
	var SPEED = 180;
	var moveTo:FlxPoint;

	public function new()
	{
		super();
		loadGraphic("assets/images/bullet.png");
		// makeGraphic(6, 6, FlxColor.WHITE);
		// trace("bullet created");
	}

	/**
		shoot a bullet.
		@param	point	can be null for Bullets, must be declared for BadBullet
	**/
	public function shoot(x, y, point:FlxPoint)
	{
		this.x = x;
		this.y = y;
		alive = true;
		FlxVelocity.moveTowardsMouse(this, SPEED);
	}

	public function buddyShoot(angle:Float)
	{
		alive = true;
		angle -= 90;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), angle);
	}
}