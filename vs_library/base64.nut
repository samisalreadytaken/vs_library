//-----------------------------------------------------------------------
// base64 encoding/decoding
// Copyright (C) 2013 William Sherif - github.com/superwills/NibbleAndAHalf
//
// Modified for Squirrel
// Copyright (c) samisalreadytaken - github.com/samisalreadytaken
//-----------------------------------------------------------------------
//    string __B64.Encode(string)
//    string __B64.Decode(string)
//-----------------------------------------------------------------------
if(!("__B64"in::getroottable())){::__B64<-{_e="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",_d=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,62,0,0,0,63,52,53,54,55,56,57,58,59,60,61,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,0,0,0,0,0,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],function Encode(S){local i,O="",L=S.len(),l=L%3,a=((l&1)<<1)+((l&2)>>1);for(i=0;i<=L-3;i+=3){local x=S[i],y=S[i+1],z=S[i+2];O+=_e[x>>2].tochar()+_e[((0x3&x)<<4)+(y>>4)].tochar()+_e[((0x0f&y)<<2)+(z>>6)].tochar()+_e[0x3f&z].tochar()}if(a==2)O+=_e[S[i]>>2].tochar()+_e[(0x3&S[i])<<4].tochar()+"==";else if(a==1)O+=_e[S[i]>>2].tochar()+_e[((0x3&S[i])<<4)+(S[i+1]>>4)].tochar()+_e[(0x0f&S[i+1])<<2].tochar()+"=";;return O}function Decode(S){local i,O="",L=S.len(),l=L%3,a=0;if(L<2)return::print("__B64: Invalid base64 string! (too short)");if(S[L-1]=='=')++a;if(S[L-2]=='=')++a;for(i=0;i<=L-4-a;i+=4){local y=_d[S[i+1]],z=_d[S[i+2]];O+=((_d[S[i]]<<2)|(y>>4)).tochar()+((y<<4)|(z>>2)).tochar()+((z<<6)|_d[S[i+3]]).tochar()}if(a==1){local y=_d[S[i+1]];O+=((_d[S[i]]<<2)|(y>>4)).tochar()+((y<<4)|(_d[S[i+2]]>>2)).tochar()}else if(a==2)O+=((_d[S[i]]<<2)|(_d[S[i+1]]>>4)).tochar();;return O}}};;
