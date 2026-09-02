#pragma once

#include <atomic>

namespace inventory_overhaul
{
struct RuntimeState
{
    std::atomic<bool> inventoryOpen{ false };
    std::atomic<int> playerBranch{ -1 };
    std::atomic<int> pendingQuickslot{ 0 };
    std::atomic<bool> quickslotsReady{ false };
    std::atomic<int> quickslotsGeneration{ 0 };
};
}
