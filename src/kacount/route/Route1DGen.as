package kacount.route {
	import kacount.util.Num;
	import kacount.util.RNG;

	public final class Route1DGen {
		public static var generators:Vector.<Function> = new <Function>[
			linear,
			twoPauses,
		];
		
		private static function linear(rng:RNG):IRoute1D {
			return new LineRoute1D(0, 1, 4.5);
		}
		
		private static function twoPauses(rng:RNG):IRoute1D {
			var stop1X:Number = Num.square(rng.double(0, 0.6));
			var stop2X:Number = rng.double(stop1X, 1);
			
			var stop1W:Number = rng.double(0.5, 1);
			var stop2W:Number = rng.double(0.5, 1);
			
			var seg1W:Number = rng.double(0.75, 3);
			var seg2W:Number = rng.double(0.75, 3);
			var seg3W:Number = rng.double(0.75, 3);
			
			return new AggregateRoute1D(new <IRoute1D>[
				new LineRoute1D(     0, stop1X, seg1W),
				new LineRoute1D(stop1X, stop1X, stop1W),
				new LineRoute1D(stop1X, stop2X, seg2W),
				new LineRoute1D(stop2X, stop2X, stop1W),
				new LineRoute1D(stop2X,      1, seg3W),
			]);
		}
	}
}