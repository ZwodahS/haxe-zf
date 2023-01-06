package zf;

/**
	@stage:stable
**/
class Build {
	/**
		Taken from https://code.haxe.org/category/macros/add-git-commit-hash-in-build.html
	**/
	public static macro function getGitCommitHash(): haxe.macro.Expr.ExprOf<String> {
#if !display
		final process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
		if (process.exitCode() != 0) {
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}

		// read the output of the process
		final commitHash: String = process.stdout.readLine();

		// Generates a string expression
		return macro $v{commitHash};
#else
		// `#if display` is used for code completion. In this case returning an
		// empty string is good enough; We don't want to call git on every hint.
		final commitHash: String = "";
		return macro $v{commitHash};
#end
	}
}
