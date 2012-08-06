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
					first = false;
				} else {
					acc = fn(acc, x);
				}
			}
			
			if (first) {
				throw new Error("foldl1 must fold over at least one element");
			}
			
			return acc;
		}
		
		public static function convertCollection(ctor:*, xs:*):* {
			return mapc(xs, ctor, id);
		}
		
		public static function foldr(xs:*, z:*, fn:Function):* {
			var acc:* = z;
			var xsArray:Array = convertCollection(Array, xs);
			xsArray.reverse();
			
			for each (var x:* in xsArray) {
				acc = fn(x, acc);
			}
			
			return acc;
		}
		
		public static function filter(xs:*, fn:Function):* {
			return xs.filter(function (x:*, _i:uint, _array:*):Boolean {
				return !!fn.call(this, x);
			});
		}
		
		public static function cat(... xss:*):Array {
			return concat(xss);
		}
		
		public static function catc(ctor:*, ... xss:*):* {
			return concatc(xss, ctor);
		}
		
		public static function concat(xss:*):Array {
			return concatc(xss, Array);
		}
		
		public static function concatc(xss:*, ctor:*):* {
			var ys:* = new ctor();
			for each (var xs:* in xss) {
				for each (var x:* in xs) {
					ys.push(x);
				}
			}
			return ys;
		}
		
		/**
		 * Compare two values strictly.
		 */
		public static function eq(x:*, y:*):Boolean {
			return x === y;
		}
		
		/**
		 * Curried eq.
		 */
		public static function eq_(x:*):Function {
			return partial(eq, x);
		}
		
		public static function not(x:Boolean):Boolean {
			return !x;
		}
		
		public static function compose(... fns:Array):* {
			return function (... args:Array):* {
				var self:Object = this;
				var rets:Array = foldr(fns, args, function (fn:Function, curArgs:Array):Array {
					return [ fn.apply(self, curArgs) ];
				});
				return rets[0];
			};
		}
		
		/**
		 * Calls a function a number of times.
		 */
		public static function replicateM(n:uint, fn:Function, ... args:Array):Array {
			var xs:Array = [];
			for (var i:uint = 0; i < n; ++i) {
				xs.push(fn.apply(null, args));
			}
			return xs;
		}
		
		public static function forEach(xs:*, fn:Function):void {
			for each (var x:* in xs) {
				fn(x);
			}
		}
		
		public static function keys(x:*):Vector.<String> {
			var keys:Vector.<String> = new <String>[];
			for each (var key:String in x) {
				keys.push(key);
			}
			return keys;
		}
		
		public static function uintKeys(x:*):Vector.<uint> {
			var keys:Vector.<uint> = new <uint>[];
			for each (var key:uint in x) {
				keys.push(key);
			}
			return keys;
		}
		
		public static function zipWithc(xs:*, ys:*, ctor:*, fn:Function, ... args:Array):* {
			var zs:* = new ctor();
			for (var i:String in xs) {
				if (i in ys) {
					zs.push(fn(xs[i], ys[i]));
				}
			}
			return zs;
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
		
		private static const constructTable:Vector.<Function> = new <Function>[
			function():Object { return new this(); },
			function(a1:*):Object { return new this(a1); },
			function(a1:*, a2:*):Object { return new this(a1, a2); },
			function(a1:*, a2:*, a3:*):Object { return new this(a1, a2, a3); },
			function(a1:*, a2:*, a3:*, a4:*):Object { return new this(a1, a2, a3, a4); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*):Object { return new this(a1, a2, a3, a4, a5); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*):Object { return new this(a1, a2, a3, a4, a5, a6); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*, a7:*):Object { return new this(a1, a2, a3, a4, a5, a6, a7); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*, a7:*, a8:*):Object { return new this(a1, a2, a3, a4, a5, a6, a7, a8); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*, a7:*, a8:*, a9:*):Object { return new this(a1, a2, a3, a4, a5, a6, a7, a8, a9); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*, a7:*, a8:*, a9:*, a10:*):Object { return new this(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10); },
			function(a1:*, a2:*, a3:*, a4:*, a5:*, a6:*, a7:*, a8:*, a9:*, a10:*, a11:*):Object { return new this(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11); },
		];
		
		/**
		 * Returns a function which constructs an instance of a class.
		 */
		public static function construct(cls:Class):Function {
			return function (... args:Array):Object {
				return constructTable[args.length].apply(cls, args);
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
		
		public static function partial(fn:Function, ... args:Array):Function {
			return function (... moreArgs:Array):* {
				return fn.apply(this, cat(args, moreArgs));
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
		
		public static function ofType(xs:*, cls:Class):Array {
			return ofTypec(xs, cls, Array);
		}
		
		public static function ofTypec(xs:*, cls:Class, vectorCls:Class):* {
			var v:* = new vectorCls();
			for each (var x:* in xs) {
				if (x is cls) {
					v.push(x);
				}
			}
			return v;
		}
	}
}
