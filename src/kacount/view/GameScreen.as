package kacount.view {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import kacount.art.*;
	import kacount.util.Display;
	import kacount.util.F;

	public final class GameScreen {
		private var _art:DisplayObjectContainer;
		private var _players:Vector.<MovieClip>;
		
		private var _monsterLayer:DisplayObjectContainer;
		
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

			this._monsterLayer = new Sprite();
			this._art.addChild(this._monsterLayer);  // Hack
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
		
		public function get walkRegion():Rectangle {
			return this._walkRegion;
		}

		public function spawnMonster(m:Monster):void {
			this._monsterLayer.addChild(m.art);
		}

		public function despawnMonster(m:Monster):void {
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
		
		private static function getBoundsOfType(art:DisplayObjectContainer, cls:Class):Vector.<Rectangle> {
			return F.mapc(
				getOfType(art, cls), Vector.<Rectangle>,
				F.invoke('getBounds', art)
			);
		}
	}
}
