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
		makeGraphic(6, 6, FlxColor.WHITE);
		trace("bullet created");
	}

	public function shoot(x, y)
	{
		this.x = x;
		this.y = y;
		FlxVelocity.moveTowardsMouse(this, SPEED);
	}

	public function buddyShoot(angle:Float, point:FlxPoint)
	{
		this.x = point.x;
		this.y = point.y;

		angle -= 90;
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), angle);
	}   
}