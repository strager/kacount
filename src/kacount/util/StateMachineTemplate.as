package kacount.util {
	public final class StateMachineTemplate {
		private var _transitions:Vector.<StateTransition>;
		
		public function StateMachineTemplate(transitions:*) {
			this._transitions = F.map(transitions, Vector.<StateTransition>, StateTransition.fromJSON);
		}
		
		public function create(initialState:String, callbacks:Object):StateMachine {
			function tryCallback(prefix:String, name:String, adder:Function):void {
				var propName:String = prefix + name;
				if (propName in callbacks) {
					adder(name, callbacks[propName], callbacks);
				}
			}
			
			var sm:StateMachine = new StateMachine(initialState, this);
			
			var n:String;
			for each (n in this.getTransitionNames()) {
				tryCallback('on_', n, sm.on);
			}
			for each (n in this.getStateNames()) {
				tryCallback('enter_', n, sm.onEnter);
				tryCallback('exit_', n, sm.onExit);
			}
			
			return sm;
		}
		
		public function isTransition(n:String):Boolean {
			return this._transitions.some(function (x:StateTransition, _i:uint, _array:*):Boolean {
				return n === x.name;
			});
		}
		
		public function findTransitions(from:String, transitionName:String):Vector.<StateTransition> {
			return this._transitions.filter(function (x:StateTransition, _i:uint, _array:*):Boolean {
				return x.from === from && x.name === transitionName;
			});
		}
		
		public function getTransitionNames():Vector.<String> {
			return transitionLookup('name');
		}
		
		public function getStateNames():Vector.<String> {
			return F.nub(
				transitionLookup('from')
				.concat(transitionLookup('to'))
			);
		}
		
		private function transitionLookup(propName:String):Vector.<String> {
			return F.nub(F.map(
				this._transitions, Vector.<String>,
				F.lookup(propName)
			));
		}
	}
}
