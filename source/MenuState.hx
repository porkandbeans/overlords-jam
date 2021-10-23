package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import io.newgrounds.NG;

class MenuState extends FlxState
{
	var background:FlxBackdrop;
	var playButton:FlxButton;
	var helpButton:FlxButton;

	var mainMenu:FlxGroup;

	var genText:FlxText;
	var buddySprite:FlxSprite;
	var buddyText:FlxText;
	var olSprite:FlxSprite;
	var olText:FlxText;
	var preciseText:FlxText;

	var helpMenu:FlxGroup;

	var backButton:FlxButton;

	var musicButton:FlxButton;
	var musicUpButt:FlxButton;
	var musicDownButt:FlxButton;
	var volumeText:FlxText;
	var sacButton:FlxButton; // sacrifice gamemode

	override public function create()
	{
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic("assets/music/Tatari.mp3", 0.2);
		}
		background = new FlxBackdrop("assets/images/menuImg.png");
		add(background);

		// === SURVIVAL MODE ===
		playButton = new FlxButton(30, FlxG.height / 2, "SURVIVAL", () ->
		{
			FlxG.switchState(new PlayState("assets/data/arena.json"));
		});
		add(playButton);

		// === SACRIFICE MODE ===
		sacButton = new FlxButton(30, playButton.y + 20, "SACRIFICE", () ->
		{
			FlxG.switchState(new Sacrifice("assets/data/sacrifice.json"));
		});
		add(sacButton);

		helpButton = new FlxButton(FlxG.width - 120, playButton.y, "HOW TO PLAY", help);
		add(helpButton);

		mainMenu = new FlxGroup();
		mainMenu.add(background);
		mainMenu.add(playButton);
		mainMenu.add(helpButton);

		musicButton = new FlxButton(FlxG.width - 120, FlxG.width - 60, "MUSIC: ON", toggleMusic);
		add(musicButton);

		musicUpButt = new FlxButton(musicButton.x + 60, musicButton.y + 30, "+", musicUp);
		musicUpButt.width = 30;
		musicDownButt = new FlxButton(musicButton.x, musicButton.y + 30, "-", musicDown);
		musicDownButt.width = 30;
		musicDownButt.loadGraphic("assets/images/button.png");
		musicUpButt.width = 30;
		musicUpButt.loadGraphic("assets/images/button.png");
		add(musicUpButt);
		add(musicDownButt);

		volumeText = new FlxText(musicDownButt.x + 30, musicDownButt.y, 100, Std.string(FlxG.sound.music.volume * 100) + "%");
		add(volumeText);

		genText = new FlxText(30, 30, FlxG.width,
			"You are an OVERLORD. Move around with WASD/Arrow keys.\nPoint and click to shoot.\n Hold SHIFT or SPACE to enter PRECISION MODE.");
		buddySprite = new FlxSprite(30, 80, "assets/images/buddy.png");
		buddyText = new FlxText(60, 80, FlxG.width - 80, "Move near a buddy to become their OVERLORD.");
		olSprite = new FlxSprite(30, 110, "assets/images/overlord.png");
		olText = new FlxText(60, 110, FlxG.width - 80,
			"You must defend yourself against the ENEMY OVERLORDS.\n Kill them to steal their BUDDIES.\n\nBuddies multiply your score!\n\n\nSACRIFICE MODE: Collect buddies before your enemies do and take them to your GOAL.\nStop your enemies from scoring points by killing\n(or stealing) their buddies. First to 30 points wins.");

		backButton = new FlxButton(30, FlxG.width - 60, "MAIN MENU", closeHelp);
		add(backButton);

		add(genText);
		add(buddySprite);
		add(buddyText);
		add(olSprite);
		add(olText);
		genText.visible = false;
		buddySprite.visible = false;
		buddyText.visible = false;
		olSprite.visible = false;
		olText.visible = false;
		backButton.visible = false;
		// NG.core.verbose = true;
	}

	function help()
	{
		// === main vars
		playButton.visible = false;
		helpButton.visible = false;
		sacButton.visible = false;

		// === help vars ===
		genText.visible = true;
		buddySprite.visible = true;
		buddyText.visible = true;
		olSprite.visible = true;
		olText.visible = true;
		backButton.visible = true;


		background.loadGraphic("assets/images/helpBg.png");
	}

	function closeHelp()
	{
		// === main vars
		playButton.visible = true;
		helpButton.visible = true;
		sacButton.visible = true;

		// === help vars ===
		genText.visible = false;
		buddySprite.visible = false;
		buddyText.visible = false;
		olSprite.visible = false;
		olText.visible = false;
		backButton.visible = false;


		background.loadGraphic("assets/images/menuImg.png");
	}

	function toggleMusic()
	{
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
			musicButton.text = "MUSIC: OFF";
		}
		else
		{
			FlxG.sound.music.play();
			musicButton.text = "MUSIC: ON";
		}
	}
	function musicUp()
	{
		FlxG.sound.music.volume += 0.1;
		volumeText.text = Std.string(Math.round(FlxG.sound.music.volume * 100)) + "%";
	}

	function musicDown()
	{
		FlxG.sound.music.volume -= 0.1;
		volumeText.text = Std.string(Math.round(FlxG.sound.music.volume * 100)) + "%";
	}
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
	}
}