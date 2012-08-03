package kacount.util.debug {
	public function assert(cond:Boolean, message:String = ""):void {
		if (!cond) {
			throw new Error("FATAL: Assertion failed" + (message ? ": " + message : ""));
		}
	}
}
