import flixel.FlxSprite;

class Heart extends FlxSprite
{
	public function new(x, y)
	{
		super(x, y);
		loadGraphic("assets/images/heart.png");
	}

	public function get(pl:Player)
	{
		pl.health += 8;
		kill();
	}
}