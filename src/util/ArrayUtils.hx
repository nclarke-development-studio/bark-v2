package util;

class ArrayUtils {
	public static function find<T>(arr:Array<T>, pred:T->Bool):T {
		for (el in arr)
			if (pred(el))
				return el;
		return null;
	}

	public static function exists<T>(arr:Array<T>, pred:T->Bool):Bool {
		for (el in arr)
			if (pred(el))
				return true;
		return false;
	}
}
