package zf.h2d.col;

#if !macro @:build(zf.macros.ObjectPool.build()) #end
class Bounds extends h2d.col.Bounds implements Disposable {
	public function reset() {
		this.empty();
	}
}
