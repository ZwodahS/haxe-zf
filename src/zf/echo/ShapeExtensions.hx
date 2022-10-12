package zf.echo;

#if echo
import echo.data.Data.CollisionData;

class ShapeExtensions {
	public static function getCollisionData(shape1: echo.Shape, body2: echo.Body = null, shape2: echo.Shape = null,
			shapes2: Array<echo.Shape> = null): CollisionData {
		if (body2 != null) {
			for (s2 in body2.shapes) {
				final c = shape1.collides(s2);
				if (c != null) return c;
			}
		}

		if (shape2 != null) {
			final c = shape1.collides(shape2);
			if (c != null) return c;
		}

		if (shapes2 != null) {
			for (s2 in shapes2) {
				final c = shape1.collides(s2);
				if (c != null) return c;
			}
		}

		return null;
	}
}
#else
class ShapeExtensions {}
#end
