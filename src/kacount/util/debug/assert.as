package kacount.util.debug {
	public function assert(cond:Boolean):void {
		if (!cond) {
			throw new Error("FATAL: Assertion failed");
		}
	}
}
