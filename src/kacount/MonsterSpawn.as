package kacount {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	import org.osmf.events.TimeEvent;

	public final class MonsterSpawn {
		public static function spawn(
			delay:Number,
			interval:Number,
			count:uint,
			spawnPoint:SpawnPoint,
			speed:Number,
			artClass:Class,
			gameScreen:GameScreen
		):void {

		}

		public static function tick(
			delay:Number,
			interval:Number,
			count:uint,
			callback:Function,
			doneCallback:Function = null
		):void {
			setTimeout(function ():void {
				var timer:Timer = new Timer(interval, count);
				timer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void {
					callback && callback();
				});
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (event:TimerEvent):void {
					doneCallback && doneCallback();
				});
				timer.start();
			}, delay);
		}
	}
}
