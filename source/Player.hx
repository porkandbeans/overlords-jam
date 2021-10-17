import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite{
    public function new(x, y){
        super(x, y);
        makeGraphic(30, 30, FlxColor.WHITE);
		maxVelocity = new FlxPoint(200, 200);
		drag = new FlxPoint(400, 400);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		keyListeners();
	}

	function keyListeners()
	{
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			acceleration.x -= 100;
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			acceleration.x += 100;
		}
		else
		{
			acceleration.x = 0;
		}

		if (FlxG.keys.anyPressed([W, UP]))
		{
			acceleration.y -= 100;
		}
		else if (FlxG.keys.anyPressed([S, DOWN]))
		{
			acceleration.y += 100;
		}
		else
		{
			acceleration.y = 0;
		}
	}

	// ====== TRIGONOMETRY AHEAD, HOPE YOU STUDIED HARD IN HIGH SCHOOL ======
	var xdistance:Float;
	var ydistance:Float;
	var c2:Float;
	var hyp:Float;
	var toDegs:Float;

	/**
		makes the player look at the mouse
		@param	pos1	a FlxPoint containing the location of the mouse cursor
	**/
	public function getAngleAndRotate(mouse:FlxPoint)
	{
		xdistance = this.x - mouse.x;
		ydistance = this.y - mouse.y;

		// pythagorean theorum (a^2 + b^2 = c^2)
		c2 = ((xdistance * xdistance) + (ydistance * ydistance));

		// square root the c^2 and we have the distance between pos1 and pos2 (or the hypotenuse)
		hyp = Math.sqrt(c2);

		// get the inverse tangent by passing the adjacent and opposite sides of the triangle to Math.atan2(), then (thanks GeoKureli) convert the radians into degrees
		toDegs = 180 / Math.PI * Math.atan2(ydistance, xdistance);

		set_angle(toDegs); // NOW LOOK AT IT!!!
	}
}