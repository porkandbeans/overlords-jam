import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class BadBullet extends Bullet
{
	override public function shoot(x, y, point:FlxPoint)
	{
		this.x = x;
		this.y = y;
		FlxVelocity.moveTowardsPoint(this, point);
	}
}