package kacount {
	import flash.display.DisplayObject;

	import kacount.util.Vec2;

	public final class Monster {
		private var _art:DisplayObject;
		private var _velocity:Vec2;

		public function Monster(art:DisplayObject, velocity:Vec2) {
			this._art = art;
			this._velocity = velocity;
		}

		public function get art():DisplayObject { return _art; }

		public function tick():void {
			var cur:Vec2 = Vec2.fromDisplayObject(this._art);
			cur.plus(this._velocity).toDisplayObject(this._art);
		}
	}
}
