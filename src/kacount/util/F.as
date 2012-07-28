package kacount.util {
	public final class F {
		public static function id(x:*, ... _rest:Array):* {
			return x;
		}

		/**
		 * Functional map with the given output type.
		 */
		public static function mapc(xs:*, ctor:*, fn:Function):* {
			var out:* = new ctor();
			for each (var x:* in xs) {
				out.push(fn(x));
			}
			return out;
		}
		
		/**
		 * Functional map with an Array output type.
		 */
		public static function map(xs:*, fn:Function):Array {
			return mapc(xs, Array, fn);
		}

		public static function foldl1(xs:*, fn:Function):* {
			var acc:*;
			var first:Boolean = true;
			
			for each (var x:* in xs) {
				if (first) {
					acc = x;
				} else {
					acc = fn(acc, x);
				}
			}
			
			if (first) {
				throw new Error("foldl1 must fold over at least one element");
			}
			
			return acc;
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
		
		/**
		 * Returns a function which invokes a member function
		 * on its first argument.
		 */
		public static function invoke(propName:*, ... args:Array):Function {
			return function (obj:Object, ... _rest:Array):* {
				return obj[propName].apply(obj, args);
			};
		}
		
		/**
		 * Returns a function which invokes a function as its first argument.
		 */
		public static function call(... args:Array):Function {
			return function (fn:Function, ... _rest:Array):* {
				return fn.apply(null, args);
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
