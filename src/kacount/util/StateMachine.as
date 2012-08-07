package kacount.util {
	public dynamic class StateMachine {
		private var _state:String;
		private var _template:StateMachineTemplate;
		
		private var _on:Object = { };     // String => [Function]
		private var _enter:Object = { };  // String => [Function]
		private var _exit:Object = { };   // String => [Function]
		private var _when:Object = { };   // String => [Function]
		
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
		
		public function canTransition(transitionName:String):Boolean {
			return this._template.findTransitions(this._state, transitionName).length > 0;
		}
		
		private function validTransition(name:String):Boolean {
			return this._template.isTransition(name);
		}
		
		private function validateTransition(name:String):void {
			if (!this.validTransition(name)) {
				throw new Error("Invalid transition: " + name);
			}
		}
		
		public function transition(transitionName:String, ... args:Array):void {
			this.validateTransition(transitionName);
			
			var ts:Vector.<StateTransition> = this._template.findTransitions(this._state, transitionName);
			if (ts.length === 1) {
				var t:StateTransition = ts[0];
				var override:Boolean = this.callWhen(t.label, args);
				if (override) {
					this._state = t.to;
				} else {
					this.callExit(t.from, args);
					this.callOn(t.name, args);
					this._state = t.to;
					this.callEnter(t.to, args);
				}
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
		
		private function callEnter(to:String, args:Array):Boolean {
			return call(this._enter, to, args);
		}
		
		private function callOn(name:String, args:Array):Boolean {
			return call(this._on, name, args);
		}
		
		private function callExit(from:String, args:Array):Boolean {
			return call(this._exit, from, args);
		}
		
		private function callWhen(label:String, args:Array):Boolean {
			return call(this._when, label, args);
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
		
		public function onLabel(label:String, callback:Function, self:Object = null):void {
			addCallback(this._when, label, callback, self);
		}
		
		public function get currentState():String { return this._state; }
		
		private static function addCallback(object:Object, name:String, callback:Function, self:Object):void {
			var value:Function = callback;
			if (self !== null) {
				// Only bind if not null for nicer stack traces.
				value = F.bind(value, self);
			}
			
			object[name] ||= new <Function>[];
			object[name].push(value);
		}
		
		private static function call(object:Object, name:String, args:Array):Boolean {
			var called:Boolean = false;
			if (object !== null && name in object) {
				for each (var callback:Function in object[name]) {
					called = true;
					callback.apply(null, args);
				}
			}
			return called;
		}
	}
}