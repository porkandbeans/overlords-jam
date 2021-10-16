import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite{
    public function new(x, y){
        super(x, y);
        makeGraphic(30, 30, FlxColor.WHITE);
    }
}