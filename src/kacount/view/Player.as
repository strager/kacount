package kacount.view {
	import flash.display.MovieClip;
	
	import kacount.Sounds;
	import kacount.util.Human;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;

	public final class Player {
		private static var template:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'click',       from: 'unready',  to: 'ready', label: 'click_ready' },
			{ name: 'click',       from: 'ready',    to: 'unready', label: 'click_unready' },
			{ name: 'start',       from: 'unready',  to: 'disabled' },
			{ name: 'start',       from: 'ready',    to: 'playing' },
			{ name: 'click',       from: 'playing',  to: 'playing', label: 'in_game_click' },
			{ name: 'results',     from: 'playing',  to: 'results' },
			{ name: 'end_results', from: 'results',  to: 'ready', label: 'end_ready' },
			{ name: 'end_results', from: 'disabled', to: 'unready' },
		]);
		
		private var _art:MovieClip;
		private var _sm:StateMachine = template.create('unready', this);
		
		public function Player(art:MovieClip) {
			this._art = art;
		}
		
		public function setCount(count:uint):void {
			this._art.bugCountContainer.bugCount.text = Human.quantity(count);
		}
		
		public function get art():MovieClip { return this._art; }
		
		public function get isReady():Boolean {
			return this._sm.currentState === 'ready';
		}
		
		public function click():void {
			if (this._sm.canTransition('click')) {
				this._sm.click();
				Sounds.bloop.play();
			}
		}
		
		public function results():void {
			if (this._sm.canTransition('results')) {
				this._sm.results();
			}
		}
		
		public function endResults():void { this._sm.end_results(); }
		public function start():void { this._sm.start(); }
		
		public function when_click_unready():void { this._art.gotoAndPlay('unready'); }
		public function when_click_ready():void { this._art.gotoAndPlay('ready'); }
		public function when_in_game_click():void { this._art.gotoAndPlay('click'); }
		public function when_end_ready():void { this._art.gotoAndPlay('close_results'); }
		
		public function enter_click_to_play():void { this._art.gotoAndPlay('click_to_play'); }
		public function enter_playing():void { this._art.gotoAndPlay('play'); }
		public function enter_results():void { this._art.gotoAndPlay('results'); }
		public function exit_disabled():void { this._art.gotoAndPlay('enable'); }
		public function enter_disabled():void { this._art.gotoAndPlay('disable'); }
	}
}
