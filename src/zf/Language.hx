package zf;

typedef LanguageConfig = {
	public var id: String;
	public var name: String;
}

class Language {
	public static final English: LanguageConfig = {id: "en", name: "English"};
	public static final SimplifiedChinese: LanguageConfig = {id: "zh-cn", name: "简体中文"};
	public static final Japanese: LanguageConfig = {id: "ja", name: "日本語"};
	public static final German: LanguageConfig = {id: "de", name: "Deutsch"};
	public static final Spanish: LanguageConfig = {id: "es", name: "Español"};
	public static final Korean: LanguageConfig = {id: "ko", name: "한국인"};
	public static final French: LanguageConfig = {id: "fr", name: "Français"};
	public static final Italian: LanguageConfig = {id: "it", name: "Italiano"};
}
