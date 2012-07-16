package kacount.util {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;

	public final class Touch {
		public static function click(mc:DisplayObject, callback:Function):Cancel {
			function onClick(event:Event):void {
				callback();
			}

			return Cancel.join(new <Cancel>[
				Ev.on(mc, MouseEvent.CLICK, onClick),
				Ev.on(mc, TouchEvent.TOUCH_TAP, onClick),
			]);
		}

		public static function down(mc:DisplayObject, callback:Function):Cancel {
			function onDown(event:Event):void {
				callback();
			}

			return Cancel.join(new <Cancel>[
				Ev.on(mc, MouseEvent.MOUSE_DOWN, onDown),
				Ev.on(mc, TouchEvent.TOUCH_BEGIN, onDown),
			]);
		}
	}
}
