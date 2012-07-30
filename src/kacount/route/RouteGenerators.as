package kacount.route {
	import avmplus.FLASH10_FLAGS;
	
	import flash.geom.Rectangle;

	import kacount.util.F;
	import kacount.util.Num;
	import kacount.util.RNG;
	import kacount.util.Vec2;
	import kacount.util.debug.assume;
	import kacount.util.debug.todo;
	
	public final class RouteGenerators {
		public static var generators:Vector.<Function> = new <Function>[
//			linear,
			manyLinear,
		];
		
		private static function linear(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):IRoute {
			return new LineRoute(
				rng.randPoint(startRegion),
				rng.randPoint(endRegion)
			);
		}
		
		private static function manyLinear(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):IRoute {
			var segCount:uint = rng.integer(2, 10);
			var xCoords:Array = F.replicateM(segCount - 1, rng.double, walkRegion.left, walkRegion.right);
			xCoords.sort(Num.compare);
			
			if (endRegion.left < startRegion.right) {
				todo("Handle endRegion left of startRegion");
			}
			
			xCoords.unshift(rng.double(startRegion.left, startRegion.right));
			xCoords.push(rng.double(endRegion.left, endRegion.right));
			
			assume(xCoords.length === segCount + 1);
			
			var yCoords:Array = F.replicateM(xCoords.length, rng.double, walkRegion.top, walkRegion.bottom);
			
			var coords:Vector.<Vec2> = F.zipWithc(
				xCoords, yCoords, Vector.<Vec2>,
				F.construct(Vec2)
			);
			
			var segs:Vector.<IRoute> = new <IRoute>[];
			for (var i:uint = 1; i < coords.length; ++i) {
				segs.push(new LineRoute(coords[i - 1], coords[i]));
			}
			
			return new AggregateRoute(segs);
		}
	}
}
