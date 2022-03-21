#include "pch.h"
#include "ytdlp_interface.h"
#include <iostream>

SneedioYtDlp& SneedioYtDlp::Get()
{
    static SneedioYtDlp instance;
    return instance;
}

SneedioYtDlp::SneedioYtDlp() : bIsVerifyFileRunning(false), bIsYtDlpRunning(false)
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

bool SneedioYtDlp::StartYtDlp(std::vector<Url> const& queues)
{
    //./yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist 'https://www.youtube.com/list=PLdYwhvDpx0FI2cmiSVn5cMufHjYHpo_88'
    //./yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output "%(title)s.%(ext)s" --yes-playlist 'https://www.youtube.com/watch?v=7iNbnineUCI' 'https://www.youtube.com/watch?v=VoOG7LEyUJ0'

    const std::string ytDlpBin = "yt-dlp/yt-dlp.exe";

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

    STARTUPINFO si;
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
        std::cout << "error :" << HRESULT_FROM_WIN32(GetLastError()) << std::endl;
        return false;
    }

    // Ensure the read handle to the pipe for STDOUT is not inherited.

    if (!SetHandleInformation(m_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0))
    {
        // log error
        std::cout << "error :" << HRESULT_FROM_WIN32(GetLastError()) << std::endl;
        return false;
    }

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.hStdError = m_hChildStd_OUT_Wr;
    si.hStdOutput = m_hChildStd_OUT_Wr;
    si.dwFlags |= STARTF_USESTDHANDLES;

    ZeroMemory(&pi, sizeof(pi));

    std::string commandLine = ytDlpBin + " --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 160K --output \"%(title)s.%(ext)s\" --yes-playlist " + UrlQueuesToString(queues);
    std::cout << "SneedioYtDlp: starting yt-dlp using following command line " << ytDlpBin << std::endl;
    // Start the child process. 
    if (!CreateProcess(NULL,           // No module name (use command line)
        (TCHAR*)commandLine.c_str(),    // Command line
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
        std::cout << "error :" << HRESULT_FROM_WIN32(GetLastError()) << std::endl;
        return false;
    }
    else
    {
        ThrMonitorYtDlp = std::thread([this]() 
        {
            const int BUFSIZE = 5;
            DWORD dwRead;
            CHAR chBuf[BUFSIZE];
            BOOL bSuccess = FALSE;
            std::string output = "";
            for (;;)
            {
                memset(chBuf, 0, sizeof(char) * BUFSIZE);
                bSuccess = ReadFile(m_hChildStd_OUT_Rd, chBuf, BUFSIZE, &dwRead, NULL);
                output += chBuf;
                if (!bSuccess || dwRead == 0) continue;

                std::cout << output << std::endl;

                if (!bSuccess) break;
            }
            return 0;
        });
    }
    return true;
}

void SneedioYtDlp::ParseYtDlpProgressFromOutput(YtDlpDownloadProgressParams& out)
{
}

std::string SneedioYtDlp::UrlQueuesToString(std::vector<Url> const& queues)
{
    std::string ret = " ";
    for (const auto& q: queues)
    {
        ret += "'" + q + "' ";
    }
    return ret;
}

SneedioYtDlp::~SneedioYtDlp()
{
    ThrMonitorYtDlp.join();
}
