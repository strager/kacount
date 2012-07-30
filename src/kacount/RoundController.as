package kacount {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import kacount.art.*;
	import kacount.route.IRoute;
	import kacount.route.RouteGenerators;
	import kacount.util.Display;
	import kacount.util.Ev;
	import kacount.util.Histogram;
	import kacount.util.RNG;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.Touch;
	import kacount.util.debug.isDebug;

	public final class RoundController extends Controller {
		private static var monsterClasses:Array = [ Monster1, Monster2, Monster3 ];
		
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'start', from: 'none',         to: 'instructions' },
			{ name: 'play',  from: 'instructions', to: 'counting' },
			{ name: 'stop',  from: 'counting',     to: 'score' },
			{ name: 'end',   from: 'score',        to: 'end' },
		]);
		
		private var _gs:GameScreen;
		private var _roundDone:Boolean = false;
		
		private var _doneCallback:Function;

		private var _monsterHist:Histogram;
		private var _playerHist:Histogram;

		private var _goals:Vector.<Class>;
		private var _sm:StateMachine;
		private var _root:DisplayObjectContainer;

		private var _rng:RNG = new RNG();
		
		public function RoundController(root:DisplayObjectContainer, doneCallback:Function) {
			this._sm = template.create('none', this);
			this._sm.onEnter('end', doneCallback);
			
			this._root = root;
			
			this._sm.start();
		}
		
		public function on_start():void {
			this._monsterHist = new Histogram();
			this._playerHist = new Histogram();
			
			this._goals = new <Class>[ this._rng.sample(monsterClasses) ];
		}
		
		public function enter_instructions():void {
			var goalScreen:GoalScreen = new GoalScreen();
			var labeledMonsterCls:Class = Monster.getLabeledClass(this._goals[0]);
			Display.replace(goalScreen.bug, new labeledMonsterCls());
			this._root.addChild(goalScreen);
			
			setTimeout(this._sm.play, 4000);
		}
		
		public function exit_instructions():void {
			this._root.removeChildren();
		}
		
		public function enter_counting():void {
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.lineStyle(5, 0xFF00FF, 1);
			this._root.addChild(s);
			
			var art:DisplayObjectContainer = new Screen();
			this._gs = new GameScreen(art);
			this._root.addChild(art);
			
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
			Ev.on(this._root.stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
				var playerIndex:int = playerKeys.indexOf(event.keyCode);
				if (playerIndex >= 0) {
					playerHit(playerIndex);
				}
			});

			var delay:Number = this._rng.double(0, 2000);
			var interval:Number = this._rng.double(700, 1400);
			var count:uint = this._rng.double(8, 20);
			
			MonsterSpawn.tick(delay, interval, count, function ():void {
				var artClass:Class = _rng.sample(monsterClasses);
				_monsterHist.inc(artClass);
				
				var startRegion:Rectangle = _rng.sample(_gs.spawnRegions);
				var endRegion:Rectangle = _rng.sample(_gs.despawnRegions);
				var walkRegion:Rectangle = _gs.walkRegion;
				
				var art:DisplayObject = new artClass();
				var route:IRoute = _rng.sample(RouteGenerators.generators)(
					startRegion, endRegion,
					walkRegion, _rng
				);
				
				if (isDebug) {
					route.debugDraw(g);
				}
				
				var m:Monster = new Monster(art, route);
				_gs.spawnMonster(m);
			}, function ():void {
				_roundDone = true;
			});
		}
		
		public override function tick():void {
			if (this._gs) {
				this._gs.tick();
				
				if (this._roundDone && this._gs.monsters.length === 0) {
					this._sm.stop();
				}
			}
		}
		
		public function enter_score():void {
			trace("So ....  there were " + this._monsterHist.total(_goals) + " matching monsters");
			trace("Let's see what each player wrote:");
			this._gs.players.forEach(function (_:*, playerIndex:uint, _array:*):void {
				trace("Player " + playerIndex + ": " + this._playerHist.count(uint(playerIndex)));
			}, this);
			
			this._sm.end();
		}
	}
}
