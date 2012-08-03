package kacount.route {
	import flash.display.Graphics;
	
	import kacount.util.Vec2;

	public final class LineRoute2D implements IRoute2D {
		private var _end:Vec2;
		private var _start:Vec2;
		
		public function LineRoute2D(start:Vec2, end:Vec2) {
			this._start = start;
			this._end = end;
		}
		
		public function point(t:Number):Vec2 {
			return Vec2.lerp(this._start, this._end, t);
		}
		
		public function delta(t:Number):Vec2 {
			return this._end.minus(this._start).normalize();
		}
		
		public function weight():Number {
			return this._start.minus(this._end).length();
		}
		
		public function debugDraw(g:Graphics):void {
			g.moveTo(this._start.x, this._start.y);
			g.lineTo(this._end.x, this._end.y);
		}
	}
}