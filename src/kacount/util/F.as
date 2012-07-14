package kacount.util {
	public final class F {
		public static function id(x:*, ... _rest:Array):* {
			return x;
		}
		
		public static function map(xs:*, ctor:*, fn:Function):* {
			var out:* = new ctor();
			for each (var x:* in xs) {
				out.push(fn(x));
			}
			return out;
		}
	}
}