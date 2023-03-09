package zf.patchnotes;

class PatchNotes {
	public static function loadPatchNotes(): Array<PatchNote> {
		final files = hxd.Res.loader.dir("changelogs");
		final changelogs: Array<PatchNote> = [];
		for (f in files) {
			try {
				final textData = f.toText();
				final jsonData = haxe.Json.parse(textData);
				final changelog: PatchNote = jsonData;
				changelog.versionObject = Version.fromString(changelog.version);
				changelogs.push(changelog);
			} catch (e) {
				Logger.debug('Fail to load changelog: ${f}');
			}
		}

		changelogs.sort(function(c1: PatchNote, c2: PatchNote) {
			final v1 = c1.versionObject;
			final v2 = c2.versionObject;

			if (v1.major != v2.major) return v1.major < v2.major ? 1 : -1;
			if (v1.minor != v2.minor) return v1.minor < v2.minor ? 1 : -1;
			return v1.patch < v2.patch ? 1 : v1.patch > v2.patch ? -1 : 0;
		});
		return changelogs;
	}
}
