package kacount {
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import kacount.route.IRoute1D;
	import kacount.route.IRoute2D;
	import kacount.util.RNG;
	import kacount.util.debug.assert;
	import kacount.view.Monster;

	public final class MonsterTemplate {
		private var _artClass:Class;
		private var _positionGens:Vector.<Function>;
		private var _speedGens:Vector.<Function>;
		
		public function MonsterTemplate(
			artClass:Class,
			positionGens:Vector.<Function>,
			speedGens:Vector.<Function>
		) {
			this._artClass = artClass;
			this._positionGens = positionGens;
			this._speedGens = speedGens;
		}
		
		public function get artClass():Class { return this._artClass; }

		public function makeMonster(
			startRegion:Rectangle, endRegion:Rectangle,
			walkRegion:Rectangle,
			rng:RNG
		):Monster {
			var art:DisplayObject = new this._artClass();
			var positionRoute:IRoute2D = rng.sample(this._positionGens)(
				startRegion, endRegion,
				walkRegion, rng
			);
			var speedRoute:IRoute1D = rng.sample(this._speedGens)(rng);
			var duration:uint = rng.double(140, 170);
			
			return new Monster(art, duration, positionRoute, speedRoute);
		}
		
		public static function fromObject(obj:Object):MonsterTemplate {
			function lookup(key:String, cls:*):* {
				assert(key in obj, "Missing key '" + key + "' from monster template object");
				return cls(obj[key]);
			}
			
			return new MonsterTemplate(
				lookup('artClass', Class),
				lookup('positionGens', Vector.<Function>),
				lookup('speedGens', Vector.<Function>)
			);
		}
	}
}