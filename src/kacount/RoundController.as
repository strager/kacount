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
	import kacount.sound.Bloop;
	import kacount.util.Async;
	import kacount.util.Cancel;
	import kacount.util.Display;
	import kacount.util.Ev;
	import kacount.util.F;
	import kacount.util.Histogram;
	import kacount.util.Human;
	import kacount.util.RNG;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.Touch;
	import kacount.util.debug.assert;
	import kacount.util.debug.isDebug;

	public final class RoundController extends Controller {
		private static var monsterClasses:Array = [ Monster1, Monster2, Monster3 ];
		
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'start', from: 'none',         to: 'instructions' },
			{ name: 'play',  from: 'instructions', to: 'counting' },
			{ name: 'stop',  from: 'counting',     to: 'score' },
			{ name: 'end',   from: 'score',        to: 'end' },
		]);
		
		private var _doneCallback:Function;
		
		private var _goals:Vector.<Class>;
		private var _monsterHist:Histogram;
		private var _playerHist:Histogram;
		
		private var _root:DisplayObjectContainer;
		private var _rng:RNG = new RNG();

		private var _sm:StateMachine;
		private var _stateCancel:Cancel;
		
		private function addCancel(... cancels:Array):void {
			var notNull:Function = F.compose(F.not, F.eq_(null));
			var newCancels:Array = F.filter(
				F.cat(cancels, [ this._stateCancel ]),
				notNull
			);
			this._stateCancel = Cancel.join(newCancels);
		}
		
		private function runCancels():void {
			var c:Cancel = this._stateCancel;
			if (c !== null) {
				this._stateCancel = null;
				c.cancel();
			}
		}
		
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
			showMonsterLabels(this._goals, goalScreen);
			
			this.addCancel(Display.add(this._root, goalScreen));
			this.addCancel(Async.timeout(4000, this._sm.play)); 
		}
		
		public function exit_instructions():void {
			this.runCancels();
		}
		
		public function enter_counting():void {
			var debugSprite:Sprite = new Sprite();
			var debugGraphics:Graphics = debugSprite.graphics;
			debugGraphics.lineStyle(5, 0xFF00FF, 1);
			
			this.addCancel(Display.add(this._root, debugSprite));
			
			var art:DisplayObjectContainer = new Screen();
			var gs:GameScreen = new GameScreen(art);
			
			this.addCancel(Display.add(this._root, art));
			
			function playerHit(playerIndex:uint):void {
				_playerHist.inc(playerIndex);
				gs.players[playerIndex].gotoAndPlay('click');
				new Bloop().play();
			}
			
			gs.players.forEach(function (player:MovieClip, playerIndex:uint, _array:*):void {
				this.addCancel(Touch.down(player, function onDown():void {
					playerHit(playerIndex);
				}));
			}, this);
			
			var playerKeys:Vector.<uint> = new <uint>[Keyboard.Q, Keyboard.P];
			this.addCancel(Ev.on(this._root.stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
				var playerIndex:int = playerKeys.indexOf(event.keyCode);
				if (playerIndex >= 0) {
					playerHit(playerIndex);
				}
			}));

			var delay:Number = this._rng.double(0, 2000);
			var interval:Number = this._rng.double(700, 1400);
			var count:uint = this._rng.double(8, 20);
			
			var roundDone:Boolean = false;
			
			MonsterSpawn.tick(delay, interval, count, function ():void {
				var artClass:Class = _rng.sample(monsterClasses);
				_monsterHist.inc(artClass);
				
				var startRegion:Rectangle = _rng.sample(gs.spawnRegions);
				var endRegion:Rectangle = _rng.sample(gs.despawnRegions);
				var walkRegion:Rectangle = gs.walkRegion;
				
				var art:DisplayObject = new artClass();
				var route:IRoute = _rng.sample(RouteGenerators.generators)(
					startRegion, endRegion,
					walkRegion, _rng
				);
				
				if (isDebug) {
					route.debugDraw(debugGraphics);
				}
				
				var m:Monster = new Monster(art, route);
				gs.spawnMonster(m);
			}, function ():void {
				roundDone = true;
			});
			
			this.addCancel(this.onTick(function ():void {
				gs.tick();
				
				if (roundDone && gs.monsters.length === 0) {
					_sm.stop();
				}
			}));
		}
		
		public function exit_counting():void {
			this.runCancels();
		}
		
		public function enter_score():void {
			var resultsScreen:ResultsScreen = new ResultsScreen();
			resultsScreen.count.text = Human.quantity(this._monsterHist.total(this._goals));
			showMonsterLabels(this._goals, resultsScreen);
			
			this.addCancel(Display.add(this._root, resultsScreen));
			
			resultsScreen.player1Count.text = Human.quantity(this._playerHist.count(0));
			resultsScreen.player2Count.text = Human.quantity(this._playerHist.count(1));
			
			this.addCancel(Async.timeout(3000, this._sm.end));
		}
		
		public function exit_score():void {
			this.runCancels();
		}
		
		private static function showMonsterLabels(monsterClss:Vector.<Class>, original:DisplayObjectContainer):void {
			assert(monsterClss.length === 1);  // TODO lax assertion
			var labeledMonsterCls:Class = Monster.getLabeledClass(monsterClss[0]);
			Display.replace(original.getChildByName('bug'), new labeledMonsterCls());
		}
	}
}
