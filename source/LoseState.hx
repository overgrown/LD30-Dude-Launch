package;

import flixel.addons.ui.FlxButtonPlus;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;


class LoseState extends FlxState
{
	
	public var emitter:FlxEmitter;
	
	override public function create():Void
	{
		emitter = new FlxEmitter();
		add(emitter);
		emitter.x = Reg.rng.int(0, FlxG.width);
		emitter.y = Reg.rng.int(0, FlxG.height);
		emitter.loadParticles(Assets.getBitmapData("assets/images/jumper.png"), 500, 0, false);
		emitter.start(true, 0, 10);

		
		var finalScore:Float = ((Reg.score - Reg.lost) * 123456.0) / Reg.launched;
		
		
		if (Reg.playerWon) {
			add(new FlxText(100, 100, 0, "YOU WON!!!!!!!!", 16));
			finalScore *= 100;
		}else {
			add(new FlxText(100, 100, 0, "GAME OVER -- YOU LOST", 16));
		}
		add(new FlxText(100, 120, 0, "You launched: " + Reg.launched + " dudes", 16));
		add(new FlxText(100, 140, 0, "You lost: " +  Reg.lost + " dudes", 16));
		add(new FlxText(100, 160, 0, "You saved: " + Reg.score + " dudes", 16));
		add(new FlxText(100, 180, 0, "FINAL SCORE: " + Math.ceil(finalScore), 16));
		
		var btn:FlxButtonPlus = new FlxButtonPlus(100, 220, restart, "GO TO MENU");
		btn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(btn);
		super.create();
	}
	
	public function restart():Void {
		FlxG.switchState(new MenuState());
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		if (Reg.rng.int(0, 20) < 1) {
			emitter.x = Reg.rng.int(0, FlxG.width);
			emitter.y = Reg.rng.int(0, FlxG.height);
			emitter.start(true, 0 , 10);
		}
		super.update();
	}	
}