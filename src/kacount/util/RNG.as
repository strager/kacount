package kacount.util {
	public final class RNG {
		public function rand(lo:Number = 0, hi:Number = 0.9999):Number {
			// TODO
			return (Math.random() * (hi - lo)) + lo;
		}
		
		public function sample(xs:*):* {
			return xs[uint(this.rand() * xs.length)];
		}
	}
}
