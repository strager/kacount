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
	import kacount.route.IRoute1D;
	import kacount.route.IRoute2D;
	import kacount.route.Route1DGen;
	import kacount.route.Route2DGen;
	import kacount.util.Async;
	import kacount.util.Cancel;
	import kacount.util.Countdown;
	import kacount.util.Display;
	import kacount.util.Ev;
	import kacount.util.F;
	import kacount.util.Histogram;
	import kacount.util.Human;
	import kacount.util.RNG;
	import kacount.util.Radioactive;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.Touch;
	import kacount.util.debug.assert;
	import kacount.util.debug.isDebug;
	import kacount.view.GameScreen;
	import kacount.view.Monster;

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
				Sounds.bloop.play();
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
			
			var monsters:Vector.<Monster> = new <Monster>[];
			
			function spawnMonster():void {
				var artClass:Class = _rng.sample(monsterClasses);
				_monsterHist.inc(artClass);
				
				var startRegion:Rectangle = _rng.sample(gs.spawnRegions);
				var endRegion:Rectangle = _rng.sample(gs.despawnRegions);
				var walkRegion:Rectangle = gs.walkRegion;
				
				var art:DisplayObject = new artClass();
				var positionRoute:IRoute2D = _rng.sample(Route2DGen.generators)(
					startRegion, endRegion,
					walkRegion, _rng
				);
				var speedRoute:IRoute1D = _rng.sample(Route1DGen.generators)(_rng);
				var duration:uint = _rng.double(25, 30) * speedRoute.weight();
				
				if (isDebug) {
					positionRoute.debugDraw(debugGraphics);
				}
				
				var m:Monster = new Monster(art, duration, positionRoute, speedRoute);
				gs.spawnMonster(m);
				monsters.push(m);
			}
			
			function despawnMonster(m:Monster, ... _rest:Array):void {
				gs.despawnMonster(m);
				
				var index:int = monsters.indexOf(m);
				if (index < 0) {
					throw new Error("Monster was not spawned or has already despawned");
				}
				monsters.splice(index, 1);
			}
			
			var spawner:Radioactive = new Radioactive(this._rng, 1 / 20, spawnMonster);
			
			var spawnMonsters:Boolean = true;
			
			var spawnFrameCount:uint = this._rng.integer(15, 20) * 60;
			var countdown:Countdown = new Countdown(spawnFrameCount, function ():void {
				spawnMonsters = false;
				
				addCancel(onTick(function ():void {
					if (monsters.length === 0) {
						_sm.stop();
					}
				}));
			});
			
			this.addCancel(this.onTick(function ():void {
				if (spawnMonsters) {
					spawner.poke();
				}
				
				countdown.dec();

				var m:Monster;
				for each (m in monsters) {
					m.tick();
				}
				monsters.filter(F.lookup('routeDone')).forEach(despawnMonster);
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
