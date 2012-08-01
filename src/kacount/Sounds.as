package kacount {
	import flash.media.Sound;
	
	import kacount.sound.Bloop;
	import kacount.util.Async;

	public final class Sounds {
		public static var bloop:Sound;
		
		private static function loadOne(cls:Class, callback:Function):void {
			var s:Sound = new cls();
			s.play().stop();
			callback(s);
		}
		
		private static function loadOne_(cls:Class, name:String):Function {
			return function (callback:Function):void {
				loadOne(cls, function (s:Sound):void {
					Sounds[name] = s;
					callback();
				});
			};
		}
		
		public static function load(callback:Function):void {
			Async.join(new <Function>[
				loadOne_(Bloop, 'bloop'),
			], callback);
		}
	}
}
