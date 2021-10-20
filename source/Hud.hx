import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import io.newgrounds.NG;

class Hud extends FlxTypedGroup<FlxSprite>
{
	var healthBar:FlxBar;
	var playerHealth:Float;
	var score:Int = 0;
	var scoreText:FlxText;
	var multiplier:Int;
	var multText:FlxText;
	var gameOverText:FlxText;
	var scoreDesc:FlxText;
	var replayButt:FlxButton;

	var musicText:FlxText;
	var musicButton:FlxButton;
	var menuButton:FlxButton;

	public function new()
	{
		super();

		healthBar = new FlxBar(10, 15, LEFT_TO_RIGHT, 200, 20, null, "_health", 0, 20, true);
		healthBar.createFilledBar(null, FlxColor.GREEN, true, FlxColor.BLACK);
		healthBar.alpha = 0;
		add(healthBar);
		scoreText = new FlxText(0, FlxG.height - 30, FlxG.width, Std.string(score), 10);
		add(scoreText);
		multText = new FlxText(0, FlxG.height - 15, FlxG.width, "x" + Std.string(multiplier), 10);
		add(multText);

		gameOverText = new FlxText(FlxG.width / 2 - 100, FlxG.height / 2 - 20, FlxG.width, "GAME OVER", 30);
		add(gameOverText);
		gameOverText.visible = false;
		scoreDesc = new FlxText(gameOverText.x, gameOverText.y + 30, FlxG.width, "Your score is: ", 10);
		add(scoreDesc);
		scoreDesc.visible = false;

		musicText = new FlxText(scoreDesc.x, FlxG.height - 20, FlxG.width, "Music: Tatari, by WaxTerK");
		add(musicText);
		musicText.visible = false;

		replayButt = new FlxButton(scoreDesc.x, scoreDesc.y + 20, "RESTART", () ->
		{
			FlxG.switchState(new PlayState());
		});
		add(replayButt);
		replayButt.visible = false;

		menuButton = new FlxButton(replayButt.x + 80, replayButt.y, "MENU", () ->
		{
			FlxG.switchState(new MenuState());
		});
		add(menuButton);
		menuButton.visible = false;


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
	public function incScore(add:Int)
	{
		score += (add * multiplier);
		scoreText.text = Std.string(score);
	}

	public function setMult(mult:Int)
	{
		if (mult == 0 || mult == null)
		{
			mult = 1;
		}
		multiplier = mult;
		multText.text = "x" + Std.string(multiplier);
	}

	var sentAPIcall:Bool = false;

	public function gameOver()
	{
		gameOverText.visible = true;
		scoreDesc.visible = true;
		healthBar.visible = false;
		multText.visible = false;

		scoreText.x = scoreDesc.x + 90;
		scoreText.y = scoreDesc.y;

		replayButt.visible = true;
		menuButton.visible = true;
		musicText.visible = true;
		if (!sentAPIcall)
		{
			sentAPIcall = true;
			if (NG.core != null && NG.core.loggedIn)
			{
				NG.core.requestScoreBoards(() ->
				{
					var scoreBoard = NG.core.scoreBoards.get(10934);
					scoreBoard.postScore(score);
				});
			}
		}
	}
}