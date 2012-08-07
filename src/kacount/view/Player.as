package kacount.view {
	import flash.display.MovieClip;
	
	import kacount.util.Human;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;

	public final class Player {
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'click',   from: 'click_to_play', to: 'ready' },
			{ name: 'start',   from: 'click_to_play', to: 'playing' },  // FIXME should be to CPU
			{ name: 'start',   from: 'ready',         to: 'playing' },
			{ name: 'results', from: 'playing',       to: 'results' },
		]);
		
		private var _art:MovieClip;
		private var _sm:StateMachine = template.create('click_to_play', this);
		
		public function Player(art:MovieClip) {
			this._art = art;
		}
		
		public function setCount(count:uint):void {
			this._art.bugCountContainer.bugCount.text = Human.quantity(count);
		}
		
		public function get art():MovieClip { return this._art; }
		
		public function click():void {
			if (this._sm.currentState === 'playing') {
				this._art.gotoAndPlay('click');
			} else {
				this._sm.click();
			}
		}
		
		public function start():void { this._sm.start(); }
		public function results():void { this._sm.results(); }
		
		public function enter_click_to_play():void { this._art.gotoAndPlay('click_to_play'); }
		public function enter_ready():void { this._art.gotoAndPlay('ready'); }
		public function enter_playing():void { this._art.gotoAndPlay('play'); }
		public function enter_results():void { this._art.gotoAndPlay('results'); }
	}
}