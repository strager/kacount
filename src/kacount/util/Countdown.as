package kacount.util {
	/**
	 * Calls a callback when decremented a certain number of times.
	 */
	public final class Countdown {
		private var _count:uint;
		private var _doneCallback:Function;
		
		public function Countdown(count:uint, doneCallback:Function) {
			this._count = count;
			this._doneCallback = doneCallback;
		}
		
		public function dec():void {
			--this._count;
			if (this._count === 0) {
				this._doneCallback.call(null);
			}
		}
	}
}