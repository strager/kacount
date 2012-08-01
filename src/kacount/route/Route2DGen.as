package kacount.route {
	import avmplus.FLASH10_FLAGS;
	
	import flash.geom.Rectangle;
	
	import kacount.util.F;
	import kacount.util.Num;
	import kacount.util.RNG;
	import kacount.util.Vec2;
	import kacount.util.debug.assume;
	import kacount.util.debug.todo;
	
	public final class Route2DGen {
		public static var generators:Vector.<Function> = new <Function>[
//			linear,
			manyLinear,
			manyQuadBezier,
		];
		
		private static function linear(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):IRoute2D {
			return new LineRoute2D(
				rng.randPoint(startRegion),
				rng.randPoint(endRegion)
			);
		}
		
		private static function manyLinear(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):IRoute2D {
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
			
			var coords:Vector.<Vec2> = zipCoords(xCoords, yCoords);
			
			return new AggregateRoute2D(Vector.<IRoute2D>(
				mapAdjacentPairs(coords, F.construct(LineRoute2D))
			));
		}
		
		private static function mapAdjacentPairs(xs:*, fn:Function):* {
			var ys:Array = [];
			for (var i:uint = 1; i < xs.length; ++i) {
				ys.push(fn(xs[i - 1], xs[i]));
			}
			return ys;
		}
		
		private static function zipCoords(xs:*, ys:*):Vector.<Vec2> {
			return F.zipWithc(
				xs, ys, Vector.<Vec2>,
				F.construct(Vec2)
			);
		}
		
		private static function manyQuadBezier(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):IRoute2D {
			var segCount:uint = rng.integer(2, 10);
			var xControlCoords:Array = F.replicateM(segCount - 1, rng.double, walkRegion.left, walkRegion.right);
			xControlCoords.sort(Num.compare);
			var yControlCoords:Array = F.replicateM(segCount - 1, rng.double, walkRegion.top, walkRegion.bottom);
			
			var controlCoords:Vector.<Vec2> = zipCoords(xControlCoords, yControlCoords);
			
			if (endRegion.left < startRegion.right) {
				todo("Handle endRegion left of startRegion");
			}
			
			var endCoords:Vector.<Vec2> = Vector.<Vec2>(
				mapAdjacentPairs(controlCoords, function (a:Vec2, b:Vec2):Vec2 {
					return Vec2.lerp(a, b, 0.5);
				})
			);
			
			endCoords.unshift(rng.randPoint(startRegion));
			endCoords.push(rng.randPoint(endRegion));
			
			var segs:Vector.<IRoute2D> = new <IRoute2D>[];
			for (var i:uint = 0; i < endCoords.length - 1; ++i) {
				segs.push(new QuadBezierRoute2D(
					endCoords[i],
					controlCoords[i],
					endCoords[i + 1]
				));
			}
			
			return new AggregateRoute2D(segs);
		}
	}
}
