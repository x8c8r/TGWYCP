package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var ply:Player;
	var pump:FlxTypedGroup<Pumpkin> = new FlxTypedGroup<Pumpkin>();

	var over:Bool = false;
	var score:Int = 0;
	var highScore:Int = 0;

	var speed:Float = 50;
	var defaultTime:Float;
	var time:Float;

	var scoreText:FlxText;
	var highscoreText:FlxText;
	var modeText:FlxText;

	var rand:FlxRandom = new FlxRandom();
	var timer:FlxTimer;
	var rct:FlxTimer;

	var colors:Array<Dynamic>;

	public static var gamemode:Int = 0; // 0 - Normal; 1 - Hard; 2 - Survival

	var controls:FlxSprite;
	var camWall:FlxGroup;

	var musicToggle:Bool = true;
	var bgToggle:Bool = true;

	override public function create()
	{
		switch (gamemode)
		{
			case 2:
				defaultTime = 0.1;
			default:
				defaultTime = 2;
		}

		super.create();

		bgColor = generateBg();

		FlxG.sound.playMusic("assets/sounds/music.wav", 0.75, true);

		camWall = FlxCollision.createCameraWall(FlxG.camera, true, 1, false);

		ply = new Player(FlxG.width / 2, FlxG.height - 16);
		add(ply);

		timer = new FlxTimer();
		add(pump);

		scoreText = new FlxText(0, 0, 0, "Score: 0", 20);
		highscoreText = new FlxText(0, 35, 0, "HighScore: 0", 20);
		scoreText.antialiasing = false;
		highscoreText.antialiasing = false;
		add(scoreText);
		add(highscoreText);

		var gmText:String = "";
		modeText = new FlxText(0, 70, 0, "", 20);
		switch (gamemode)
		{
			case 0:
				gmText = "Normal Mode";
				modeText.color = FlxColor.WHITE;
			case 1:
				gmText = "Hard Mode";
				modeText.color = FlxColor.RED;
			case 2:
				gmText = "Rotten Rain";
				modeText.color = FlxColor.PURPLE;
		}
		modeText.text = gmText;
		add(modeText);

		controls = new FlxSprite(0, 0);
		controls.loadGraphic("assets/images/controls.png");
		controls.screenCenter(XY);
		controls.antialiasing = false;
		add(controls);
		FlxTween.tween(controls, {"scale.x": 3, "scale.y": 3}, 0.5, {ease: FlxEase.quadInOut, type: FlxTweenType.ONESHOT});

		rct = new FlxTimer();
		rct.start(3, function(_)
		{
			timer.start(defaultTime, make, 0);
			FlxTween.tween(controls, {"alpha": 0}, 0.5, {
				onComplete: function(_)
				{
					controls.destroy();
				}
			});
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (speed >= 150)
			speed = 150;

		if (gamemode == 0 || gamemode == 1)
		{
			time = 25 / speed * 4;
			timer.time = time;
		}

		FlxG.collide(ply, camWall);

		pump.forEach(function(p:Pumpkin)
		{
			if (p == null)
			{
				pump.remove(p);
				trace(p);
				return;
			}

			if (p.velocity.y != speed)
				p.velocity.y = speed;

			FlxG.collide(ply, p, function(d1, d2)
			{
				if (p.bad)
					reset();
				else
					pumpkinCollision(d1, d2);
			});

			if (p.y > FlxG.height)
			{
				if (!p.bad)
					over = true;
				else
				{
					addScore();
					pump.remove(p, true);
					p.destroy();
				}
			}

			if (over)
			{
				pump.remove(p, true);
				p.destroy();
				reset();
			}
		});

		if (FlxG.keys.justPressed.R && rct.finished)
			reset();

		if (FlxG.keys.pressed.ESCAPE)
		{
			if (FlxG.sound.music != null)
				FlxTween.tween(FlxG.sound.music, {"volume": 0}, 0.33);
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		if (FlxG.keys.justPressed.M)
			musicToggle = !musicToggle;
		FlxG.sound.music.volume = musicToggle ? 0.75 : 0;
		if (FlxG.keys.justPressed.B)
		{
			bgToggle = !bgToggle;
			bgColor = bgToggle ? generateBg() : FlxColor.BLACK;
		}
	}

	function make(_):Void
	{
		var bad:Bool = (rand.int(0, 10) / 1 == 1 && score > 20 && gamemode == 0)
			|| (rand.int(0, 20) / 1 == 1 && score > 50 && gamemode == 1)
			|| gamemode == 2;
		var p:Pumpkin = new Pumpkin(rand.int(0, FlxG.width - 32), -32, bad);
		pump.add(p);
	}

	function addScore()
	{
		score += 1;
		if (gamemode == 0)
			speed += 1;
		else if (gamemode == 1)
			speed += 2;

		if (gamemode != 2)
			FlxG.sound.play("assets/sounds/collect.wav");

		if (score > highScore)
			highScore = score;

		scoreText.text = "Score: " + score;
		highscoreText.text = "HighScore: " + highScore;
	}

	function pumpkinCollision(ply:FlxSprite, p:Pumpkin)
	{
		ply.velocity.y = 0; // I HAVE NO CLUE WHY PLAYER GETS 50 VELOCITY WHEN COLLIDING
		ply.y = FlxG.height - 16;

		p.destroy();
		pump.remove(p, true);

		addScore();
	}

	function reset()
	{
		pump.clear();
		timer.reset(defaultTime);
		score = 0;
		speed = 50;
		FlxG.sound.play("assets/sounds/miss.wav");
		FlxG.camera.shake(0.01, 0.1);
		scoreText.text = "Score: 0";
		over = false;
		bgColor = bgToggle ? generateBg() : FlxColor.BLACK;
	}

	function generateBg():FlxColor
	{
		colors = [rand.int(0, 50), rand.int(0, 50), rand.int(0, 50)];
		return FlxColor.fromRGB(colors[0], colors[1], colors[2]);
	}
}
