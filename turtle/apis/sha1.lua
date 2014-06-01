--[[
NOTE: This is a modified version of the SHA1 routines from the StringUtils api by tomass1996
which have been revised to use the much faster java bit api now available in cc instead of 
the original native lua bitwise operations where appropriate.
No other changes made.

Original license from StringUtils api:

Copyright (C) 2012 Thomas Farr a.k.a tomass1996 [farr.thomas@gmail.com]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

-The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-Visible credit is given to the original author.
-The software is distributed in a non-profit way.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


--]]

local floor,modf, insert = math.floor,math.modf, table.insert
local char,format,rep = string.char,string.format,string.rep



local tSHA1 = {}
tSHA1["bytes_to_w32"] = function(a,b,c,d) return a*0x1000000+b*0x10000+c*0x100+d end
tSHA1["w32_rot"] = function(bits,a)
    local b2 = 2^(32-bits)
    local a,b = modf(a/b2)
    return a+b*b2*(2^(bits))
end
tSHA1["w32_to_hexstring"] = function(w) return format("%08x",w) end



function SHA1(str) --Returns SHA1 Hash of @str
    if not str then return nil end
    str = tostring(str)
    local H0,H1,H2,H3,H4 = 0x67452301,0xEFCDAB89,0x98BADCFE,0x10325476,0xC3D2E1F0
    local msg_len_in_bits = #str * 8
    local first_append = char(0x80)
    local non_zero_message_bytes = #str +1 +8
    local current_mod = non_zero_message_bytes % 64
    local second_append = current_mod>0 and rep(char(0), 64 - current_mod) or ""
    local B1, R1 = modf(msg_len_in_bits  / 0x01000000)
    local B2, R2 = modf( 0x01000000 * R1 / 0x00010000)
    local B3, R3 = modf( 0x00010000 * R2 / 0x00000100)
    local B4    = 0x00000100 * R3
    local L64 = char( 0) .. char( 0) .. char( 0) .. char( 0)
            .. char(B1) .. char(B2) .. char(B3) .. char(B4)
    str = str .. first_append .. second_append .. L64
    assert(#str % 64 == 0)
    local chunks = #str / 64
    local W = { }
    local start, A, B, C, D, E, f, K, TEMP
    local chunk = 0
    while chunk < chunks do
        start,chunk = chunk * 64 + 1,chunk + 1
        for t = 0, 15 do
            W[t] = tSHA1.bytes_to_w32(str:byte(start, start + 3))
            start = start + 4
        end
        for t = 16, 79 do
            W[t] = tSHA1.w32_rot(1, bit.bxor(bit.bxor(W[t-3], W[t-8]), bit.bxor(W[t-14], W[t-16])))
        end
        A,B,C,D,E = H0,H1,H2,H3,H4
        for t = 0, 79 do
            if t <= 19 then
                f = bit.bor(bit.band(B, C), bit.band(bit.bnot(B), D))
                K = 0x5A827999
            elseif t <= 39 then
                f = bit.bxor(bit.bxor(B, C), D)
                K = 0x6ED9EBA1
            elseif t <= 59 then
                f = bit.bor(bit.bor(bit.band(B, C), bit.band(B, D)), bit.band(C, D))
                K = 0x8F1BBCDC
            else
                f = bit.bxor(bit.bxor(B, C), D)
                K = 0xCA62C1D6
            end
            A,B,C,D,E = (tSHA1.w32_rot(5, A)+ f + E + W[t] + K)% 0x100000000,
            A, tSHA1.w32_rot(30, B), C, D
        end        
        H0,H1,H2,H3,H4 = (H0+A)%0x100000000,(H1+B)%0x100000000,(H2+C)%0x100000000,(H3+D)%0x100000000,(H4+E)%0x100000000
    end
    local f = tSHA1.w32_to_hexstring
    return f(H0) .. f(H1) .. f(H2) .. f(H3) .. f(H4)
end
