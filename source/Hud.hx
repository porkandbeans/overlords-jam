import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class Hud extends FlxTypedGroup<FlxSprite>
{
	var healthBar:FlxBar;
	var playerHealth:Int;

	// var testText:FlxText;

	public function new()
	{
		super();

		healthBar = new FlxBar(10, 15, LEFT_TO_RIGHT, 200, 20, null, "_health", 0, 20, true);
		healthBar.createFilledBar(null, FlxColor.GREEN, true, FlxColor.BLACK);
		healthBar.alpha = 0;
		add(healthBar);

		forEach((sprite) ->
		{
			// makes all the sprites in this group follow the camera
			sprite.scrollFactor.set(0, 0);
		});
	}

	public function updateBar(x:Float)
	{
		healthBar.value = x;

		if (playerHealth < 20)
		{
			FlxTween.tween(healthBar, {alpha: 1}, 0.33);
		}
		else
		{
			FlxTween.tween(healthBar, {alpha: 0}, 0.33);
		}
	}
}