package kacount {
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
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
			{ name: 'start', from: 'none',         to: 'instructions' },
			{ name: 'play',  from: 'instructions', to: 'counting' },
			{ name: 'stop',  from: 'counting',     to: 'score' },
			{ name: 'end',   from: 'score',        to: 'end' },
		]);
		
		private var _doneCallback:Function;
		
		private var _goals:Vector.<MonsterTemplate>;
		private var _monsterHist:Histogram;
		private var _playerHist:Histogram;
		
		private var _rng:RNG = new RNG();

		private var _sm:StateMachine;
		private var _stateCancel:Cancel;
		
		private var _gameScreen:GameScreen = new GameScreen();
		
		private var _stage:Stage;
		
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
			this._sm = template.create('none', this);
			this._sm.onEnter('end', doneCallback);
		}
		
		public function start(root:DisplayObjectContainer):void {
			this._stage = root.stage;
			root.addChild(this._gameScreen.art);
			this._sm.start();
		}
		
		public function on_start():void {
			this._monsterHist = new Histogram();
			this._playerHist = new Histogram();
			
			this._goals = new <MonsterTemplate>[ this._rng.sample(monsterTemplates) ];
		}
		
		public function enter_instructions():void {
			this._gameScreen.showGoal(this._goals);
			this.addCancel(Async.timeout(4000, this._sm.play));
		}
		
		public function exit_instructions():void {
			this.runCancels();
		}
		
		public function enter_counting():void {
			var debugSprite:Sprite = this._gameScreen.debugLayer;
			var debugGraphics:Graphics = debugSprite.graphics;
			debugGraphics.lineStyle(5, 0xFF00FF, 1);
			
			this._gameScreen.startRound();
			
			function playerHit(playerIndex:uint):void {
				var players:Vector.<MovieClip> = _gameScreen.players;
				if (players.length > playerIndex) {
					_playerHist.inc(playerIndex);
					players[playerIndex].gotoAndPlay('click');
					Sounds.bloop.play();
				}
			}
			
			_gameScreen.players.forEach(function (player:MovieClip, playerIndex:uint, _array:*):void {
				this.addCancel(Touch.down(player, function onDown():void {
					playerHit(playerIndex);
				}));
			}, this);
			
			var playerKeys:Vector.<uint> = new <uint>[Keyboard.Q, Keyboard.P];
			this.addCancel(Ev.on(this._stage, KeyboardEvent.KEY_DOWN, function onKeyDown(event:KeyboardEvent):void {
				var playerIndex:int = playerKeys.indexOf(event.keyCode);
				if (playerIndex >= 0) {
					playerHit(playerIndex);
				}
			}));
			
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
			var playerCounts:Vector.<uint> = F.mapc(
				F.uintKeys(this._gameScreen.players), Vector.<uint>,
				this._playerHist.count
			);
			
			var goalCount:uint = this._monsterHist.total(this._goals);
			
			this._gameScreen.endRound(goalCount, playerCounts);
			
			this.addCancel(Async.timeout(3000, this._sm.end));
		}
		
		public function exit_score():void {
			this.runCancels();
		}
	}
}
