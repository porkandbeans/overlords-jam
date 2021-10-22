package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import io.newgrounds.NG;

class LoginState extends FlxState
{
	override public function create()
	{

		var loggingInText = new FlxText(30, 30, FlxG.width - 60, "Logging in to Newgrounds...\n(If you can read this, try allowing pop-ups)");
		add(loggingInText);

		var api_key:String = haxe.Resource.getString("api_key");
		var enc_key:String = haxe.Resource.getString("enc_key");
		NG.create(api_key);
		NG.core.initEncryption(enc_key, RC4, BASE_64);
		var failButton = new FlxButton(30, 90, "Play anyway", loadGame);
		add(failButton);

		if (NG.core != null)
		{
			if (NG.core.attemptingLogin)
			{
				NG.core.onLogin.add(onLoggedIn);
			}
			else
			{
				NG.core.requestLogin(onLoggedIn, null, () ->
				{
					loggingInText.text = "The login has failed. Maybe you denied permission?\nYou will not be able to post high-scores.";
					failButton.visible = true;
				});
			}
		}

		/*
		if (NG.core != null && !NG.core.loggedIn)
		{
			NG.core.requestLogin(onLoggedIn);
		}
		else if (NG.core != null && NG.core.loggedIn)
		{
			loadGame();
		}*/
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