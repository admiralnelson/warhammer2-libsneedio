#pragma once
#include <functional>
#include <thread>
#include <string>
#include <vector>
typedef std::string Url;


struct VerifyFileProgressParams 
{
	Url Url;
	std::string FilePath;
};
typedef std::function<void(VerifyFileProgressParams const&)> VerifyFileProgressCallback;
struct VerifyFileCompleteParams
{
	std::string ErrorMessage;
	bool bAreFilesOk;
};
typedef std::function<void(VerifyFileCompleteParams const&)> VerifyFileCompleteCallback;

enum class YtDlpDownloadStatus 
{
	Downloading,
	Converting
};

struct YtDlpDownloadProgressParams
{
	Url Url;
	std::string FilePath;
	int Size;
	int CurrentSize;
	YtDlpDownloadStatus Status;
};
typedef std::function<void(YtDlpDownloadProgressParams const&)> YtDlpDownloadProgressCallback;
struct YtDlpDownloadCompleteParams
{
	std::string ErrorMessage;
	bool bAreDownloadsOk;
};
typedef std::function<void(YtDlpDownloadCompleteParams const&)> YtDlpDownloadCompleteCallback;
class SneedioYtDlp
{
public:
	static SneedioYtDlp& Get();
	SneedioYtDlp();
	void SetupVerifyFiles(VerifyFileProgressCallback vfProgressCallback, VerifyFileCompleteCallback vfCompleteCallback);
	void SetupYtDlp(YtDlpDownloadProgressCallback ytDlpProgressCallback, YtDlpDownloadCompleteCallback ytCompleteCallback);
	bool VerifyFiles();
	bool StartYtDlp(std::vector<Url> const &queues);
	std::string UrlQueuesToString(std::vector<Url> const& queues);

private:

	void ParseYtDlpProgressFromOutput(YtDlpDownloadProgressParams& out);

	std::thread ThrVerifyFile;
	std::thread ThrMonitorYtDlp;
	VerifyFileCompleteCallback callbackVerifyFileComplete;
	VerifyFileProgressCallback callbackVerifyFileProgress;
	YtDlpDownloadProgressCallback callbackYtDlpDownloadProgress;
	YtDlpDownloadCompleteCallback callbackYtDlpDownloadComplete;

	HANDLE m_hChildStd_OUT_Rd = NULL;
	HANDLE m_hChildStd_OUT_Wr = NULL;

	bool bIsYtDlpRunning;
	bool bIsVerifyFileRunning;


public:
	SneedioYtDlp(SneedioYtDlp const&) = delete;
	void operator=(SneedioYtDlp const&) = delete;
	~SneedioYtDlp();
};