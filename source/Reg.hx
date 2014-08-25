package;

import flixel.math.FlxRandom;

class Reg
{
	
	public static var playerWon:Bool = false;
	public static var playState:PlayState;
	public static var rng:FlxRandom;
	
	public static var levels:Array<Dynamic> = [];
	public static var level:Int = 0;

	public static var score:Int = 0;
	public static var lost:Int = 0;
	public static var launched:Int = 0;
}