#include "pch.h"
#include "ytdlp_interface.h"
#include <iostream>
#include <regex>
#include "comdef.h"

SneedioYtDlp& SneedioYtDlp::Get()
{
    static SneedioYtDlp instance;
    return instance;
}

SneedioYtDlp::SneedioYtDlp() : 
    bIsVerifyFileRunning(false), 
    bIsYtDlpRunning(false), 
    TotalQueuedUrls(0),
    TotalProcessedUrls(0),
    bEncounteredError(false)
{
    
}

void SneedioYtDlp::SetupVerifyFiles(VerifyFileProgressCallback vfProgressCallback, VerifyFileCompleteCallback vfCompleteCallback)
{
    if (bIsVerifyFileRunning)
    {
        std::cout << "SneedioYtDlp: cannot setup " << __FUNCTION__ << " verify is busy " << std::endl;
        return;
    }
    callbackVerifyFileProgress = vfProgressCallback;
    callbackVerifyFileComplete = vfCompleteCallback;
}

void SneedioYtDlp::SetupYtDlp(YtDlpDownloadProgressCallback ytDlpProgressCallback, YtDlpDownloadCompleteCallback ytCompleteCallback)
{
    if (bIsYtDlpRunning) 
    {
        std::cout << "SneedioYtDlp: cannot setup " << __FUNCTION__ << " ytdlp  is busy " << std::endl;
        return;
    }
    callbackYtDlpDownloadProgress = ytDlpProgressCallback;
    callbackYtDlpDownloadComplete = ytCompleteCallback;
}

bool SneedioYtDlp::VerifyFiles()
{
    if (bIsVerifyFileRunning)
    {
        std::cout << "SneedioYtDlp: cannot start " << __FUNCTION__ << " verify is busy " << std::endl;
        return false;
    }
    if (bIsYtDlpRunning)
    {
        std::cout << "SneedioYtDlp: cannot start " << __FUNCTION__ << " ytdlp  is busy " << std::endl;
        return false;
    }
    return false;
}

bool SneedioYtDlp::IsDownloading()
{
    return bIsYtDlpRunning;
}

