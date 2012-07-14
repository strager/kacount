package kacount {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	import kacount.util.F;
	import kacount.util.Vec2;

	public final class GameScreen {
		private var _art:DisplayObjectContainer;
		private var _spawnPoints:Vector.<SpawnPoint>;
		private var _players:Vector.<MovieClip>;
		private var _monsters:Vector.<Monster>;
		
		public function GameScreen(art:DisplayObjectContainer) {
			this._art = art;
			
			this._spawnPoints = F.map(
				getNumbered(art, 'spawn'), Vector.<SpawnPoint>,
				SpawnPoint.fromArt
			);
			
			this._players = F.map(
				getNumbered(art, 'player'), Vector.<MovieClip>,
				F.id
			);
			
			this._monsters = new Vector.<Monster>();
		}
		
		public function get spawnPoints():Vector.<SpawnPoint> {
			return this._spawnPoints.slice();
		}
		
		public function get numPlayers():uint {
			return this._players.length;
		}
		
		public function get monsters():Vector.<Monster> {
			return this._monsters.slice();
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
			this._monsters.forEach(function (m:Monster, _i:uint, _array:*):void {
				m.tick();
			});
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
	}
}