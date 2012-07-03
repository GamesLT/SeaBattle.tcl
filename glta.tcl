# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Copyright (C) 2003-2012 MekDrop <github@mekdrop.name>
# 
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
#  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
#  sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
#  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
#  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
#  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
#  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# This script is for finding out if Games.lt user is online
# This script is probably outdated

set is_online_url "http://www.games.lt/g/user.narso"

package require http

bind pub -|- "!isonline" pub:isonline

proc pub:isonline { nick host handle chan text } {
   global is_online_url
   set user $text
   set st ">$user</a>"
   if {[string equal -nocase $nick $user]==1} {
     putquick "NOTICE $nick :Taip að tave matau! O tu pats ne? :P"
     return
   }
   if {[string trim $user]==""} {
     putquick "NOTICE $nick :Norëdamas suþinoti ar vartotojas tikrai OnLine paraðyk prie ðios komandos nick'à þmogaus, kurio tu ieðkai."
     return
   }
   set token [http::config -useragent "Mozilla"]
   set token [http::geturl $is_online_url]
   set error 0
#   puts stderr ""
   upvar #0 $token state
#   foreach {item} [split $state(body) "\n"] {
#     putlog "=> $item"
#   }
   if {[string first [string tolower $st] [string tolower $state(body)]]>-1} {
     if {[onchan $user]>0} {
         putquick "NOTICE $nick :Ðiuo metu $user yra tiek ir tinklalapyje tiek ir IRC"
         putquick "NOTICE $nick :Ir galbût net á tave ir dëmesá atkreipë"
	 return
     } else {
         putquick "NOTICE $nick :Ðiuo metu $user yra tik tinklalapyje"
	 return
     }
   } else {
     if {[onchan $user]>0} {
         putquick "NOTICE $nick :Ðiuo metu $user yra tik IRC"
         putquick "NOTICE $nick :Ir galbût net á tave ir dëmesá atkreipë"
	 return
     } else {
         putquick "NOTICE $nick :Ðiuo metu $user yra uþ ryðio ribø"
	 return
     }
   }
#  putlog 
#  putlog [array names state]
}