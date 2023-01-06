package zf.userdata;

/**
	@stage:stable
**/
enum UserDataResult {
	NotSupported;
	BrowserNotEnabled;
	Failure;
	FailureReason(reason: String, message: String);
	Success;
	SuccessContent(data: Dynamic);
}
