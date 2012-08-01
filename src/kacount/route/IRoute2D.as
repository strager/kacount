package kacount.route {
	import flash.display.Graphics;
	
	import kacount.util.Vec2;

	public interface IRoute2D {
		function point(t:Number):Vec2;
		function delta(t:Number):Vec2;
		function weight():Number;
		
		function debugDraw(g:Graphics):void;
	}
}