bool SneedioYtDlp::StartYtDlp(std::vector<Url> const& queues)
{
    //./yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist 'https://www.youtube.com/list=PLdYwhvDpx0FI2cmiSVn5cMufHjYHpo_88'
    //./yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist 'https://www.youtube.com/watch?v=7iNbnineUCI' 'https://www.youtube.com/watch?v=VoOG7LEyUJ0'
    const std::string ytDlpBin = "\"" + GetCurrentDir() + "\\yt-dlpbin\\yt-dlp.exe\"";

    if (bIsVerifyFileRunning)
    {
        std::cout << "SneedioYtDlp: cannot start " << __FUNCTION__ << " verify is busy " << std::endl;
        return false;
    }
    if (bIsYtDlpRunning)
    {
        std::cout << "SneedioYtDlp: cannot start " << __FUNCTION__ << " ytdlp  is busy " << std::endl;
        return false;
    }

    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    SECURITY_ATTRIBUTES saAttr;

    ZeroMemory(&saAttr, sizeof(saAttr));
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;

    // Create a pipe for the child process's STDOUT. 

    if (!CreatePipe(&m_hChildStd_OUT_Rd, &m_hChildStd_OUT_Wr, &saAttr, 0))
    {
        // log error
        PrintErrorFromHr(HRESULT_FROM_WIN32(GetLastError()));
        return false;
    }

    // Ensure the read handle to the pipe for STDOUT is not inherited.

    if (!SetHandleInformation(m_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0))
    {
        // log error
        PrintErrorFromHr(HRESULT_FROM_WIN32(GetLastError()));
        return false;
    }

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.hStdError = m_hChildStd_OUT_Wr;
    si.hStdOutput = m_hChildStd_OUT_Wr;
    si.dwFlags |= STARTF_USESTDHANDLES;

    ZeroMemory(&pi, sizeof(pi));

    std::string commandLine = ytDlpBin + " --newline --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output \"%(title)s.%(ext)s\" --yes-playlist " + UrlQueuesToString(queues);
    std::cout << "SneedioYtDlp: starting yt-dlp using following command line " << commandLine << std::endl;
    // Start the child process. 
    if (!CreateProcessA(NULL,           // No module name (use command line)
        (LPSTR)commandLine.c_str(),    // Command line
        NULL,                           // Process handle not inheritable
        NULL,                           // Thread handle not inheritable
        TRUE,                           // Set handle inheritance
        0,                              // No creation flags
        NULL,                           // Use parent's environment block
        NULL,                           // Use parent's starting directory 
        &si,                            // Pointer to STARTUPINFO structure
        &pi)                            // Pointer to PROCESS_INFORMATION structure
        )
    {
        PrintErrorFromHr(HRESULT_FROM_WIN32(GetLastError()));
        return false;
    }
    else
    {
        handleYtDlp = pi.hProcess;
        bIsYtDlpRunning = true;

        ThrYtDlpHeartbeat = std::thread([this]()
        {
            while(bIsYtDlpRunning)
            {
                bIsYtDlpRunning = IsYtDlpRunning();
            }
            return 0;
        });

        ThrMonitorYtDlp = std::thread([this]() 
        {
            const int BUFSIZE = 5;
            DWORD dwRead;
            CHAR chBuf[BUFSIZE];
            BOOL bSuccess = FALSE;
            std::string ytDlpOutput ="";
            while (bIsYtDlpRunning)
            {
                memset(chBuf, 0, sizeof(char) * BUFSIZE);
                bSuccess = ReadFile(m_hChildStd_OUT_Rd, chBuf, BUFSIZE, &dwRead, NULL);
                ytDlpOutput += chBuf;
                if (!bSuccess || dwRead == 0) continue;

                if (strchr(chBuf, '\n'))
                {
                    //std::cout << "yt-dlp.exe: " << ytDlpOutput;
                    ParseYtDlpProgressFromOutput(ytDlpOutput);
                    ytDlpOutput = "";
                }

                if (dwRead == 0)
                {
                    std::cout << "ThrMonitorYtDlp exited" << std::endl;
                    bIsYtDlpRunning = false;
                    if (callbackYtDlpDownloadComplete) callbackYtDlpDownloadComplete(lastDownloadStatusParam);
                    break;
                }

                if (!bSuccess)
                {
                    std::cout << __FUNCTION__": read stream error" << std::endl;
                    bIsYtDlpRunning = false;
                    if (callbackYtDlpDownloadComplete) callbackYtDlpDownloadComplete(lastDownloadStatusParam);
                    break;
                };
            }
            return 0;
        });
    }
    TotalQueuedUrls = queues.size();
    TotalProcessedUrls = 0;
    return true;
}

