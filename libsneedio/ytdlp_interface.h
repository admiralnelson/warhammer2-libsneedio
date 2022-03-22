#pragma once
#include <functional>
#include <thread>
#include <string>
#include <vector>
#include <map>
#include <shared_mutex>
#include <atomic>
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
enum class YtDlpDownloadProgressStatus
{
	E_Preparing = 0, E_Downloading, E_Converting
};
struct YtDlpDownloadProgressParams
{
	std::string Message;
	Url Url;
	std::string Title;
	YtDlpDownloadProgressStatus Status;
	int CurrentSize;
	int FileNo;
	int FileNoOutOf;
	int Percentage;
	int CurrentSpeedInKBpS;
	int SizeInKB;
};
typedef std::function<void(YtDlpDownloadProgressParams const&)> YtDlpDownloadProgressCallback;

enum class YtDlpDownloadStatus 
{
	E_Running = 0, E_Fail, E_Partial, E_Completed
};
struct YtDlpDownloadCompleteParams
{
	std::string ErrorMessage;
	bool bAreDownloadsOk;
	YtDlpDownloadStatus DownloadStatus;
	std::vector<Url> ErroredUrls;
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
	const YtDlpDownloadCompleteParams& GetDownloadCompleteStatus();
	void SetupVerifyFiles(VerifyFileProgressCallback vfProgressCallback, VerifyFileCompleteCallback vfCompleteCallback);
	void SetupYtDlp(YtDlpDownloadProgressCallback ytDlpProgressCallback, YtDlpDownloadCompleteCallback ytCompleteCallback);

private:
	void ParseYtDlpProgressFromOutput(std::string ytDlpStream);
	void PrintErrorFromHr(HRESULT hr);
	bool IsYtDlpRunning();

	 const std::map<std::string, int> UnitToConversionKB = {
		{"KiB", 1},
		{"MiB", 1024},
		{"GiB", 1024*1024},
		{"KiB/s", 1},
		{"MiB/s", 1024},
		{"GiB/s", 1024 * 1024}
	};

	
	std::thread ThrVerifyFile;
	std::thread ThrMonitorYtDlp;
	std::thread ThrYtDlpHeartbeat;

	std::shared_mutex write;

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
	HANDLE handleYtDlp = NULL;

	int TotalQueuedUrls;
	int TotalProcessedUrls;

	std::atomic<bool> bIsYtDlpRunning;
	bool bIsVerifyFileRunning;
	bool bEncounteredError;

public:
	SneedioYtDlp(SneedioYtDlp const&) = delete;
	void operator=(SneedioYtDlp const&) = delete;
	~SneedioYtDlp();
};