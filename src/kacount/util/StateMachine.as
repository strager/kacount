package kacount.util {
	public dynamic class StateMachine {
		private var _state:String;
		private var _template:StateMachineTemplate;
		
		private var _on:Object = { };     // String => [Function]
		private var _enter:Object = { };  // String => [Function]
		private var _exit:Object = { };   // String => [Function]
		
		public function StateMachine(initialState:String, template:StateMachineTemplate) {
			this._state = initialState;
			this._template = template;
			
			for each (var n:String in template.getTransitionNames()) {
				this[n] = mkTransitioner(n);
			}
		}
		
		private function mkTransitioner(transitionName:String):Function {
			var self:StateMachine = this;
			return function ():void {
				self.transition(transitionName);
			};
		}
		
		public function transition(transitionName:String, ... args:Array):void {
			if (!this._template.isTransition(transitionName)) {
				throw new Error("Invalid transition: " + transitionName);
			}
			
			var ts:Vector.<StateTransition> = this._template.findTransitions(this._state, transitionName);
			if (ts.length === 1) {
				var t:StateTransition = ts[0];
				this.callExit(t.from, args);
				this.callOn(t.name, args);
				this.callEnter(t.to, args);
				this._state = t.to;
			} else if (ts.length === 0) {
				throw new Error(
					"Cannot transition '" + transitionName + "'"
					+ " with no possible destinations"
					+ " from '" + this._state + "'"
				);
			} else {
				var destinations:Vector.<String> = F.mapc(
					ts, Vector.<String>,
					function (x:StateTransition):String {
						return x.to;
					}
				);
				throw new Error(
					"Cannot transition '" + transitionName + "'"
					+ " with multiple possible destinations"
					+ " from '" + this._state + "'"
					+ ": " + destinations.join(", ")
				);
			}
		}
		
		private function callEnter(from:String, args:Array):void {
			call(this._enter, from, args);
		}
		
		private function callOn(from:String, args:Array):void {
			call(this._on, from, args);
		}
		
		private function callExit(from:String, args:Array):void {
			call(this._exit, from, args);
		}
		
		public function on(transitionName:String, callback:Function, self:Object = null):void {
			addCallback(this._on, transitionName, callback, self);
		}
		
		public function onEnter(stateName:String, callback:Function, self:Object = null):void {
			addCallback(this._enter, stateName, callback, self);
		}
		
		public function onExit(stateName:String, callback:Function, self:Object = null):void {
			addCallback(this._exit, stateName, callback, self);
		}
		
		private static function addCallback(object:Object, name:String, callback:Function, self:Object):void {
			var value:Function = callback;
			if (self !== null) {
				// Only bind if not null for nicer stack traces.
				value = F.bind(value, self);
			}
			
			object[name] ||= new <Function>[];
			object[name].push(value);
		}
		
		private static function call(object:Object, name:String, args:Array):void {
			if (object !== null && name in object) {
				for each (var callback:Function in object[name]) {
					callback.apply(null, args);
				}
			}
		}
	}
}