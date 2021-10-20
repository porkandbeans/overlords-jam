package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import io.newgrounds.NG;

class LoginState extends FlxState
{
	override public function create()
	{
		var loggingInText = new FlxText(30, 30, FlxG.width - 60, "Logging in to Newgrounds...\n(If you can read this, try allowing pop-ups)");
		add(loggingInText);

		if (NG.core != null && !NG.core.loggedIn)
		{
			NG.core.requestLogin(onLoggedIn);
		}
		else if (NG.core != null && NG.core.loggedIn)
		{
			loadGame();
		}
	}

	function onLoggedIn()
	{
		trace("Logged in to newgrounds");

		// camera zoom is defined here
		loadGame();
	}

	function loadGame()
	{
		FlxG.switchState(new MenuState());
	}
}