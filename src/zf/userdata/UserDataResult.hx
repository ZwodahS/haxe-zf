package zf.userdata;

enum UserDataResult {
	NotSupported;
	BrowserNotEnabled;
	Failure;
	FailureReason(reason: String, message: String);
	Success;
	SuccessContent(data: Dynamic);
}
