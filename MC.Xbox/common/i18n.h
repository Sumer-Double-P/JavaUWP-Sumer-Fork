#pragma once

#include <initializer_list>
#include <string>
#include <vector>

// marks a string for the translation files without translating it where it stands
#define TR_NOOP(text) text

namespace i18n {

struct Language {
    std::wstring code;
    std::wstring name;
};

void Init();

// English first, then every language file found, sorted by name
std::vector<Language> Languages();
std::wstring CurrentCode();
bool SetLanguage(const std::wstring& code);

// the English text is the key, so a missing translation shows the English
const wchar_t* Tr(const wchar_t* english);

// {0}, {1} and so on in the text are replaced by the arguments
std::wstring TrFormat(const wchar_t* english, std::initializer_list<std::wstring> args);

}
