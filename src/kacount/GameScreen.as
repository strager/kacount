package kacount {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import kacount.art.*;
	import kacount.util.Display;
	import kacount.util.F;

	public final class GameScreen {
		private var _art:DisplayObjectContainer;
		private var _players:Vector.<MovieClip>;
		private var _monsters:Vector.<Monster>;
		
		private var _spawnRegions:Vector.<Rectangle>;
		private var _despawnRegions:Vector.<Rectangle>;
		private var _walkRegion:Rectangle;

		public function GameScreen(art:DisplayObjectContainer) {
			this._art = art;

			this._spawnRegions = getBoundsOfType(art, SpawnRegion);
			this._despawnRegions = getBoundsOfType(art, DespawnRegion);
			this._walkRegion = art.getChildByName('walkRegion').getBounds(art);

			this._players = F.mapc(
				getNumbered(art, 'player'), Vector.<MovieClip>,
				F.id
			);

			this._monsters = new Vector.<Monster>();
		}

		public function get players():Vector.<MovieClip> {
			return this._players;
		}
		
		public function get spawnRegions():Vector.<Rectangle> {
			return this._spawnRegions;
		}
		
		public function get despawnRegions():Vector.<Rectangle> {
			return this._despawnRegions;
		}

		public function get numPlayers():uint {
			return this._players.length;
		}

		public function get monsters():Vector.<Monster> {
			return this._monsters;
		}
		
		public function get walkRegion():Rectangle {
			return this._walkRegion;
		}

		public function spawnMonster(m:Monster):void {
			this._art.addChild(m.art);
			this._monsters.push(m);
		}

		public function despawnMonster(m:Monster):void {
			this._art.removeChild(m.art);
			this._monsters.splice(this._monsters.indexOf(m), 1);
		}

		public function tick():void {
			var m:Monster;
			
			for each (m in this._monsters) {
				m.tick();
			}
			
			for each (m in this._monsters.filter(F.lookup('routeDone'))) {
				this.despawnMonster(m);
			}
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
		
		private static function getBoundsOfType(art:DisplayObjectContainer, cls:Class):Vector.<Rectangle> {
			return F.mapc(
				getOfType(art, cls), Vector.<Rectangle>,
				F.invoke('getBounds', art)
			);
		}
	}
}
