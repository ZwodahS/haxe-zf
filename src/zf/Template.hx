package zf;

interface Template<T> {
    public function make(r: hxd.Rand): T;
}
