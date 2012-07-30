package kacount {
	import flash.display.DisplayObject;
	
	import kacount.art.*;
	import kacount.route.IRoute;

	public final class Monster {
		private var _art:DisplayObject;
		private var _route:IRoute;
		
		private var _curT:Number = 0;
		private var _speed:Number;     // t per tick

		public function Monster(art:DisplayObject, route:IRoute) {
			this._art = art;
			this._route = route;
			this._speed = 10 / route.weight();
			this.update();
		}

		public function get art():DisplayObject { return _art; }
		
		public function get routeDone():Boolean {
			return this._curT >= 1;
		}

		public function tick():void {
			this._curT = Math.min(this._speed + this._curT, 1);
			this.update();
		}
		
		private function update():void {
			this.updateTo(this._curT);
		}
		
		private function updateTo(t:Number):void {
			this._route.point(t).toDisplayObject(this.art);
			this.art.rotation = this._route.delta(t).toDegrees();
		}
		
		public static function getLabeledClass(monsterCls:Class):Class {
			switch (monsterCls) {
			case Monster1: return Monster1Labeled;
			case Monster2: return Monster2Labeled;
			case Monster3: return Monster3Labeled;
			default: throw new Error("Unknown monster class: " + monsterCls);
			}
		}
	}
}