void SneedioYtDlp::ParseYtDlpProgressFromOutput(std::string ytDlpStream)
{
    std::lock_guard<std::shared_mutex> lock(write);
    std::cout << "yt-dlp :" << ytDlpStream << std::endl;

    std::regex regVideoId("\\[youtube\\] (.*): Downloading webpage");
    std::smatch matchVideoId;
    static std::string videoId;
    if (std::regex_search(ytDlpStream, matchVideoId, regVideoId))
    {
        currentDownloadProgressParams.Status = YtpDownloadProgressStatus::E_Preparing;
        std::cout << "match video id: " << matchVideoId[1] << std::endl;
        videoId = matchVideoId[1];
        TotalProcessedUrls++;
    }

    std::regex regVideoTitle("\\[download\\] Destination: (.*)\\.webm");
    std::smatch matchVideoTitle;
    static std::string videoTitle;
    if (std::regex_search(ytDlpStream, matchVideoTitle, regVideoTitle))
    {
        std::cout << "match video title: " << matchVideoTitle[1] << std::endl;
        videoTitle = matchVideoTitle[1];
    }

    std::regex regConvert("\\[ExtractAudio\\] Destination: (.*)\\.mp3");
    if (std::regex_search(ytDlpStream, matchVideoTitle, regConvert))
    {
        currentDownloadProgressParams.Status = YtpDownloadProgressStatus::E_Converting;
        std::cout << "match video title: " << matchVideoTitle[1] << std::endl;
        videoTitle = matchVideoTitle[1];
    }

    std::regex regProgress("(\\d+\\.\\d+)% of (\\d+.\\d+)(MiB|KiB|GiB) at  (\\d+.\\d+)(MiB\\/s|KiB\\/s|GiB\\/s)");
    std::smatch matchVideoProgress;
    static int percentage = 0;
    static int sizeInKB = 0;
    static int speedInKB = 0;
    if (std::regex_search(ytDlpStream, matchVideoProgress, regProgress))
    {
        currentDownloadProgressParams.Status = YtpDownloadProgressStatus::E_Downloading;
        percentage = (int)(atof(matchVideoProgress[1].str().c_str()));
        if (UnitToConversionKB.find(matchVideoProgress[3]) != UnitToConversionKB.end())
        {
            int sizeMultiplier = UnitToConversionKB.at(matchVideoProgress[3]);
            sizeInKB = (atof(matchVideoProgress[2].str().c_str()) * sizeMultiplier);
        }
        if (UnitToConversionKB.find(matchVideoProgress[5]) != UnitToConversionKB.end())
        {
            int sizeMultiplier = UnitToConversionKB.at(matchVideoProgress[5]);
            speedInKB = (atof(matchVideoProgress[4].str().c_str()) * sizeMultiplier);
        }
    }

    currentDownloadProgressParams.Message = ytDlpStream;
    currentDownloadProgressParams.FileNoOutOf = TotalQueuedUrls;
    currentDownloadProgressParams.FileNo = TotalProcessedUrls;
    currentDownloadProgressParams.Url = videoId;
    currentDownloadProgressParams.Title = videoTitle;
    currentDownloadProgressParams.CurrentSpeedInKBpS = speedInKB;
    currentDownloadProgressParams.SizeInKB = sizeInKB;
    currentDownloadProgressParams.Percentage = percentage;

    //todo
    //if (callbackYtDlpDownloadProgress) callbackYtDlpDownloadProgress(currentDownloadProgressParams);

    if (TotalProcessedUrls == TotalProcessedUrls && !bEncounteredError)
    {
        lastDownloadStatusParam.bAreDownloadsOk = true;
        lastDownloadStatusParam.ErrorMessage = ytDlpStream;
        lastDownloadStatusParam.DownloadStatus = YtDlpDownloadStatus::E_Completed;
        return;
    }

    if (TotalProcessedUrls == TotalProcessedUrls && bEncounteredError)
    {
        lastDownloadStatusParam.bAreDownloadsOk = true;
        lastDownloadStatusParam.ErrorMessage = ytDlpStream;
        lastDownloadStatusParam.DownloadStatus = YtDlpDownloadStatus::E_Partial;
        return;
    }

    if (TotalProcessedUrls != TotalProcessedUrls && bEncounteredError)
    {
        lastDownloadStatusParam.bAreDownloadsOk = true;
        lastDownloadStatusParam.ErrorMessage = ytDlpStream;
        lastDownloadStatusParam.DownloadStatus = YtDlpDownloadStatus::E_Fail;
        return;
    }
}

void SneedioYtDlp::PrintErrorFromHr(HRESULT hr)
{
    _com_error err(hr);
    std::cout << "error : hr code : " << hr << " " << std::endl;
}

bool SneedioYtDlp::IsYtDlpRunning()
{
    return WaitForSingleObject(handleYtDlp, 0) == WAIT_TIMEOUT;
}

std::string SneedioYtDlp::UrlQueuesToString(std::vector<Url> const& queues)
{
    std::string ret = " ";
    for (const auto& q: queues)
    {
        ret += "" + q + " ";
    }
    return ret;
}

std::string SneedioYtDlp::GetCurrentDir()
{
    char buffer[MAX_PATH] = { 0 };
    GetModuleFileNameA(NULL, buffer, MAX_PATH);
    std::string::size_type pos = std::string(buffer).find_last_of("\\/");
    return std::string(buffer).substr(0, pos);
}

const YtDlpDownloadProgressParams& SneedioYtDlp::GetDownloadStatus()
{
    std::shared_lock<std::shared_mutex> lock(write);
    return currentDownloadProgressParams;
}

SneedioYtDlp::~SneedioYtDlp()
{
    ThrMonitorYtDlp.join();
    ThrYtDlpHeartbeat.join();
}
