package kacount {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import kacount.art.*;
	import kacount.util.Async;
	import kacount.util.Cancel;
	import kacount.util.Ev;
	import kacount.util.F;
	import kacount.util.Histogram;
	import kacount.util.RNG;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.Touch;

	public final class RoundController extends Controller {
		private static var monsterClasses:Array = [ Monster1, Monster2, Monster3 ];
		
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'start', from: 'none',         to: 'instructions' },
			{ name: 'next',  from: 'instructions', to: 'counting' },
			{ name: 'stop',  from: 'counting',     to: 'score' },
			{ name: 'next',  from: 'score',        to: 'end' },
		]);
		
		public function RoundController(root:DisplayObjectContainer, doneCallback:Function) {
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
			Ev.on(root.stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
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
					var count:uint = rng.rand(4, 4);
					
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
			
			root.addChild(screen);
			var cancelEnterFrame:Cancel = Ev.on(root, Event.ENTER_FRAME, function onEnterFrame(event:Event):void {
				gs.tick();
				
				if (roundDone && gs.monsters.length === 0) {
					cancelEnterFrame.cancel();
					
					trace("So ....  there were " + monsterHist.total(goals) + " matching monsters");
					trace("Let's see what each player wrote:");
					gs.players.forEach(function (_:*, playerIndex:uint, _array:*):void {
						trace("Player " + playerIndex + ": " + playerHist.count(uint(playerIndex)));
					});
					
					root.removeChild(screen);
					doneCallback();
				}
			});
		}
	}
}