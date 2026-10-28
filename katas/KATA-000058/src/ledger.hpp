// SPDX-License-Identifier: MIT
// Original implementation: monetary values remain signed integer cents.
#pragma once
#include <algorithm>
#include <cstdint>
#include <iomanip>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace ledger {
struct Entry { std::string date; std::string description; std::int64_t cents; };
enum class Locale { US, NL };
enum class Currency { USD, EUR };
inline Locale locale_of(const std::string& s) {
  if(s=="en_US") return Locale::US;
  if(s=="nl_NL") return Locale::NL;
  throw std::invalid_argument("unsupported locale");
}
inline Currency currency_of(const std::string& s) {
  if(s=="USD") return Currency::USD;
  if(s=="EUR") return Currency::EUR;
  throw std::invalid_argument("unsupported currency");
}
inline bool leap(int y) { return y%4==0 && (y%100!=0 || y%400==0); }
inline int parse_digits(const std::string& s, std::size_t at, std::size_t n) {
  int v=0;
  for(std::size_t i=at;i<at+n;i++) {
    if(i>=s.size() || s[i]<'0' || s[i]>'9') throw std::invalid_argument("invalid date digit");
    v=v*10+(s[i]-'0');
  }
  return v;
}
inline std::string date_display(const std::string& iso, Locale loc) {
  if(iso.size()!=10 || iso[4]!='-' || iso[7]!='-') throw std::invalid_argument("invalid ISO date");
  int y=parse_digits(iso,0,4), m=parse_digits(iso,5,2), d=parse_digits(iso,8,2);
  if(y<1 || m<1 || m>12) throw std::invalid_argument("invalid calendar date");
  const int lengths[]={31,28,31,30,31,30,31,31,30,31,30,31};
  int max=lengths[m-1]+(m==2 && leap(y)?1:0);
  if(d<1 || d>max) throw std::invalid_argument("invalid calendar day");
  return loc==Locale::US ? iso.substr(5,2)+"/"+iso.substr(8,2)+"/"+iso.substr(0,4)
                         : iso.substr(8,2)+"-"+iso.substr(5,2)+"-"+iso.substr(0,4);
}
inline std::string description_display(const std::string& s) {
  // Contract: printable ASCII descriptions, no embedded control/TSV characters.
  for(unsigned char c:s) if(c<32 || c>126) throw std::invalid_argument("description outside ASCII contract");
  std::string v=s.size()>25?s.substr(0,22)+"...":s;
  v.append(25-v.size(),' ');
  return v;
}
inline std::string amount_display(std::int64_t cents, Locale loc, Currency curr) {
  // Magnitude computation is safe even for INT64_MIN.
  std::uint64_t mag=cents<0 ? std::uint64_t(-(cents+1))+1 : std::uint64_t(cents);
  std::string digits=std::to_string(mag/100);
  std::string grouped;
  char sep=loc==Locale::US?',':'.';
  for(std::size_t i=0;i<digits.size();i++) {
    if(i && (digits.size()-i)%3==0) grouped+=sep;
    grouped+=digits[i];
  }
  std::string fractional=std::to_string(mag%100);
  if(fractional.size()==1) fractional.insert(0,"0");
  std::string symbol=curr==Currency::USD?"$":"€";
  std::string core;
  if(loc==Locale::US) core=cents<0?"("+symbol+grouped+"."+fractional+")":symbol+grouped+"."+fractional+" ";
  else core=symbol+" "+(cents<0?"-":"")+grouped+","+fractional+" ";
  std::size_t visible=core.size()-(curr==Currency::EUR?2:0);
  if(visible>13) throw std::out_of_range("amount exceeds 13-character ledger column");
  return std::string(13-visible,' ')+core;
}
inline std::vector<std::string> format(std::vector<Entry> entries, Locale loc, Currency curr) {
  // Validate before sorting/output to keep the operation atomic.
  for(const auto& e:entries) { (void)date_display(e.date,loc); (void)description_display(e.description); (void)amount_display(e.cents,loc,curr); }
  std::sort(entries.begin(),entries.end(),[](const Entry& a,const Entry& b) {
    if(a.date!=b.date) return a.date<b.date;
    if(a.description!=b.description) return a.description<b.description;
    return a.cents<b.cents;
  });
  std::vector<std::string> lines;
  lines.reserve(entries.size()+1);
  lines.push_back(loc==Locale::US?"Date       | Description               | Change       ":"Datum      | Omschrijving              | Verandering  ");
  for(const auto& e:entries) lines.push_back(date_display(e.date,loc)+" | "+description_display(e.description)+" | "+amount_display(e.cents,loc,curr));
  return lines;
}
}
