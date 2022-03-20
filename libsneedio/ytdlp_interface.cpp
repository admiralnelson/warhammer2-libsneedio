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
