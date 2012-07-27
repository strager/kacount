package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import kacount.Controller;
	import kacount.RoundController;
	import kacount.util.Ev;
	import kacount.util.StateMachine;
	import kacount.util.StateMachineTemplate;

	[SWF(frameRate="60", width="1024", height="768")]
	public class Main extends Sprite {
		private var _sm:StateMachine;
		private var _currentController:Controller;
		
		private static var gameTemplate:StateMachineTemplate = new StateMachineTemplate([
			{ name: 'start_round', from: 'none',    to: 'playing' },
			{ name: 'next_round',  from: 'playing', to: 'playing' },
		]);
		
		public function Main() {
			this._sm = gameTemplate.create('none', this);
			
			this.init();
			this._sm.start_round();
		}

		private function init():void {
			this.stage.frameRate = 60;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Ev.on(this, Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void {
			if (this._currentController) {
				this._currentController.tick();
			}
		}
		
		public function enter_playing():void {
			this.setController(new RoundController(this, this._sm.next_round));
		}
		
		private function setController(c:Controller):void {
			this._currentController = c;
		}
	}
}
