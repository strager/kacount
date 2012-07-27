package kacount.util {
	public final class StateTransition {
		private var _name:String;
		private var _from:String;
		private var _to:String;
		
		public function StateTransition(name:String, from:String, to:String) {
			this._name = name;
			this._from = from;
			this._to = to;
		}
		
		public function get name():String { return _name; }
		public function get from():String { return _from; }
		public function get to():String { return _to; }
		
		public static function fromJSON(x:Object):StateTransition {
			return new StateTransition(
				x.name,
				x.from,
				x.to
			);
		}
	}
}
