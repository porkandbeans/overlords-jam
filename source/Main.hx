package;

import flixel.FlxGame;
import io.newgrounds.NG;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		var api_key:String = haxe.Resource.getString("api_key");
		var enc_key:String = haxe.Resource.getString("enc_key");
		NG.create(api_key); // instantiate a connection to Newgrounds using the AppId
		NG.core.initEncryption(enc_key, RC4, BASE_64);
		addChild(new FlxGame(400, 400, LoginState));
	}
}
