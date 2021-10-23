import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;

class Hud extends FlxTypedGroup<FlxSprite>
{
	var healthBar:FlxBar;
	var playerHealth:Float;
	public var score:Int = 0;
	var scoreText:FlxText;
	var multiplier:Int;
	var multText:FlxText;
	var gameOverText:FlxText;
	var scoreDesc:FlxText;
	var replayButt:FlxButton;

	var musicText:FlxText;
	var musicButton:FlxButton;
	var menuButton:FlxButton;

	var painOverlay:FlxSprite;

	var sacrificeMode:Bool;

	var redTeamScoreText:FlxText;
	var redTeamDesc:FlxText;

	public var redTeamScore:Int;

	/**
		@param	mode	true = sacrifice mode, false = survival
	**/
	public function new(mode:Bool)
	{
		super();

		sacrificeMode = mode;

		// === THESE ARE ALWAYS VISIBLE ===
		healthBar = new FlxBar(10, 15, LEFT_TO_RIGHT, 200, 20, null, "_health", 0, 20, true);
		healthBar.createFilledBar(null, FlxColor.GREEN, true, FlxColor.BLACK);
		healthBar.alpha = 0;
		add(healthBar);
		scoreText = new FlxText(0, FlxG.height - 30, FlxG.width, Std.string(score), 20);
		add(scoreText);
		if (!sacrificeMode)
		{
			multText = new FlxText(0, FlxG.height - 15, FlxG.width, "x" + Std.string(multiplier), 10);
			add(multText);
			scoreText.size = 10;
		}
		else
		{
			scoreText.y = FlxG.height + 10;
			redTeamScoreText = new FlxText(FlxG.width - 30, FlxG.height - 30, "0", 20);
			redTeamScoreText.color = FlxColor.RED;
			add(redTeamScoreText);
		}
		

		// === VISIBLE ON GAME OVER ===
		gameOverText = new FlxText(FlxG.width / 2 - 100, FlxG.height / 2 - 20, FlxG.width, "GAME OVER", 30);
		add(gameOverText);
		gameOverText.visible = false;
		scoreDesc = new FlxText(gameOverText.x, gameOverText.y + 30, FlxG.width, "Your score is: ", 10);
		add(scoreDesc);
		scoreDesc.visible = false;
		musicText = new FlxText(scoreDesc.x, FlxG.height - 20, FlxG.width, "Music: Tatari, by WaxTerK");
		add(musicText);
		musicText.visible = false;
		replayButt = new FlxButton(scoreDesc.x, scoreDesc.y + 25, "RESTART", () ->
		{
			if (!sacrificeMode)
			{
				FlxG.switchState(new PlayState("assets/data/arena.json"));
			}
			else
			{
				FlxG.switchState(new PlayState("assets/data/sacrifice.json"));
			}
			
		});
		add(replayButt);
		replayButt.visible = false;
		menuButton = new FlxButton(replayButt.x + 80, replayButt.y, "MENU", () ->
		{
			FlxG.switchState(new MenuState());
		});
		add(menuButton);
		menuButton.visible = false;
		if (sacrificeMode)
		{
			scoreDesc.text = "You: ";
			scoreText.y -= 40;
			redTeamDesc = new FlxText(scoreText.x + 25, scoreDesc.y, FlxG.width, "Them: ", 10);
			add(redTeamDesc);
			redTeamDesc.visible = false;
		}

		// === DISPLAYS WHEN YOU GET SHOT ===
		painOverlay = new FlxSprite(0, 0, "assets/images/painOverlay.png");
		add(painOverlay);
		painOverlay.alpha = 0;

		forEach((sprite) ->
		{
			// makes all the sprites in this group follow the camera
			sprite.scrollFactor.set(0, 0);
		});
		if (!sacrificeMode)
		{
		// message the server every 5 minutes and ask if everything's ok bb <3
			if (NG.core != null && NG.core.loggedIn)
			{
				new FlxTimer().start(300, (timer) ->
				{
					NG.core.calls.gateway.ping().send();
				}, 0);
			}
		}
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
		if (sacrificeMode)
		{
			score++;
		}
		else
		{
			score += (add * multiplier);
		}
		
		scoreText.text = Std.string(score);
	}

	public function setMult(mult:Int)
	{
		if (!sacrificeMode)
		{
			if (mult == 0 || mult == null)
			{
				mult = 1;
			}
			multiplier = mult;
			multText.text = "x" + Std.string(multiplier);
		}
		else
		{
			multiplier = 1;
		}
	}

	var sentAPIcall:Bool = false;

	public function gameOver()
	{
		if (!sacrificeMode)
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
			scoreText.size = 8;
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
	public function flashOverlay()
	{
		painOverlay.alpha = 1;
		FlxTween.tween(painOverlay, {alpha: 0}, 0.5);
	}
	public function redScore()
	{
		redTeamScore++;
		redTeamScoreText.text = Std.string(redTeamScore);
	}

	public function lostGame()
	{
		gameOverText.visible = true;
		gameOverText.text = "You Lose!";
		scoreDesc.visible = true;
		healthBar.visible = false;
		// multText.visible = false;

		scoreText.x = scoreDesc.x + 30;
		scoreText.y = scoreDesc.y;
		redTeamDesc.x = scoreText.x + 30;
		redTeamDesc.y = scoreText.y;
		redTeamDesc.visible = true;
		redTeamScoreText.x = redTeamDesc.x + 40;
		redTeamScoreText.y = redTeamDesc.y;

		replayButt.visible = true;
		menuButton.visible = true;
		musicText.visible = true;
	}

	public function winGame()
	{
		gameOverText.visible = true;
		gameOverText.text = "You Win!";
		scoreDesc.visible = true;
		healthBar.visible = false;
		// multText.visible = false;

		scoreText.x = scoreDesc.x + 30;
		scoreText.y = scoreDesc.y;
		redTeamDesc.x = scoreText.x + 30;
		redTeamDesc.y = scoreText.y;
		redTeamDesc.visible = true;
		redTeamScoreText.x = redTeamDesc.x + 40;
		redTeamScoreText.y = redTeamDesc.y;

		replayButt.visible = true;
		menuButton.visible = true;
		musicText.visible = true;
	}
}