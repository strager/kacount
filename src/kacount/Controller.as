package kacount {
	import kacount.util.Cancel;
	import kacount.util.F;
	import kacount.util.debug.assume;

	public class Controller {
		private var _onTickHandlers:Vector.<Function> = new <Function>[];
		
		protected function onTick(callback:Function):Cancel {
			this._onTickHandlers.push(callback);
			
			return new Cancel(function ():void {
				var index:int = _onTickHandlers.indexOf(callback);
				assume(index >= 0);
				_onTickHandlers.splice(index, 1);
			});
		}
		
		public final function tick():void {
			F.multicast(this._onTickHandlers)();
		}
	}
}