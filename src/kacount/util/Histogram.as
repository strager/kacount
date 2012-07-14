package kacount.util {
	import flash.utils.Dictionary;

	public final class Histogram {
		private var _counts:Dictionary = new Dictionary(true);
		
		public function inc(key:Object):void {
			if (key in this._counts) {
				this._counts[key] += 1;
			} else {
				this._counts[key] = 1;
			}
		}
		
		public function count(key:Object):uint {
			return this._counts[key] || 0;
		}
		
		public function counts(keys:*):Vector.<uint> {
			return F.map(keys, Vector.<uint>, this.count);
		}
		
		public function total(keys:*):uint {
			var sum:uint = 0;
			for each (var x:uint in this.counts(keys)) {
				sum += x;
			}
			return sum;
		}
	}
}
