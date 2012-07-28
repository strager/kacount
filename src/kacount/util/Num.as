package kacount.util {
	public final class Num {
		/**
		 * Adds the first two arguments.  Ignores the remaining arguments.
		 */
		public static function add(a:Number, b:Number, ... _rest:Array):Number {
			return a + b;
		}
		
		public static function compare(a:Number, b:Number, ... _rest:Array):int {
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		}
		
		public static function lerp(a:Number, b:Number, t:Number):Number {
			return (b - a) * t + a;
		}
		
		/**
		 * unlerp(a, b, lerp(a, b, c)) == c
		 */
		public static function unlerp(a:Number, b:Number, x:Number):Number {
			return (x - a) / (b - a);
		}
	}
}