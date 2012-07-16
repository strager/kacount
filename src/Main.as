package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.setInterval;
	
	import kacount.GameScreen;
	import kacount.Monster;
	import kacount.MonsterSpawn;
	import kacount.SpawnPoint;
	import kacount.util.Async;
	import kacount.util.Ev;
	import kacount.util.F;
	import kacount.util.Histogram;
	import kacount.util.RNG;
	import kacount.util.Touch;
	
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
		
		private function init():void {
			this.stage.frameRate = 60;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		public function Main() {
			this.init();
			this.playRound();
		}
		
		private function playRound():void {
			var screen:DisplayObjectContainer = new Screen();
			var gs:GameScreen = new GameScreen(screen);
			
			var monsterHist:Histogram = new Histogram();
			var playerHist:Histogram = new Histogram();
			
			function playerHit(playerIndex:uint):void {
				playerHist.inc(playerIndex);
				gs.players[playerIndex].gotoAndPlay('click');
			}
			
			gs.players.forEach(function (player:MovieClip, playerIndex:uint, _array:*):void {
				Touch.down(player, function onDown():void {
					playerHit(playerIndex);
				});
			});
			
			var playerKeys:Vector.<uint> = new <uint>[Keyboard.Q, Keyboard.P];
			Ev.on(this.stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
				var playerIndex:int = playerKeys.indexOf(event.keyCode);
				if (playerIndex >= 0) {
					playerHit(playerIndex);
				}
			});
			
			var goals:Vector.<Class> = new <Class>[Monster1, Monster3];
			
			var rng:RNG = new RNG();
			var spawners:Vector.<Function> = F.map(
				gs.spawnPoints, Vector.<Function>,
				function (spawnPoint:SpawnPoint):Function {
					var delay:Number = rng.rand(0, 2000);
					var interval:Number = rng.rand(700, 1400);
					var count:uint = rng.rand(4, 12);
					
					return function (callback:Function):void {
						MonsterSpawn.tick(delay, interval, count, function ():void {
							var artClass:Class = rng.sample(monsterClasses);
							monsterHist.inc(artClass);
							var speed:Number = rng.rand(2, 10);
							
							var art:DisplayObject = new artClass();
							spawnPoint.pos.toDisplayObject(art);
							
							var m:Monster = new Monster(art, spawnPoint.velocity.scale1(speed));
							gs.spawnMonster(m);
						}, callback);
					};
				}
			);
			
			var roundDone:Boolean = false;
			Async.join(spawners, function ():void {
				roundDone = true;
			});
			
			this.addChild(screen);
			Ev.on(this, Event.ENTER_FRAME, function onEnterFrame(event:Event):void {
				gs.tick();
				
				if (roundDone && gs.monsters.length === 0) {
					removeEventListener(event.type, arguments.callee);
					
					trace("So ....  there were " + monsterHist.total(goals) + " matching monsters");
					trace("Let's see what each player wrote:");
					gs.players.forEach(function (_:*, playerIndex:uint, _array:*):void {
						trace("Player " + playerIndex + ": " + playerHist.count(uint(playerIndex)));
					});
				}
			});
		}
	}
}
