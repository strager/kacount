package kacount.view {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import kacount.MonsterTemplate;
	import kacount.art.*;
	import kacount.util.Display;
	import kacount.util.F;
	import kacount.util.Human;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;
	import kacount.util.debug.assert;

	public final class GameScreen {
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'init',        from: 'none',         to: 'ready_screen' },
			{ name: 'show_goal',   from: 'ready_screen', to: 'goal_screen' },
			{ name: 'start_round', from: 'goal_screen',  to: 'game_screen' },
			{ name: 'end_round',   from: 'game_screen',  to: 'results_screen' },
		]);
		
		private var _art:Screen = new Screen();
		private var _players:Vector.<MovieClip>;
		
		private var _monsterLayer:DisplayObjectContainer = new Sprite();
		private var _debugLayer:Sprite = new Sprite();
		
		private var _spawnRegions:Vector.<Rectangle>;
		private var _despawnRegions:Vector.<Rectangle>;
		private var _walkRegion:Rectangle;
		
		private var _sm:StateMachine;

		public function GameScreen() {
			var spawns:Array = getOfType(this._art, SpawnRegion);
			var despawns:Array = getOfType(this._art, DespawnRegion);
			var walk:DisplayObject = this._art.walkRegion;
			
			this._spawnRegions = getBounds(this._art, spawns);
			this._despawnRegions = getBounds(this._art, despawns);
			this._walkRegion = walk.getBounds(this._art);
			
			F.forEach(spawns, this._art.removeChild);
			F.forEach(despawns, this._art.removeChild);
			this._art.removeChild(walk);
			
			this._players = F.mapc(
				getNumbered(this._art, 'player'), Vector.<MovieClip>,
				F.id
			);

			this._art.addChild(this._monsterLayer);  // Hack
			this._art.addChild(this._debugLayer);
			
			this._sm = template.create('none', this);
			this._sm.init();
		}
		
		public function showGoal(templates:Vector.<MonsterTemplate>):void {
			this._sm.show_goal();
			Monster.showMonsterLabels(templates, this._art);
			F.forEach(this._players, F.partial(Monster.showMonsterLabels, templates));
		}
		
		public function startRound():void {
			this._sm.start_round();
		}
		
		public function endRound(goalTotal:uint, playerTotals:Vector.<uint>):void {
			assert(playerTotals.length === this._players.length);
			
			this._art.bugCountContainer.bugCount.text = Human.quantity(goalTotal);
			
			this._players.forEach(function (player:MovieClip, i:uint, _array:*):void {
				player.bugCountContainer.bugCount.text = Human.quantity(playerTotals[i]);
			});
			
			this._sm.end_round();
		}
		
		public function enter_ready_screen():void {
			this._art.gotoAndPlay('ready_screen');
		}
		
		public function exit_ready_screen():void {
			// TODO ready vs CPU state
			this._players.forEach(F.invoke('gotoAndPlay', 'ready'));
		}
		
		public function enter_goal_screen():void {
			this._art.gotoAndPlay('goal_screen');
		}
		
		public function enter_game_screen():void {
			this._players.forEach(F.invoke('gotoAndPlay', 'play'));
			this._art.gotoAndPlay('game_screen');
		}
		
		public function enter_results_screen():void {
			this._players.forEach(F.invoke('gotoAndPlay', 'results'));
			this._art.gotoAndPlay('results_screen');
		}

		public function get players():Vector.<MovieClip> { return this._players; }
		public function get spawnRegions():Vector.<Rectangle> { return this._spawnRegions; }
		public function get despawnRegions():Vector.<Rectangle> { return this._despawnRegions; }
		public function get numPlayers():uint { return this._players.length; }
		public function get walkRegion():Rectangle { return this._walkRegion; }
		public function get debugLayer():Sprite { return this._debugLayer; }
		public function get art():Screen { return this._art; }

		public function spawnMonster(m:Monster):void {
			if (this._sm.currentState !== 'game_screen') {
				throw new Error("Cannot spawn monster when not in state 'game_screen'");
			}
			
			this._monsterLayer.addChild(m.art);
		}

		public function despawnMonster(m:Monster):void {
			if (this._sm.currentState !== 'game_screen') {
				throw new Error("Cannot despawn monster when not in state 'game_screen'");
			}
			
			this._monsterLayer.removeChild(m.art);
		}

		private static function getNumbered(art:DisplayObjectContainer, prefix:String):Vector.<DisplayObject> {
			var xs:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var i:uint = 1;
			var x:DisplayObject;
			while ((x = art.getChildByName(prefix + i))) {
				xs.push(x);
				++i;
			}

			return xs;
		}
		
		private static function getOfType(art:DisplayObjectContainer, cls:Class):Array {
			return F.ofType(Display.children(art), cls);
		}
		
		private static function getBounds(art:DisplayObjectContainer, objects:Array):Vector.<Rectangle> {
			return F.mapc(
				objects, Vector.<Rectangle>,
				F.invoke('getBounds', art)
			);
		}
	}
}
