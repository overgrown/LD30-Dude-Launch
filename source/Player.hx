package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Player extends FlxSpriteGroup
{
	
	public var boat:FlxSprite;
	public var ladder:FlxSprite;
	
	public var ladderAngle:Float;
	
	public function new(X:Float,Y:Float,boatAsset:FlxGraphicAsset,ladderAsset:FlxGraphicAsset,jumper:FlxGraphicAsset)
	{
		super(X, Y);
		boat = new FlxSprite(X, Y, boatAsset);
		add(boat);
		
		ladderAngle = 180;
		var ladderHeight = 50;
		width = boat.width;
		height = ladderHeight;
		
		ladder = new FlxSprite(X + width / 2, 0, ladderAsset);
		ladder.y = Y-ladder.height/2;
		add(ladder);
		
		add(new FlxSprite(boat.width/2,-8,jumper));
	}

	public function move():Void
	{
		acceleration.x = 0;
		acceleration.y = 0;
		ladder.angularAcceleration = 0;
		if (ladder.angle < 0) {
			ladder.angularAcceleration = -50 + ladder.angle;
		}else {
			ladder.angularAcceleration = 50 + ladder.angle;
		}
		
		var left:Bool = false;
		var right:Bool = false;
		var rotLeft:Bool = false;
		var rotRight:Bool = false;
		var jump:Bool = false;
		
		left = FlxG.keys.anyPressed(["A"]);
		right = FlxG.keys.anyPressed(["L"]);
		rotLeft = FlxG.keys.anyPressed(["S"]);
		rotRight = FlxG.keys.anyPressed(["K"]);
		jump = FlxG.keys.anyJustPressed(["SPACE"]);
		
		
		if (left == right) {
			left = right= false;
		}
		if (rotLeft == rotRight) {
			rotLeft = rotRight = false;
		}
		
		if (left) {
			acceleration.x = -100;
		}
		if (right) {
			acceleration.x = 100;
		}
		if (rotLeft) {
			ladder.angularAcceleration = -250;
			if (ladder.angle < -75) {
				ladder.angularVelocity = 10;
			}
		}
		if (rotRight) {
			ladder.angularAcceleration = 250;
			if (ladder.angle > 75) {
				ladder.angularVelocity = -10;
			}
		}
		
		if (ladder.angle * acceleration.x > 0) {
			ladder.angularAcceleration += acceleration.x;
		} else {
			ladder.angularAcceleration -= acceleration.x;
		}
		
		if (jump) {
			var pivot = new FlxPoint(ladder.x + ladder.width / 2, ladder.y + ladder.height / 2);
			var jPoint = new FlxPoint(ladder.x + ladder.width / 2, ladder.y).rotate(pivot, ladder.angle);
			Reg.playState.addJumper(jPoint.x,jPoint.y);
		}
		
		if (FlxG.keys.anyJustPressed(["M"])) {
			if (FlxG.sound.music.active == true) {
				FlxG.sound.music.stop();
			}else {
				FlxG.sound.music.play();
			}
		}
	}
	
	override public function update():Void {
		move();

		super.update();
		if (ladder.angle < -85) {
			ladder.angle = -85;
			if (ladder.angularVelocity < 0) {
				ladder.angularVelocity = 0;
			}
		}
		if (ladder.angle > 85) {
			ladder.angle = 85;
			if (ladder.angularVelocity > 0) {
				ladder.angularVelocity = 0;
			}
		}
		
		if (x < -boat.width) {
			x = FlxG.width;
		}
		if (x > FlxG.width) {
			x = -boat.width;
		}
	}
	
}