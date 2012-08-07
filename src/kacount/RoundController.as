package kacount {
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import kacount.art.*;
	import kacount.route.Route1DGen;
	import kacount.route.Route2DGen;
	import kacount.util.Async;
	import kacount.util.Cancel;
	import kacount.util.Countdown;
	import kacount.util.Ev;
	import kacount.util.F;
	import kacount.util.Histogram;
	import kacount.util.RNG;
	import kacount.util.Radioactive;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.Touch;
	import kacount.util.debug.isDebug;
	import kacount.view.GameScreen;
	import kacount.view.Monster;
	import kacount.view.Player;

	public final class RoundController extends Controller {
		private static var monsterTemplates:Vector.<MonsterTemplate> = F.mapc([
			{
				name: "Bug2",
				artClass: Monster1,
				positionGens: [ Route2DGen.linear, Route2DGen.manyLinear ],
				speedGens: [ Route1DGen.linear ]
			}, {
				name: "Horse Fly",
				artClass: Monster2,
				positionGens: [ Route2DGen.manyLinear ],
				speedGens: [ Route1DGen.mkPauses(2), Route1DGen.mkPauses(3) ]
			}, {
				name: "Luna Moth",
				artClass: Monster3,
				positionGens: [ Route2DGen.manyQuadBezier ],
				speedGens: [ Route1DGen.linear ]
			},
		], Vector.<MonsterTemplate>, MonsterTemplate.fromObject);
		
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'start',   from: 'none',       to: 'waiting' },
			{ name: 'ready',   from: 'waiting',    to: 'countdown' },
			{ name: 'unready', from: 'countdown',  to: 'waiting' },
			{ name: 'play',    from: 'countdown',  to: 'counting' },
			{ name: 'stop',    from: 'counting',   to: 'score' },
			{ name: 'end',     from: 'score',      to: 'end' },
		]);
		
		private var _doneCallback:Function;
		
		private var _goals:Vector.<MonsterTemplate>;
		private var _monsterHist:Histogram;
		private var _playerHist:Histogram;
		
		private var _rng:RNG = new RNG();

		private var _sm:StateMachine = template.create('none', this);
		private var _stateCancel:Cancel;
		private var _globalCancel:Cancel;
		
		private var _gameScreen:GameScreen = new GameScreen();
		
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
		
		public function RoundController(doneCallback:Function) {
			this._sm.onEnter('end', function ():void {
				_globalCancel.cancel();
				doneCallback();
			});
		}
		
		public function start(root:DisplayObjectContainer):void {
			root.addChild(this._gameScreen.art);
			
			function playerHit(player:Player):void {
				if (_sm.currentState === 'counting') {
					_playerHist.inc(player);
				}
				
				player.click();
			}
			
			var playerKeys:Vector.<uint> = new <uint>[Keyboard.Q, Keyboard.P];
			this._globalCancel = Ev.on(root.stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
				var playerIndex:int = playerKeys.indexOf(event.keyCode);
				if (playerIndex >= 0 && playerIndex < _gameScreen.players.length) {
					playerHit(_gameScreen.players[playerIndex]);
				}
			});
			
			F.forEach(_gameScreen.players, function (player:Player):void {
				Touch.down(player.art, function onDown():void {
					playerHit(player);
				});
			});
			
			this._sm.start();
		}
		
		public function enter_waiting():void {
			this.addCancel(this.onTick(function ():void {
				if (_gameScreen.hasReadyPlayer()) {
					_sm.ready();
				}
			}));
		}
		
		public function exit_waiting():void {
			this.runCancels();
		}
		
		public function enter_countdown():void {
			this._monsterHist = new Histogram();
			this._playerHist = new Histogram();
			
			this._goals = new <MonsterTemplate>[ this._rng.sample(monsterTemplates) ];
			
			this._gameScreen.showGoal(this._goals);
			this.addCancel(Async.timeout(4000, this._sm.play));
			
			this.addCancel(this.onTick(function ():void {
				if (!_gameScreen.hasReadyPlayer()) {
					_gameScreen.hideGoal();
					_sm.unready();
				}
			}));
		}
		
		public function exit_countdown():void {
			this.runCancels();
		}
		
		public function enter_counting():void {
			var debugSprite:Sprite = this._gameScreen.debugLayer;
			var debugGraphics:Graphics = debugSprite.graphics;
			debugGraphics.lineStyle(5, 0xFF00FF, 1);
			
			this._gameScreen.startRound();
			
			var monsters:Vector.<Monster> = new <Monster>[];
			
			function spawnMonster():void {
				var startRegion:Rectangle = _rng.sample(_gameScreen.spawnRegions);
				var endRegion:Rectangle = _rng.sample(_gameScreen.despawnRegions);
				var walkRegion:Rectangle = _gameScreen.walkRegion;
				
				var monsterTemplate:MonsterTemplate = _rng.sample(monsterTemplates);
				_monsterHist.inc(monsterTemplate);
				var m:Monster = monsterTemplate.makeMonster(
					startRegion, endRegion,
					walkRegion, _rng
				);
				
				if (isDebug) {
					m.positionRoute.debugDraw(debugGraphics);
				}
				
				_gameScreen.spawnMonster(m);
				monsters.push(m);
			}
			
			function despawnMonster(m:Monster, ... _rest:Array):void {
				_gameScreen.despawnMonster(m);
				
				var index:int = monsters.indexOf(m);
				if (index < 0) {
					throw new Error("Monster was not spawned or has already despawned");
				}
				monsters.splice(index, 1);
			}
			
			var spawner:Radioactive = new Radioactive(this._rng, 1 / 20, spawnMonster);
			
			var spawnMonsters:Boolean = true;
			
			var spawnFrameCount:uint = this._rng.integer(15, 20) * 20;
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
			var goalCount:uint = this._monsterHist.total(this._goals);
			this._gameScreen.endRound(goalCount, this._playerHist.count);
			
			this.addCancel(Async.timeout(3000, this._sm.end));
		}
		
		public function exit_score():void {
			this.runCancels();
		}
	}
}
