package kacount.route {
	import flash.geom.Rectangle;
	
	import kacount.util.RNG;
	import kacount.util.Vec2;
	
	public final class RouteGenerators {
		public static var generators:Vector.<Function> = new <Function>[
			function linear(
				startRegion:Rectangle, endRegion:Rectangle,
				walkRegion:Rectangle,
				rng:RNG
			):IRoute {
				return new LineRoute(
					rng.randPoint(startRegion),
					rng.randPoint(endRegion)
				);
			},
		];
	}
}
