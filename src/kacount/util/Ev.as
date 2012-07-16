package kacount.util {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public final class Ev {
		public static function on(ed:EventDispatcher, eventType:String, handler:Function, useCapture:Boolean = false):Cancel {
			// We wrap `handler` so addEventListener and removeEventListener
			// don't conflict with duplicates.
			function wrapper(event:Event):void {
				handler(event);
			}
			
			ed.addEventListener(eventType, wrapper, useCapture);
			
			function cancel():void {
				ed.removeEventListener(eventType, wrapper, useCapture);
			}
			
			return new Cancel(cancel);
		}
	}
}