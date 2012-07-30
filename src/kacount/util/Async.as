package kacount.util {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Async {
		public static function join(fns:*, callback:Function):void {
			fns = fns.slice();

			var doneCount:uint = 0;
			var params:Array = [];

			function checkDone():void {
				if(doneCount === fns.length) {
					callback.apply(null, params);
				}
			}

			function makeCallback(idx:uint):Function {
				return function(... args:Array):void {
					args.forEach(function (x:*, i:uint, _array:Array):void {
						if (!params[i]) {
							params[i] = [];
						}

						params[i][idx] = x;
					});

					++doneCount;
					checkDone();
				};
			}

			fns.forEach(function(fn:Function, idx:uint, _array:*):void {
				var callback:Function = makeCallback(idx);
				fn(callback);
			});
		}

		public static function joinError(fns:*, callback:Function):void {
			fns = fns.slice();

			var doneCount:uint = 0;
			var errorCalled:Boolean = false;

			function checkDone():void {
				if(doneCount === fns.length) {
					callback(null);
				}
			}

			function makeCallback(idx:uint):Function {
				return function(err:Error):void {
					if(err === null) {
						// Success!
						++doneCount;
						checkDone();
					} else {
						// Error!
						if(!errorCalled) {
							errorCalled = true;
							callback(err);
						}
					}
				};
			}

			fns.forEach(function(fn:Function, idx:uint, _array:*):void {
				var callback:Function = makeCallback(idx);
				fn(callback);
			});
		}
		
		public static function timeout(ms:uint, callback:Function):Cancel {
			var timer:uint = setTimeout(callback, ms);
			return new Cancel(F.partial(clearTimeout, timer));
		}
	}
}
