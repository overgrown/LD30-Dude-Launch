package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

class PlayState extends FlxState
{
	
	public static var TERMINAL_VELOCITY = 35;

	public var t:Int;
	public var timer:FlxTimer;
	public var splash:FlxSprite;
	public var showingSplash:Bool = true;
	
	public var moon:FlxSprite;
	public var sea:FlxSprite;
	public var sky:FlxSprite;
	public var stars:FlxStarField2D;
	public var player:Player;
	
	public var jumpers:FlxTypedGroup<Jumper>;
	public var exploderRed:FlxEmitter;
	public var exploderBlue:FlxEmitter;
	public var exploderCyan:FlxEmitter;
	
	public var setMoonGoal:Bool = false;
	public var moonGoalX:Float;
	
	public var stats:FlxText;
	public var numSaved:Int = 0;
	public var numOutThere:Int = 0;
	public var numSquished:Int = 0;
	public var numDrowned:Int = 0;
	public var numAvailable:Int;
	public var numTotalGuys:Int;
	public var numToSave:Int;
	public var endless:Bool;

	
	override public function create():Void
	{
		//static reference for convenience
		Reg.playState = this;
		
		// t is counter, used for moon and sea position
		t = Reg.rng.int(0,300);
		
		// load level data
		numTotalGuys = Reg.levels[Reg.level].numTotalGuys;
		numToSave = Reg.levels[Reg.level].numToSave;
		endless = Reg.levels[Reg.level].endless;
		numAvailable = numTotalGuys;
		
		sky = new FlxSprite(0, 0);
		sky.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(sky);
		
		stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 300);
		stars.setStarSpeed(1, 75);
		add(stars);
		
		moon = new FlxSprite(0, 0, Assets.getBitmapData("assets/images/moon.png"));
		moon.immovable = true;
		moonGoalX = Reg.rng.float(0, -moon.width / 2.0 - 20);
		updateMoon();
		add(moon);
		
		jumpers = new FlxTypedGroup<Jumper>();
		add(jumpers);
		
		sea = new FlxSprite(0, 0, Assets.getBitmapData("assets/images/sea.png"));
		updateSea();
		add(sea);
		
		player = new Player(0, 0, Assets.getBitmapData("assets/images/boat.png"),
								  Assets.getBitmapData("assets/images/ladder.png"),
								  Assets.getBitmapData("assets/images/jumper.png"));
		player.x += player.width * 2;
		player.y = sea.y - player.height;
		add(player);
		
		// emitters when jumpers perish
		exploderRed = new FlxEmitter();
		exploderBlue = new FlxEmitter();
		exploderCyan = new FlxEmitter();
		exploderRed.makeParticles(2, 2, FlxColor.RED, 300);
		exploderBlue.makeParticles(2, 2, FlxColor.BLUE, 300);
		exploderCyan.makeParticles(2, 2, FlxColor.CYAN, 300);
		add(exploderRed);
		add(exploderBlue);
		add(exploderCyan);
		
		// show how many jumpers are left, died, etc.
		stats = new FlxText(0, 0);
		add(stats);
		
		// splash screen before level starts
		showingSplash = true;
		splash = new FlxSprite(0, 0);
		splash.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		var splashText:String = "Level " + (Reg.level+1) + "\n\nSave " + numToSave + " of " + numAvailable + " dudes";
		splash.stamp(new FlxText(0,0, 0, splashText, 16),Math.ceil(FlxG.width/2-100), Math.ceil(FlxG.height/2-100));
		add(splash);
		timer = new FlxTimer();
		timer.start(4, hideSplash, 1);
		
