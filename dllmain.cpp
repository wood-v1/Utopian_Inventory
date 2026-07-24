#include "framework.h"

#include "bootstrap.h"

BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID)
{
    if (reason == DLL_PROCESS_ATTACH) {
        ::DisableThreadLibraryCalls(module);
        const HANDLE thread = ::CreateThread(nullptr, 0, MainThread, module, 0, nullptr);
        if (thread) {
            ::CloseHandle(thread);
        }
    }
    return TRUE;
}
