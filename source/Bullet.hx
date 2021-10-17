import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;

class Bullet extends FlxSprite
{
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
		FlxVelocity.moveTowardsMouse(this, 180);
		trace("bullet fired");
	}
}