package zf.echo;

#if echo
import echo.data.Data.CollisionData;

class BodyExtensions {
	public static function getCollisionData(body1: echo.Body, body2: echo.Body = null, shape2: echo.Shape = null,
			shapes2: Array<echo.Shape> = null): CollisionData {
		if (body2 != null) {
			for (s1 in body1.shapes) {
				for (s2 in body2.shapes) {
					final c = s1.collides(s2);
					if (c != null) return c;
				}
			}
		}

		if (shape2 != null) {
			for (s1 in body1.shapes) {
				final c = s1.collides(shape2);
				if (c != null) return c;
			}
		}

		if (shapes2 != null) {
			for (s1 in body1.shapes) {
				for (s2 in shapes2) {
					final c = s1.collides(s2);
					if (c != null) return c;
				}
			}
		}

		return null;
	}
}
#else
class BodyExtensions {}
#end
