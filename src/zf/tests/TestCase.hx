package zf.tests;

using StringTools;

// The Console used here comes from console module, not h2d.Console
class TestCase {
    public function new() {}

    public function run() {
        switch (Type.typeof(this)) {
            case TClass(c):
                var className = Type.getClassName(c);
                Console.log('Running ${className}');
                for (name in Type.getInstanceFields(c)) {
                    var field = Reflect.field(this, name);
                    var success = false;
                    if (name.startsWith("test_") && Reflect.isFunction(field)) {
                        try {
                            Reflect.callMethod(this, field, []);
                            success = true;
                        } catch (e) {
                            // error not thrown by assert function
                            if (e.message != 'Assertion Fail') {
                                trace(e.message);
                                trace(e.stack);
                            }
                            success = false;
                        }
                        if (success) {
                            Console.log('---- Done: ${className}.${name}: <green>Pass</>');
                        } else {
                            Console.log('---- Done: ${className}.${name}: <red>Fail</>');
                        }
                    }
                }
            default:
        }
    }

    public function assertEqual(v1: Dynamic, v2: Dynamic, ?additionalMsg: String, ?pos: haxe.PosInfos) {
        if (v1 != v2) {
            additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
            var msg = '[${pos.fileName}:${pos.lineNumber}]: ${v1} != ${v2} ${additionalMsg}';
            Console.error(msg);
            throw 'Assertion Fail';
        }
    }

    public function assertIn(v1: Dynamic, v2: Iterable<Dynamic>, ?additionalMsg: String,
            ?pos: haxe.PosInfos) {
        var found = false;
        for (v in v2) {
            if (v1 == v) {
                found = true;
                break;
            }
        }
        if (!found) {
            additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
            var msg = '[${pos.fileName}:${pos.lineNumber}]: ${v1} not found in ${v2} ${additionalMsg}';
            Console.error(msg);
            throw 'Assertion Fail';
        }
    }
}
