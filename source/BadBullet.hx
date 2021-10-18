import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;

class BadBullet extends Bullet
{
	override public function new()
	{
		super();
		// makeGraphic(6, 6, FlxColor.BLACK);
		loadGraphic("assets/images/badbullet.png");
	}
	override public function shoot(x, y, point:FlxPoint)
	{
		this.x = x;
		this.y = y;
		FlxVelocity.moveTowardsPoint(this, point);
	}
}