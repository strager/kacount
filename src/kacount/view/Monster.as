package kacount.view {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import kacount.MonsterTemplate;
	import kacount.art.*;
	import kacount.route.IRoute1D;
	import kacount.route.IRoute2D;
	import kacount.util.Display;
	import kacount.util.debug.assert;

	public final class Monster {
		private var _art:DisplayObject;
		private var _positionRoute:IRoute2D;
		private var _speedRoute:IRoute1D;
		
		private var _duration:uint;
		private var _curTick:uint = 0;
		
		public function Monster(art:DisplayObject, duration:uint, positionRoute:IRoute2D, speedRoute:IRoute1D) {
			this._art = art;
			this._positionRoute = positionRoute;
			this._speedRoute = speedRoute;
			this._duration = duration;
			this.update();
		}

		public function get speedRoute():IRoute1D { return this._speedRoute; }
		public function get positionRoute():IRoute2D { return this._positionRoute; }
		public function get art():DisplayObject { return _art; }
		
		public function get routeDone():Boolean {
			return this._curTick >= this._duration;
		}

		public function tick():void {
			this._curTick = Math.min(this._curTick + 1, this._duration);
			this.update();
		}
		
		private function update():void {
			this.updateTo(this._curTick / this._duration);
		}
		
		private function updateTo(t:Number):void {
			var u:Number = this._speedRoute.point(t);
			this._positionRoute.point(u).toDisplayObject(this.art);
			this.art.rotation = this._positionRoute.delta(u).toDegrees();
		}
		
		public static function getLabeledClass(monsterCls:Class):Class {
			switch (monsterCls) {
			case Monster1: return Monster1Labeled;
			case Monster2: return Monster2Labeled;
			case Monster3: return Monster3Labeled;
			default: throw new Error("Unknown monster class: " + monsterCls);
			}
		}
		
		public static function showMonsterLabels(templates:Vector.<MonsterTemplate>, original:DisplayObjectContainer):void {
			assert(templates.length === 1);  // TODO lax assertion
			var labeledMonsterCls:Class = getLabeledClass(templates[0].artClass);
			var monsterContainer:DisplayObjectContainer = DisplayObjectContainer(original.getChildByName('bug'));
			monsterContainer.removeChildren();
			monsterContainer.addChild(new labeledMonsterCls());
		}
	}
}