		super.create();
	}
	
	public function hideSplash(timer:FlxTimer):Void {
		splash.kill();
		showingSplash = false;
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}
	
	public function updateMoon():Void {
		// moon moves sinusoidally, picks a random x target
		moon.y = -moon.height / 2 - 100 * Math.cos(t / 150.0);
		moon.x = moonGoalX * Math.cos(t / 300.0 + Math.PI / 2.0);
		if (setMoonGoal == false && Math.cos(t / 150.0) > 0.999) {
			moonGoalX = Reg.rng.float(0, -moon.width / 2.0 - 20);
			setMoonGoal = true;
		}else if (Math.cos(t / 150.0) < 0.5) {
			setMoonGoal = false;
		}
	}
	public function updateSea():Void {
		// sea moves sinusoidally
		sea.y = (FlxG.height - 100) + 75 * Math.cos(t / 100.0);
		sea.x = FlxG.width / 2 - sea.width / 2;
	}
	public function updateBoat():Void {
		// lock player y to sea y
		player.y = sea.y - player.boat.height;
	}
	public function addJumper(jX:Float, jY:Float):Void {
		// callback when user presses key to jump
		if (showingSplash) {
			// disallow jump input during splash
			return;
		}
		if (numOutThere + numSaved + numSquished + numDrowned >= numTotalGuys) {
			// disallow any more jumpers
			return;
		}
		FlxG.sound.play("assets/sounds/jump.wav");
		Reg.launched += 1;
		var jumper:Jumper = new Jumper(jX, jY, Assets.getBitmapData("assets/images/jumper.png"));
		jumpers.add(jumper);
		numOutThere += 1;
		numAvailable -= 1;
		jumper.jump(jX,jY,player.ladder.angle);
	}
	 
	public function explodeJumper(b:Jumper, exploder:FlxEmitter):Void {
		exploder.x = b.x;
		exploder.y = b.y;
		exploder.start(true, 0, 3);
		exploder.update();
		jumpers.remove(b);
		numOutThere += -1;
		b.destroy();
	}
	
	public function lostInSea(jumper:Jumper):Void {
		numDrowned += 1;
		FlxG.sound.play("assets/sounds/drowned.wav");
		explodeJumper(jumper, exploderBlue);
	}
	public function lostInSpace(jumper:Jumper):Void {
		numSquished += 1;
		FlxG.sound.play("assets/sounds/squished.wav");
		explodeJumper(jumper, exploderRed);
	}
	
	public function testCollisionMoon(a:Dynamic, b:Dynamic):Void {
		if (FlxCollision.pixelPerfectCheck(a, b)) {
			if (new FlxVector(b.velocity.x, b.velocity.y).length > TERMINAL_VELOCITY) {
				numSquished += 1;
				FlxG.sound.play("assets/sounds/squished.wav");
				explodeJumper(b,exploderRed);
			}else {
				numSaved += 1;
				FlxG.sound.play("assets/sounds/saved.wav");
				explodeJumper(b, exploderCyan);
			}
		}
	}
	
	public function testCollisionSea(a:Dynamic, b:Dynamic):Void {
		if (FlxCollision.pixelPerfectCheck(a, b)) {
			numDrowned += 1;
		FlxG.sound.play("assets/sounds/drowned.wav");
			explodeJumper(b, exploderBlue);
		}
	}
	
	public function updateStats():Void {
		stats.text = "";
		stats.text += "Dudes Left: "+numAvailable+"\n";
		stats.text += "Dudes Floating: "+numOutThere+"\n";
		stats.text += "Dudes Squished: "+numSquished+"\n";
		stats.text += "Dudes Drowned: "+numDrowned+"\n";
		stats.text += "Dudes Saved: "+numSaved;
	}
	
	public function checkWinLose():Void {
		if (numSaved >= numToSave) {

			Reg.level += 1;
			
			// for endless mode
			if (endless) {
				var randomTotal:Int = Reg.rng.int(1,(Reg.level+1)*10);
				var randomSave:Int = Reg.rng.int(1,randomTotal);
				Reg.levels.push( { numTotalGuys : randomTotal, numToSave: randomSave, endless: true } );

				Reg.score += numSaved;
				Reg.lost += numDrowned + numSquished;
				FlxG.switchState(new PlayState());
				return;
			}
			
			// otherwise store score and get next level / end state
			if (Reg.level < Reg.levels.length) {
				Reg.score += numSaved;
				Reg.lost += numDrowned + numSquished;
				FlxG.switchState(new PlayState());
				return;
			}else {
				Reg.score += numSaved;
				Reg.lost += numDrowned + numSquished;
				Reg.playerWon = true;
				
				FlxG.switchState(new LoseState());
				return;
			}
		}
		if (numAvailable + numOutThere <= 0 || FlxG.keys.anyJustPressed(["ESCAPE"])) {
			Reg.score += numSaved;
			Reg.lost += numDrowned + numSquished;
			
			FlxG.switchState(new LoseState());
			return;
		}
	}

	override public function update():Void
	{
		
		if (showingSplash == false) {
			checkWinLose();
			updateMoon();
			updateSea();
			updateBoat();
			updateStats();
		}

		super.update();

		if (showingSplash == false) {
			FlxG.overlap(moon, jumpers, testCollisionMoon);
			FlxG.overlap(sea, jumpers, testCollisionSea);
			t += 1;
		}
	}	
}
