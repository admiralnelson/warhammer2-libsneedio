#pragma once
#include <functional>
#include <thread>
#include <string>
#include <vector>
typedef std::string Url;


struct VerifyFileProgressParams 
{
	Url Url;
	std::string Title;
};
typedef std::function<void(VerifyFileProgressParams const&)> VerifyFileProgressCallback;
struct VerifyFileCompleteParams
{
	std::string ErrorMessage;
	bool bAreFilesOk;
};
typedef std::function<void(VerifyFileCompleteParams const&)> VerifyFileCompleteCallback;

struct YtDlpDownloadProgressParams
{
	std::string Message;
	Url Url;
	std::string Title;
	int Size;
	int CurrentSize;
	int FileNo;
	int FileNoOutOf;
};
typedef std::function<void(YtDlpDownloadProgressParams const&)> YtDlpDownloadProgressCallback;

enum class YtDlpDownloadStatus 
{
	E_Fail, E_Partial, E_Completed
};
struct YtDlpDownloadCompleteParams
{
	std::string ErrorMessage;
	bool bAreDownloadsOk;
	YtDlpDownloadStatus DownloadStatus;
};
typedef std::function<void(YtDlpDownloadCompleteParams const&)> YtDlpDownloadCompleteCallback;
class SneedioYtDlp
{
public:
	static SneedioYtDlp& Get();
	SneedioYtDlp();
	bool VerifyFiles();
	bool IsDownloading();
	bool StartYtDlp(std::vector<Url> const &queues);
	std::string UrlQueuesToString(std::vector<Url> const& queues);
	std::string GetCurrentDir();
	const YtDlpDownloadProgressParams& GetDownloadStatus();
	void SetupVerifyFiles(VerifyFileProgressCallback vfProgressCallback, VerifyFileCompleteCallback vfCompleteCallback);
	void SetupYtDlp(YtDlpDownloadProgressCallback ytDlpProgressCallback, YtDlpDownloadCompleteCallback ytCompleteCallback);

private:
	void ParseYtDlpProgressFromOutput(std::string const& ytDlpStream);
	void PrintErrorFromHr(HRESULT hr);

	std::thread ThrVerifyFile;
	std::thread ThrMonitorYtDlp;

	VerifyFileCompleteCallback callbackVerifyFileComplete;
	VerifyFileProgressCallback callbackVerifyFileProgress;
	YtDlpDownloadProgressCallback callbackYtDlpDownloadProgress;
	YtDlpDownloadCompleteCallback callbackYtDlpDownloadComplete;

	VerifyFileProgressParams currentFileProgressParams;
	VerifyFileCompleteParams lastFileStatusParam;

	YtDlpDownloadProgressParams currentDownloadProgressParams;
	YtDlpDownloadCompleteParams lastDownloadStatusParam;

	HANDLE m_hChildStd_OUT_Rd = NULL;
	HANDLE m_hChildStd_OUT_Wr = NULL;

	int TotalQueuedUrls;
	int TotalProcessedUrls;

	bool bIsYtDlpRunning;
	bool bIsVerifyFileRunning;
	bool bEncounteredError;

public:
	SneedioYtDlp(SneedioYtDlp const&) = delete;
	void operator=(SneedioYtDlp const&) = delete;
	~SneedioYtDlp();
};