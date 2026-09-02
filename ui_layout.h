#pragma once

namespace inventory_overhaul
{
const char* ResolveInventoryXml(int playerBranch);
const char* ResolveLootXml();
const char* ResolveCorpseXml();

bool IsInventoryWindowName(const char* xml);
bool IsPlayerInventoryWindowName(const char* xml);
bool IsCorpseWindowName(const char* xml);
bool IsContainerWindowName(const char* xml);
bool IsStorageContainerUseScript(const char* scriptName);
bool IsCenteredInventoryXml(const char* xml);
bool IsCenteredLootXml(const char* xml);
}
