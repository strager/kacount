package kacount.route {
	import flash.display.Graphics;
	
	import kacount.util.Num;
	import kacount.util.Vec2;

	public final class QuadBezierRoute2D implements IRoute2D {
		private var _start:Vec2;
		private var _control:Vec2;
		private var _end:Vec2;
		
		private var _weight:Number;
		
		public function QuadBezierRoute2D(start:Vec2, control:Vec2, end:Vec2) {
			this._start = start;
			this._control = control;
			this._end = end;
			
			this._weight = this.bezierLength(0, 1, 20);
		}
		
		private function bezierLength(
			startT:Number, endT:Number,
			subdivisions:uint
		):Number {
			var length:Number = 0;
			
			var lastPoint:Vec2 = this.point(startT);
			for (var i:uint = 1; i < subdivisions; ++i) {
				 var t:Number = Num.lerp(startT, endT, i / (subdivisions - 1));
				 var p:Vec2 = this.point(t);
				 
				 length += p.minus(lastPoint).length();
				 lastPoint = p;
			}
			
			return length;
		}
		
		public function point(t:Number):Vec2 {
			var ax:Number = (1 - t) * (1 - t) * this._start.x;
			var ay:Number = (1 - t) * (1 - t) * this._start.y;
			
			var bx:Number = 2 * (1 - t) * t * this._control.x;
			var by:Number = 2 * (1 - t) * t * this._control.y;
			
			var cx:Number = t * t * this._end.x;
			var cy:Number = t * t * this._end.y;
			
			return new Vec2(
				ax + bx + cx,
				ay + by + cy
			);
		}
		
		public function delta(t:Number):Vec2 {
			var ax:Number = this._control.x - this._start.x;
			var ay:Number = this._control.y - this._start.y;
			
			var bx:Number = this._end.x - this._control.x;
			var by:Number = this._end.y - this._control.y;
			
			return new Vec2(
				Num.lerp(ax, bx, t),
				Num.lerp(ay, by, t)
			);
		}
		
		public function weight():Number {
			return this._weight;
		}
		
		public function debugDraw(g:Graphics):void {
			g.moveTo(this._start.x, this._start.y);
			g.curveTo(
				this._control.x, this._control.y,
				this._end.x, this._end.y
			);
		}
	}
}