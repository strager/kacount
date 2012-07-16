package kacount {
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;

	import kacount.util.Vec2;

	public final class SpawnPoint {
		private var _pos:Vec2;
		private var _velocity:Vec2;

		public function SpawnPoint(pos:Vec2, velocity:Vec2) {
			this._pos = pos;
			this._velocity = velocity;
		}

		public function get pos():Vec2 { return _pos; }
		public function get velocity():Vec2 { return _velocity; }

		public static function fromArt(art:DisplayObject):SpawnPoint {
			return new SpawnPoint(
				Vec2.fromDisplayObject(art),
				Vec2.fromDegrees(art.rotation)
			);
		}
	}
}
