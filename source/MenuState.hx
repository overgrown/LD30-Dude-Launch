package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;

class MenuState extends FlxState
{
	
	public var titleMoon:FlxSprite;
	public var titleSea:FlxSprite;
	public var instructions:FlxSprite;
	public var playGame:FlxButtonPlus;
	public var instBtn:FlxButtonPlus;
	public var sandboxBtn:FlxButtonPlus;
	public var unlimitedBtn:FlxButtonPlus;
	
	override public function create():Void
	{
		
		FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
		FlxG.sound.playMusic(Assets.getMusic("assets/music/the_wings_ghost.mp3"), 1, true);
		
		// reset counters
		Reg.score = 0;
		Reg.lost = 0;
		Reg.launched = 0;
		Reg.level = 0;
		
		var stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 300);
		stars.setStarSpeed(1, 75);
		add(stars);
		
		titleMoon = new FlxSprite(FlxG.width / 2, 25, Assets.getBitmapData("assets/images/titleMoon.png"));
		titleMoon.x -= titleMoon.width / 2;
		titleSea = new FlxSprite(0, FlxG.height - 25, Assets.getBitmapData("assets/images/sea.png"));
		add(titleMoon);
		add(titleSea);
		
		add(new FlxSprite(FlxG.width/2 - 25, FlxG.height - 35, Assets.getBitmapData("assets/images/boat.png")));
		add(new FlxSprite(FlxG.width/2 - 2.5, FlxG.height - 35 - 50, Assets.getBitmapData("assets/images/ladder.png")));
		
		playGame = new FlxButtonPlus(FlxG.width / 2 - 50, 210, startGame, "PLAY GAME");
		playGame.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		instBtn = new FlxButtonPlus(FlxG.width / 2 - 50, 235, showInstructions, "INSTRUCTIONS");
		instBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		unlimitedBtn = new FlxButtonPlus(FlxG.width / 2 - 50, 260, endlessMode, "ENDLESS MODE");
		unlimitedBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		sandboxBtn = new FlxButtonPlus(FlxG.width / 2 - 50, 285, startSandbox, "INFINITE DUDES (SANDBOX)", 100, 30);
		sandboxBtn.updateInactiveButtonColors([FlxColor.BLUE, FlxColor.BLACK]);
		add(playGame);
		add(instBtn);
		add(unlimitedBtn);
		add(sandboxBtn);
		
		instructions = new FlxSprite(0, FlxG.height - 125);
		instructions.makeGraphic(FlxG.width, 120, FlxColor.BLACK);
		var instText:String = "Launch Dudes so they land safely on the Moon.\n\n";
		instText += "Press and hold A and L to move the boat.\n";
		instText += "Press and hold S and K to move the ladder.\nSPACE to launch Dudes, ESC to quit, M to mute.\n";
		instText += "(CYAN means safe, BLUE and RED mean dead)";
		var inst = new FlxText(0, 0, 0, instText, 16);
		inst.addFormat(new FlxTextFormat(0x00FFFF,false,false,0x00FFFF),instText.length-40,instText.length-36);
		inst.addFormat(new FlxTextFormat(0x0000FF,false,false,0x0000FF),instText.length-24,instText.length-19);
		inst.addFormat(new FlxTextFormat(0xFF0000,false,false,0xFF0000),instText.length-15,instText.length-11);
		instructions.stamp(inst, 100, 0);
		add(instructions);
		instructions.kill();
		
		super.create();
	}
	
	public function startGame():Void {
		// level data, hardcoded (sorry)
		Reg.levels = [];
		Reg.levels.push({numTotalGuys : 10, numToSave: 2, endless: false});
		Reg.levels.push({numTotalGuys : 100, numToSave: 10, endless: false});
		Reg.levels.push({numTotalGuys : 20, numToSave: 5, endless: false});
		Reg.levels.push({numTotalGuys : 80, numToSave: 15, endless: false});
		Reg.levels.push({numTotalGuys : 30, numToSave: 10, endless: false});
		Reg.levels.push({numTotalGuys : 60, numToSave: 25, endless: false});
		Reg.levels.push({numTotalGuys : 40, numToSave: 20, endless: false});
		Reg.levels.push({numTotalGuys : 50, numToSave: 35, endless: false});
		Reg.levels.push({numTotalGuys : 40, numToSave: 40, endless: false});
		Reg.levels.push({numTotalGuys : 1, numToSave: 1, endless: false});

		FlxG.switchState(new PlayState());
	}
	public function endlessMode():Void {
		Reg.levels = [];
		var randomTotal:Int = Reg.rng.int(1,(Reg.level+1)*10);
		var randomSave:Int = Reg.rng.int(1,randomTotal);
		Reg.levels.push({numTotalGuys : randomTotal, numToSave: randomSave, endless: true});

		FlxG.switchState(new PlayState());
	}
	public function startSandbox():Void {
		Reg.levels = [];
		Reg.levels.push({numTotalGuys : FlxMath.MAX_VALUE_INT, numToSave: FlxMath.MAX_VALUE_INT});
		FlxG.switchState(new PlayState());
	}
	public function showInstructions():Void {
		instructions.revive();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		if (FlxG.keys.anyJustPressed(["M"])) {
			if (FlxG.sound.music.active == true) {
				FlxG.sound.music.stop();
			}else {
				FlxG.sound.music.play();
			}
		}

		super.update();
	}	
}