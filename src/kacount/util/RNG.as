package kacount.util {
	import flash.geom.Rectangle;

	public final class RNG {
		public function rand(lo:Number = 0, hi:Number = 0.9999):Number {
			// TODO
			return Num.lerp(lo, hi, Math.random());
		}
		
		public function randPoint(region:Rectangle):Vec2 {
			return new Vec2(
				this.rand(region.left, region.right),
				this.rand(region.top, region.bottom)
			);
		}

		public function sample(xs:*):* {
			return xs[uint(this.rand() * xs.length)];
		}
	}
}
