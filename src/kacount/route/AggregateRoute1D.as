package kacount.route {
	import kacount.util.F;
	import kacount.util.Num;

	public final class AggregateRoute1D implements IRoute1D {
		private var _segments:Vector.<IRoute1D>;
		
		public function AggregateRoute1D(segments:Vector.<IRoute1D>) {
			if (segments.length < 1) {
				throw new Error("Route must have at least one segment");
			}
			
			this._segments = segments;
		}
		
		public function point(x:Number):Number {
			if (x <= 0) return this._segments[0].point(x);
			if (x >= 1) return this._segments[this._segments.length - 1].point(x);
			
			var totalW:Number = this.weight();
			var curW:Number = 0;
			var tW:Number = x * totalW;
			
			for each (var seg:IRoute1D in this._segments) {
				var nextW:Number = curW + seg.weight();
				if (nextW > tW) {
					var innerX:Number = Num.unlerp(curW, nextW, tW);
					return seg.point(innerX);
				}
				curW = nextW;
			}
			
			throw new RangeError("Could not find segment at x=" + x);
		}
		
		public function weight():Number {
			return F.foldl1(F.map(this._segments, F.invoke('weight')), Num.add);
		}
	}
}
