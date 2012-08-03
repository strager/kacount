package kacount.route {
	import avmplus.FLASH10_FLAGS;
	
	import kacount.util.F;
	import kacount.util.Num;
	import kacount.util.RNG;

	public final class Route1DGen {
		public static function linear(rng:RNG):IRoute1D {
			return new LineRoute1D(0, 1, 1);
		}
		
		public static function mkPauses(pauseCount:uint):Function {
			return F.partial(pauses, pauseCount);
		}
		
		private static function pauses(pauseCount:uint, rng:RNG):IRoute1D {
			const minStopDuration:Number = 0.2;
			const maxStopDuration:Number = 0.6;
			var pauses:Array = F.replicateM(
				pauseCount, rng.double,
				minStopDuration / pauseCount,
				maxStopDuration / pauseCount
			);
			
			var totalPauseW:Number = Num.sum(pauses);
			var totalPointW:Number = 1 - totalPauseW;
			
			const yCount:uint = pauseCount + 1;
			var rawPoints:Array = F.replicateM(yCount, rng.double, 0.1, 0.9);
			var rawTotal:Number = Num.sum(rawPoints);
			var ys:Array = F.map(rawPoints, F.partial(Num.mult, 1 / rawTotal));
			var xs:Array = F.map(rawPoints, F.partial(Num.mult, totalPointW / rawTotal));
			
			var routes:Vector.<IRoute1D> = new <IRoute1D>[];
			var y:Number = 0;
			for (var i:uint = 0; i < pauses.length; ++i) {
				routes.push(new LineRoute1D(y, y + ys[i], xs[i]));
				y += ys[i];
				routes.push(new LineRoute1D(y, y, pauses[i]));
			}
			routes.push(new LineRoute1D(y, 1, xs[xs.length - 1]));
			
			return new AggregateRoute1D(routes);
		}
	}
}