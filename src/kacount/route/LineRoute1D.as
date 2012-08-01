package kacount.route {
	import kacount.util.Num;

	public final class LineRoute1D implements IRoute1D {
		private var _start:Number;
		private var _end:Number;
		private var _weight:Number;
		
		public function LineRoute1D(start:Number, end:Number, weight:Number) {
			this._start = start;
			this._end = end;
			this._weight = weight;
		}
		
		public function point(x:Number):Number {
			return Num.lerp(this._start, this._end, x);
		}
		
		public function weight():Number {
			return this._weight;
		}
	}
}