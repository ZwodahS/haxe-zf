package zf.tests;

// The Console used here comes from console module, not h2d.Console
class TestCase {
    var testcases: Array<{name: String, func: Void->Void}>;

    public function new() {
        this.testcases = [];
    }

    public function run() {
        Console.log('------ Running ${this}');
        for (tc in this.testcases) {
            Console.log('---- Running: ${tc.name}');
            try {
                tc.func();
                Console.log('---- Done: ${tc.name}: <green>Pass</>');
            } catch (e) {
                if (e.message != 'Assertion Fail') {
                    trace(e.message);
                    trace(e.stack);
                }
                Console.log('---- Done: ${tc.name}: <red>Fail</>');
            }
            Console.log('');
        }
    }

    function add(name: String, func: Void->Void) {
        this.testcases.push({name: name, func: func});
    }

    public function assertEqual(v1: Dynamic, v2: Dynamic, ?additionalMsg: String, ?pos: haxe.PosInfos) {
        if (v1 != v2) {
            additionalMsg = additionalMsg == null ? '' : '${additionalMsg}';
            var msg = '[${pos.fileName}:${pos.lineNumber}]: ${v1} != ${v2} ${additionalMsg}';
            Console.error(msg);
            throw 'Assertion Fail';
        }
    }
}
