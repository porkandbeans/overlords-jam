import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite{
    public function new(x, y){
        super(x, y);
		makeGraphic(60, 60, FlxColor.WHITE);
		maxVelocity = new FlxPoint(200, 200);
		drag = new FlxPoint(400, 400);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		keyListeners();
	}

	// ====== I AM STEALING THIS FROM THE TUTORIAL https://haxeflixel.com/documentation/groundwork/ ======
	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var newAngle:Float;
	var SPEED:Float = 200;
    
	function keyListeners()
	{
		up = FlxG.keys.anyPressed([W, UP]);
		down = FlxG.keys.anyPressed([S, DOWN]);
		left = FlxG.keys.anyPressed([A, LEFT]);
		right = FlxG.keys.anyPressed([D, RIGHT]);

		// CANCEL OUT THE OPPOSING DIRECTIONS
		if (up && down)
		{
			up = down = false;
		}
		if (left && right)
		{
			left = right = false;
		}
		// SET THE VELOCITY ANGLE
		if (up)
		{
			newAngle = -90;
			if (left)
			{
				newAngle -= 45;
			}
			else if (right)
			{
				newAngle += 45;
			}
		}
		else if (down)
		{
			newAngle = 90;
			if (left)
			{
				newAngle += 45;
			}
			else if (right)
			{
				newAngle -= 45;
			}
		}
		else if (left)
		{
			newAngle = 180;
		}
		else if (right)
		{
			newAngle = 0;
		}
		// APPLY THE PHYSICS
		velocity.set(SPEED, 0);
		velocity.rotate(FlxPoint.weak(0, 0), newAngle);
	    
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