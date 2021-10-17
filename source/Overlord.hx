import Random;
import flixel.FlxSprite;
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

	public function new(x:Float, y:Float)
	{
		super(x, y);
		state = IDLE;
		timer = new FlxTimer();

		makeGraphic(16, 16, FlxColor.BLACK);

		timer.start(3, (timer) ->
		{
			moveIdle();
		}, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function moveIdle()
	{
		newAngle = Random.float(-180, 180);

		velocity.set(100, 0);
		velocity.rotate(FlxPoint.weak(0, 0), newAngle);
	}
}