package kacount.route {
	import flash.display.Graphics;
	
	import kacount.util.F;
	import kacount.util.Num;
	import kacount.util.Vec2;

	public final class AggregateRoute implements IRoute {
		private var _segments:Vector.<IRoute>;
		
		public function AggregateRoute(segments:Vector.<IRoute>) {
			if (segments.length < 1) {
				throw new Error("Route must have at least one segment");
			}
			
			this._segments = segments;
		}
		
		public function point(t:Number):Vec2 {
			var segT:SegT = this.segTAt(t);
			return segT.seg.point(segT.t);
		}
		
		public function delta(t:Number):Vec2 {
			var segT:SegT = this.segTAt(t);
			return segT.seg.delta(segT.t);
		}
		
		private function segTAt(t:Number):SegT {
			if (t <= 0) return new SegT(this._segments[0], 0);
			if (t >= 1) return new SegT(this._segments[this._segments.length - 1], 1);
			
			var totalW:Number = this.weight();
			var curW:Number = 0;
			var tW:Number = t * totalW;
			
			for each (var seg:IRoute in this._segments) {
				var nextW:Number = curW + seg.weight();
				if (nextW > tW) {
					var innerT:Number = Num.unlerp(curW, nextW, tW);
					return new SegT(seg, innerT);
				}
				curW = nextW;
			}
			
			throw new RangeError("Could not find segment at t=" + t);
		}
		
		public function weight():Number {
			return F.foldl1(F.map(this._segments, F.invoke('weight')), Num.add);
		}
		
		public function debugDraw(g:Graphics):void {
			for each (var seg:IRoute in this._segments) {
				seg.debugDraw(g);
			}
		}
	}
}

import kacount.route.IRoute;

// Awesome tuple type!
class SegT {
	public var seg:IRoute;
	public var t:Number;
	
	public function SegT(seg:IRoute, t:Number) {
		this.seg = seg;
		this.t = t;
	}
}
