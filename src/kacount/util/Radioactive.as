package kacount.util {
	/**
	 * Randomly calls the callback function when poked.
	 */
	public final class Radioactive {
		private var _rng:RNG;
		private var _probability:Number;
		private var _callback:Function;
		 
		public function Radioactive(rng:RNG, probability:Number, callback:Function) {
			if (probability < 0 || probability > 1) {
				throw new RangeError("probability must be between 0 and 1");
			}
			
			if (callback === null) {
				throw new ArgumentError("callback must be non-null");
			}
			
			this._rng = rng;
			this._probability = probability;
			this._callback = callback;
		}
		
		public function poke(... args:Array):void {
			if (this.roll()) {
				this._callback.apply(null, args);
			}
		}
		
		private function roll():Boolean {
			return this._rng.bool(this._probability);
		}
	}
}