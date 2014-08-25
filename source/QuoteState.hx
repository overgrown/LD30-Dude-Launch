package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class QuoteState extends FlxState
{
	
	override public function create():Void
	{
		FlxG.camera.flash(FlxColor.BLACK, 5, finishFlash);
		
		// format Calvino quote
		var quote:String = "";
		quote += "\"Orbit? Oh, elliptical, of course: for a while it would huddle\n";
		quote += "against us and then it would take flight for a while.\n\n";
		quote += "The tides, when the Moon swung closer, rose so high nobody\n";
		quote += "could hold them back.\n\n";
		quote += "There were nights when the Moon was full and very, very low,\n";
		quote += "and the tide was so high that the Moon missed a ducking\n";
		quote += "in the sea by a hair’s-breadth; well, let’s say a few yards\n";
		quote += "anyway.\n\n";
		quote += "Climb up on the Moon? Of course we did. All you had to do\n";
		quote += "was row out to it in a boat and, when you were underneath it,\n";
		quote += "prop a ladder against her and scramble up...\"";
		
		add(new FlxText(20, 25, 0, quote, 16));
		add(new FlxText(180, 325, 0, "- Italo Calvino, \"The Distance of the Moon\"", 16));
		
		var timer:FlxTimer = new FlxTimer();
		timer.start(8,showSpace);
		super.create();
	}
	
	public function finishFlash():Void {
		// had some ideas for this callback, not enough time
	}
	
	public function showSpace(timer:FlxTimer):Void {
		add(new FlxText(FlxG.width - 150, FlxG.height - 30, 0, "PRESS SPACE", 16));
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		var skip = FlxG.keys.anyJustPressed(["SPACE"]);
		if (skip) {
			FlxG.switchState(new MenuState());
		}
		super.update();
	}	
}