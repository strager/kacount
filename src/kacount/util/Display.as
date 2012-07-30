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
		
		public static function replace(original:DisplayObject, replacement:DisplayObject):void {
			var p:DisplayObjectContainer = original.parent;
			if (!p) {
				throw new Error("original must have a parent");
			}
			
			var index:uint = p.getChildIndex(original);
			p.removeChildAt(index);
			p.addChildAt(replacement, index);
			
			replacement.transform = original.transform;
		}
		
		public static function add(parent:DisplayObjectContainer, child:DisplayObject):Cancel {
			if (child.parent) {
				throw new Error("Child already has a parent");
			}
			
			parent.addChild(child);
			
			return new Cancel(function ():void {
				if (child.parent === parent) {
					parent.removeChild(child);
				}
			});
		}
	}
}
