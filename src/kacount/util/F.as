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

		/**
		 * For each element x in xs, yields x
		 * if x is the first value equal to x in xs.
		 *
		 * In other words, removes duplicates from
		 * the given collection.
		 */
		public static function nub(xs:*):* {
			return xs.filter(function (x:*, i:uint, _array:*):Boolean {
				return xs.indexOf(x) === i;
			});
		}
		
		/**
		 * Returns a function which looks up propName in its first argument.
		 */
		public static function lookup(propName:*):Function {
			return function (obj:Object, ... _rest:Array):* {
				return obj[propName];
			};
		}
		
		public static function multicast(fns:*):Function {
			fns = fns.slice();
			return function (... args:Array):void {
				for each (var fn:Function in fns) {
					fn.apply(this, args);
				}
			};
		}
		
		// ECMAScript-262 5th edition Function#bind
		private static var nativeBind:Function = Function.prototype['bind'];
		
		public static function bind(fn:Function, self:Object):Function {
			if (nativeBind === null) {
				return function (... args:Array):* {
					return fn.apply(self, args);
				}
			} else {
				return nativeBind.call(fn, self);
			}
		}
	}
}
