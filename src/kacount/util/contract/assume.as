package kacount.util.contract {
	public function assume(cond:Boolean):void {
		if (!cond) {
			throw new Error("Failed assumption");
		}
	}
}