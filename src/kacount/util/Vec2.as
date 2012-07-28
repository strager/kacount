package kacount.util {
	import flash.display.DisplayObject;

	public class Vec2 {
		private var _x:Number, _y:Number;

		public function Vec2(x:Number, y:Number) {
			this._x = x;
			this._y = y;
		}

		public function get x():Number { return this._x; }
		public function get y():Number { return this._y; }
		
		public function plus(a:Vec2):Vec2 {
			return new Vec2(this.x + a.x, this.y + a.y);
		}
		
		public function minus(a:Vec2):Vec2 {
			return new Vec2(this.x - a.x, this.y - a.y);
		}
		
		public function length():Number {
			return Math.sqrt(this.length2());
		}
		
		public function length2():Number {
			return this.x * this.x + this.y * this.y;
		}
		
		public function normalize():Vec2 {
			var len:Number = this.length();
			return new Vec2(this.x / len, this.y / len);
		}

		public function scale1(factor:Number):Vec2 {
			return new Vec2(this.x * factor, this.y * factor);
		}
		
		public function toDegrees():Number {
			return this.toRadians() / Math.PI * 180;
		}
		
		public function toRadians():Number {
			return Math.atan2(this.y, this.x);
		}

		public static function fromDegrees(deg:Number):Vec2 {
			return fromRadians(deg * Math.PI / 180);
		}

		public static function fromRadians(rad:Number):Vec2 {
			return new Vec2(Math.cos(rad), Math.sin(rad));
		}

		public static function fromDisplayObject(d:DisplayObject):Vec2 {
			return new Vec2(d.x, d.y);
		}
		
		public static function lerp(a:Vec2, b:Vec2, t:Number):Vec2 {
			return new Vec2(
				Num.lerp(a.x, b.x, t),
				Num.lerp(a.y, b.y, t)
			);
		}

		public function toDisplayObject(d:DisplayObject):void {
			d.x = this.x;
			d.y = this.y;
		}
	}
}
