package kacount {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import kacount.art.*;
	import kacount.route.IRoute;
	import kacount.route.RouteGenerators;
	import kacount.util.Ev;
	import kacount.util.Histogram;
	import kacount.util.RNG;
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
		
		private var _gs:GameScreen;
		private var _roundDone:Boolean = false;
		
		private var _doneCallback:Function;

		private var _monsterHist:Histogram = new Histogram();
		private var _playerHist:Histogram = new Histogram();

		private var _goals:Vector.<Class>;
		
		public function RoundController(root:DisplayObjectContainer, doneCallback:Function) {
			this._doneCallback = doneCallback;
			
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.lineStyle(5, 0xFF00FF, 1);
			root.addChild(s);
			
			var startRegion:Rectangle = new Rectangle(0, 0, 50, 400);
			var endRegion:Rectangle = new Rectangle(500, 0, 50, 400);
			var walkRegion:Rectangle = new Rectangle(50, 0, 400, 400);
			var rng:RNG = new RNG();
			
			var art:DisplayObjectContainer = new Screen();
			this._gs = new GameScreen(art);
			root.addChild(art);
			
			function playerHit(playerIndex:uint):void {
				_playerHist.inc(playerIndex);
				_gs.players[playerIndex].gotoAndPlay('click');
			}
			
			this._gs.players.forEach(function (player:MovieClip, playerIndex:uint, _array:*):void {
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

			_goals = new <Class>[Monster1, Monster3];
			
			var delay:Number = rng.rand(0, 2000);
			var interval:Number = rng.rand(700, 1400);
			var count:uint = rng.rand(8, 20);
			
			MonsterSpawn.tick(delay, interval, count, function ():void {
				var artClass:Class = rng.sample(monsterClasses);
				_monsterHist.inc(artClass);
				
				var art:DisplayObject = new artClass();
				var route:IRoute = rng.sample(RouteGenerators.generators)(startRegion, endRegion, walkRegion, rng);
				route.debugDraw(g);
				
				var m:Monster = new Monster(art, route);
				_gs.spawnMonster(m);
			}, function ():void {
				_roundDone = true;
			});
		}
		
		public override function tick():void {
			this._gs.tick();
			
			if (this._roundDone && this._gs.monsters.length === 0) {
				trace("So ....  there were " + _monsterHist.total(_goals) + " matching monsters");
				trace("Let's see what each player wrote:");
				this._gs.players.forEach(function (_:*, playerIndex:uint, _array:*):void {
					trace("Player " + playerIndex + ": " + _playerHist.count(uint(playerIndex)));
				});
				
				this._doneCallback();
			}

		}
	}
}