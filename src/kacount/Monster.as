package kacount {
	import flash.display.DisplayObject;
	
	import kacount.route.IRoute;

	public final class Monster {
		private var _art:DisplayObject;
		private var _route:IRoute;
		
		private var curT:Number = 0;

		public function Monster(art:DisplayObject, route:IRoute) {
			this._art = art;
			this._route = route;
			this.update();
		}

		public function get art():DisplayObject { return _art; }
		
		public function get routeDone():Boolean {
			return this.curT >= 1;
		}

		public function tick():void {
			this.curT = Math.min(0.01 + this.curT, 1);
			this.update();
		}
		
		private function update():void {
			this.updateTo(this.curT);
		}
		
		private function updateTo(t:Number):void {
			this._route.point(t).toDisplayObject(this.art);
			this.art.rotation = this._route.delta(t).toDegrees();
		}
	}
}
