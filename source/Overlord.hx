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
	var bullets:FlxTypedGroup<BadBullet>;
	var player:Player;

	public function new(x:Float, y:Float, _player:Player)
	{
		super(x, y);
		state = IDLE;
		timer = new FlxTimer();
		// makeGraphic(16, 16, FlxColor.BLACK);
		loadGraphic("assets/images/overlord.png");

		timer.start(3, (timer) ->
		{
			moveIdle();
		}, 0);
		player = _player;
	}

	public function loadBullets(_bulls:FlxTypedGroup<BadBullet>)
	{
		bullets = _bulls;
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

	function lookForPlayer()
	{
		playerDistance = getMidpoint().distanceTo(player.getMidpoint());

		if (playerDistance < 100)
		{
			bullets.recycle(BadBullet.new).shoot(getMidpoint().x, getMidpoint().y, player.getMidpoint());
		}
	}
}