package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	var sprite:FlxSprite;
	var speed:Float = 5;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		// sprite = makeGraphic(16, 16, FlxColor.BLUE);
		sprite = loadGraphic("assets/images/player.png");

		velocity.y = 0;

		updateHitbox();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMovement();
	}

	function updateMovement()
	{
		var right:Bool = FlxG.keys.anyPressed([RIGHT, D]);
		var left:Bool = FlxG.keys.anyPressed([LEFT, A]);
		var sprint:Bool = FlxG.keys.anyPressed([SPACE]);

		if (sprint)
			speed = 17.5;
		else
			speed = 5;

		if (right)
			x += speed;
		if (left)
			x -= speed;
		if ((left && right))
			return;
	}
}
