package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import kacount.GameScreen;
	import kacount.Monster;
	import kacount.MonsterSpawn;
	import kacount.SpawnPoint;
	import kacount.util.RNG;
	
	[SWF(frameRate="60", width="1024", height="768")]
	public class Main extends Sprite {
		[Embed(source="game.swf", symbol="Screen")]
		private static var Screen:Class;
		
		[Embed(source="game.swf", symbol="Monster1")]
		private static var Monster1:Class;
		[Embed(source="game.swf", symbol="Monster2")]
		private static var Monster2:Class;
		[Embed(source="game.swf", symbol="Monster3")]
		private static var Monster3:Class;
		
		private static var monsterClasses:Array = [ Monster1, Monster2, Monster3 ];
		
		public function Main() {
			this.stage.frameRate = 60;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var screen:DisplayObjectContainer = new Screen();
			var gs:GameScreen = new GameScreen(screen);
			
			var rng:RNG = new RNG();
			gs.spawnPoints.forEach(function (spawnPoint:SpawnPoint, _i:uint, _array:*):void {
				var delay:Number = rng.rand(0, 2000);
				var interval:Number = rng.rand(700, 1400);
				var count:uint = rng.rand(4, 12);
				
				MonsterSpawn.tick(delay, interval, count, function ():void {
					var artClass:Class = rng.sample(monsterClasses);
					var speed:Number = rng.rand(2, 10);
					
					var art:DisplayObject = new artClass();
					spawnPoint.pos.toDisplayObject(art);
					
					var m:Monster = new Monster(art, spawnPoint.velocity.scale1(speed));
					gs.spawnMonster(m);
				});
			});
			
			this.addChild(screen);
			this.addEventListener(Event.ENTER_FRAME, function (event:Event):void {
				gs.tick();
			});
		}
	}
}
