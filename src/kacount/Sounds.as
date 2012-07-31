package kacount {
	import flash.events.Event;
	import flash.media.Sound;
	
	import kacount.sound.Bloop;
	import kacount.util.Ev;

	public final class Sounds {
		public static var bloop:Sound;
		
		public static function load(callback:Function):void {
			bloop = new Bloop();
			callback();
		}
	}
}
