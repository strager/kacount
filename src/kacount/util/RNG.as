package kacount.util {
	import flash.geom.Rectangle;

	public final class RNG {
		public function double(lo:Number = 0, hi:Number = 0.9999):Number {
			// TODO
			return Num.lerp(lo, hi, Math.random());
		}
		
		public function integer(lo:int = 0, hi:int = 1):int {
			return int(double(lo, hi));
		}
		
		public function randPoint(region:Rectangle):Vec2 {
			return new Vec2(
				this.double(region.left, region.right),
				this.double(region.top, region.bottom)
			);
		}

		public function sample(xs:*):* {
			if (xs.length === 0) {
				throw new Error("Can't sample an empty collection");
			}
			return xs[uint(this.double() * xs.length)];
		}
	}
}
