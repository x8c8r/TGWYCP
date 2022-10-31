package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class MainMenuState extends FlxState
{
	var title:FlxText;
	var enterText:FlxText;
	var modeText:FlxText;
	var modeDescriptionText:FlxText;
	var creditText:FlxText;

	var started:Bool = false;

	var gamemode:Int = PlayState.gamemode;

	var modeNum:String; // Defining here to save memory
	var modeDesc:String;

	override function create()
	{
		super.create();

		bgColor = FlxColor.BLACK;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		title = new FlxText(0, 50, 0, "The game where you catch pumpkins", 30, true);
		title.color = FlxColor.ORANGE;
		title.screenCenter(X);
		title.updateHitbox();
		add(title);
		FlxTween.tween(title, {y: title.y + 50}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

		modeText = new FlxText(0, 250, 0, "Mode: Placeholder", 20, true);
		modeText.color = FlxColor.WHITE;
		modeText.updateHitbox();
		add(modeText);

		modeDescriptionText = new FlxText(0, 275, 0, "Placeholder", 15, true);
		modeDescriptionText.color = FlxColor.WHITE;
		modeDescriptionText.updateHitbox();
		add(modeDescriptionText);

		enterText = new FlxText(0, 350, 0, "Press enter to play", 20, true);
		enterText.color = FlxColor.WHITE;
		enterText.screenCenter(X);
		enterText.updateHitbox();
		add(enterText);

		creditText = new FlxText(0, 600, 0, "Made by x8c8r in a week.", 15);
		creditText.color = FlxColor.fromString("#3292E7");
		creditText.screenCenter(X);
		creditText.updateHitbox();
		add(creditText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if desktop
		if (FlxG.keys.pressed.ESCAPE)
			Sys.exit(0);
		#end

		if (FlxG.keys.pressed.ENTER)
		{
			PlayState.gamemode = gamemode;
			FlxTween.tween(enterText, {"color": FlxColor.GREEN}, 0.1);
			if (!started)
				FlxG.sound.play("assets/sounds/start.wav");
			started = true;
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
			{
				FlxG.switchState(new PlayState());
			});
		}

		if (FlxG.keys.anyJustPressed([RIGHT, D]))
			gamemode += 1;
		if (FlxG.keys.anyJustPressed([LEFT, A]))
			gamemode -= 1;
		if (FlxG.keys.anyJustPressed([RIGHT, LEFT, D, A]))
			FlxG.sound.play("assets/sounds/select.wav");

		if (gamemode >= 3)
			gamemode = 0;
		if (gamemode <= -1)
			gamemode = 2;

		switch (gamemode)
		{
			case 0:
				modeNum = "Normal Mode";
				modeDesc = "The way it's meant to be played";
				modeText.color = FlxColor.WHITE;
			case 1:
				modeNum = "Hard Mode";
				modeDesc = "Everything just got a little harder";
				modeText.color = FlxColor.RED;
			case 2:
				modeNum = "Rotten Rain";
				modeDesc = "There are a lot of rotten pumpkins this season eh?";
				modeText.color = FlxColor.PURPLE;
		}
		modeText.text = "Mode: " + modeNum + " (Press Left or Right to switch)";
		modeDescriptionText.text = modeDesc;
		modeText.screenCenter(X);
		modeDescriptionText.screenCenter(X);
	}
}
