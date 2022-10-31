package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Pumpkin extends FlxSprite
{
	var sprite:FlxSprite;
	var speed:Int = 10;

	public var bad:Bool;

	public function new(x:Float, y:Float, bad:Bool)
	{
		super(x, y);

		this.bad = bad;

		if (!bad)
			sprite = loadGraphic("assets/images/pumpkin.png");
		else
			sprite = loadGraphic("assets/images/badpumpkin.png");
		sprite.antialiasing = false;
		setGraphicSize(32, 32);
		// velocity.y = 200;

		updateHitbox();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
