package kacount.util {
	public final class Cancel {
		private var _callback:Function;
		private var _called:Boolean = false;
		
		public function Cancel(callback:Function) {
			if (callback === null) {
				throw new ArgumentError("callback should not be null");
			}
			
			this._callback = callback;
		}
		
		public function cancel():void {
			if (this._called) {
				throw new Error("cancel already called");
			}
			
			this._called = true;
			this._callback();
		}
		
		public static function join(cancels:*):Cancel {
			return new Cancel(F.multicast(F.map(
				cancels, Vector.<Function>,
				function (cancel:Cancel):Function {
					return cancel._callback;
				}
			)));
		}
	}
}