package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Jumper extends FlxSprite
{
	public var speed:Float;
	
	// values to get gravity working in a fun way
	public var R:Float = 2.50 * Math.pow(10, 5);
	public var G:Float = 6.67 * Math.pow(10,-11);
	public var jMass:Float = 5.974 * Math.pow(10, 10);
	public var moonMass:Float = 1.989 * Math.pow(10, 25);
	public var seaMass:Float = 4.0 * Math.pow(10, 25);
	
	public function new(X:Float,Y:Float,Asset:FlxGraphicAsset)
	{
		super(X,Y,Asset);
		speed = 120;
	}
	
	public function convert(n:Float):Float {
		return n*2*R - R;
	}
	
	public function calcForce(body:FlxSprite, targetMass:Float, vertical:Bool):Void {
		// calculate net forces (gravity acting on jumper)
		var midBodyX:Float = body.x + body.width / 2;
		var midBodyY:Float = body.y + body.height / 2;
		if (vertical) {
			midBodyX = x;
			midBodyY *= 2;
		}
		var deltaX:Float = convert(midBodyX) - convert(x);
		var deltaY:Float = convert(midBodyY) - convert(y);
		var dist:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		var F:Float = (G * jMass * targetMass) / (dist * dist);
		var fX:Float = F * (deltaX / dist);
		var fY:Float = F * (deltaY / dist);
		acceleration.x += fX / jMass;
		acceleration.y += fY / jMass;
	}
	
	override public function update():Void {
		calcForce(Reg.playState.moon,moonMass,false);
		calcForce(Reg.playState.sea,seaMass,true);
		super.update();
		
		if (x < -Reg.playState.player.boat.width) {
			x = FlxG.width;
		}
		if (x > FlxG.width) {
			x = -Reg.playState.player.boat.width;
		}
		if (y > FlxG.height) {
			Reg.playState.lostInSea(this);
		}
		if (y < -20) {
			Reg.playState.lostInSpace(this);
		}
	}
	
	public function jump(jX:Float,jY:Float,jAngle:Float):Void
	{
		x = jX - width/2;
		y = jY - height/2;
		angle = jAngle;
		var temp = new FlxPoint(0, speed);
		temp = temp.rotate(new FlxPoint(0, 0), angle);
		velocity.x = -temp.x / 5;
		velocity.y = -temp.y / 5;
	}
}