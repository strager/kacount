package kacount.util {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public final class Display {
		public static function children(x:DisplayObjectContainer):Vector.<DisplayObject> {
			var v:Vector.<DisplayObject> = new <DisplayObject>[];
			for (var i:uint = 0; i < x.numChildren; ++i) {
				v.push(x.getChildAt(i));
			}
			return v;
		}
	}
}