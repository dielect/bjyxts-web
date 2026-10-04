(()=>{var ue=class l{static read_bytes(e,t){let n=new l;return n.buf=e.getUint32(t,!0),n.buf_len=e.getUint32(t+4,!0),n}static read_bytes_array(e,t,n){let a=[];for(let s=0;s<n;s++)a.push(l.read_bytes(e,t+8*s));return a}},pe=class l{static read_bytes(e,t){let n=new l;return n.buf=e.getUint32(t,!0),n.buf_len=e.getUint32(t+4,!0),n}static read_bytes_array(e,t,n){let a=[];for(let s=0;s<n;s++)a.push(l.read_bytes(e,t+8*s));return a}},Ue=0,Be=1,ve=2;var Me=2,L=3,ie=4;var ne=class{head_length(){return 24}name_length(){return this.dir_name.byteLength}write_head_bytes(e,t){e.setBigUint64(t,this.d_next,!0),e.setBigUint64(t+8,this.d_ino,!0),e.setUint32(t+16,this.dir_name.length,!0),e.setUint8(t+20,this.d_type)}write_name_bytes(e,t,n){e.set(this.dir_name.slice(0,Math.min(this.dir_name.byteLength,n)),t)}constructor(e,t,n,a){let s=new TextEncoder().encode(n);this.d_next=e,this.d_ino=t,this.d_namlen=s.byteLength,this.d_type=a,this.dir_name=s}};var je=1;var X=class{write_bytes(e,t){e.setUint8(t,this.fs_filetype),e.setUint16(t+2,this.fs_flags,!0),e.setBigUint64(t+8,this.fs_rights_base,!0),e.setBigUint64(t+16,this.fs_rights_inherited,!0)}constructor(e,t){this.fs_rights_base=0n,this.fs_rights_inherited=0n,this.fs_filetype=e,this.fs_flags=t}};var Se=1,ae=2,We=4,Ne=8,Q=class{write_bytes(e,t){e.setBigUint64(t,this.dev,!0),e.setBigUint64(t+8,this.ino,!0),e.setUint8(t+16,this.filetype),e.setBigUint64(t+24,this.nlink,!0),e.setBigUint64(t+32,this.size,!0),e.setBigUint64(t+38,this.atim,!0),e.setBigUint64(t+46,this.mtim,!0),e.setBigUint64(t+52,this.ctim,!0)}constructor(e,t,n){this.dev=0n,this.nlink=0n,this.atim=0n,this.mtim=0n,this.ctim=0n,this.ino=e,this.filetype=t,this.size=n}},Ze=0;var et=1,Re=class l{static read_bytes(e,t){return new l(e.getBigUint64(t,!0),e.getUint8(t+8),e.getUint32(t+16,!0),e.getBigUint64(t+24,!0),e.getUint16(t+36,!0))}constructor(e,t,n,a,s){this.userdata=e,this.eventtype=t,this.clockid=n,this.timeout=a,this.flags=s}},Ee=class{write_bytes(e,t){e.setBigUint64(t,this.userdata,!0),e.setUint16(t+8,this.error,!0),e.setUint8(t+10,this.eventtype)}constructor(e,t,n){this.userdata=e,this.error=t,this.eventtype=n}};var Et=0,ze=class{write_bytes(e,t){e.setUint32(t,this.pr_name.byteLength,!0)}constructor(e){this.pr_name=new TextEncoder().encode(e)}},xe=class l{static dir(e){let t=new l;return t.tag=Et,t.inner=new ze(e),t}write_bytes(e,t){e.setUint32(t,this.tag,!0),this.inner.write_bytes(e,t+4)}};var xt=class{enable(e){this.log=vt(e===void 0?!0:e,this.prefix)}get enabled(){return this.isEnabled}constructor(e){this.isEnabled=e,this.prefix="wasi:",this.enable(e)}};function vt(l,e){return l?console.log.bind(console,"%c%s","color: #265BA0",e):()=>{}}var I=new xt(!1);var me=class extends Error{constructor(e){super("exit with exit code "+e),this.code=e}},Ye=class{start(e){this.inst=e;try{return e.exports._start(),0}catch(t){if(t instanceof me)return t.code;throw t}}initialize(e){this.inst=e,e.exports._initialize&&e.exports._initialize()}constructor(e,t,n,a={}){this.args=[],this.env=[],this.fds=[],I.enable(a.debug),this.args=e,this.env=t,this.fds=n;let s=this;this.wasiImport={args_sizes_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);o.setUint32(r,s.args.length,!0);let c=0;for(let d of s.args)c+=d.length+1;return o.setUint32(i,c,!0),I.log(o.getUint32(r,!0),o.getUint32(i,!0)),0},args_get(r,i){let o=new DataView(s.inst.exports.memory.buffer),c=new Uint8Array(s.inst.exports.memory.buffer),d=i;for(let _=0;_<s.args.length;_++){o.setUint32(r,i,!0),r+=4;let f=new TextEncoder().encode(s.args[_]);c.set(f,i),o.setUint8(i+f.length,0),i+=f.length+1}return I.enabled&&I.log(new TextDecoder("utf-8").decode(c.slice(d,i))),0},environ_sizes_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);o.setUint32(r,s.env.length,!0);let c=0;for(let d of s.env)c+=new TextEncoder().encode(d).length+1;return o.setUint32(i,c,!0),I.log(o.getUint32(r,!0),o.getUint32(i,!0)),0},environ_get(r,i){let o=new DataView(s.inst.exports.memory.buffer),c=new Uint8Array(s.inst.exports.memory.buffer),d=i;for(let _=0;_<s.env.length;_++){o.setUint32(r,i,!0),r+=4;let f=new TextEncoder().encode(s.env[_]);c.set(f,i),o.setUint8(i+f.length,0),i+=f.length+1}return I.enabled&&I.log(new TextDecoder("utf-8").decode(c.slice(d,i))),0},clock_res_get(r,i){let o;switch(r){case 1:{o=5000n;break}case 0:{o=1000000n;break}default:return 52}return new DataView(s.inst.exports.memory.buffer).setBigUint64(i,o,!0),0},clock_time_get(r,i,o){let c=new DataView(s.inst.exports.memory.buffer);if(r===0)c.setBigUint64(o,BigInt(new Date().getTime())*1000000n,!0);else if(r==1){let d;try{d=BigInt(Math.round(performance.now()*1e6))}catch{d=0n}c.setBigUint64(o,d,!0)}else c.setBigUint64(o,0n,!0);return 0},fd_advise(r,i,o,c){return s.fds[r]!=null?0:8},fd_allocate(r,i,o){return s.fds[r]!=null?s.fds[r].fd_allocate(i,o):8},fd_close(r){if(s.fds[r]!=null){let i=s.fds[r].fd_close();return s.fds[r]=void 0,i}else return 8},fd_datasync(r){return s.fds[r]!=null?s.fds[r].fd_sync():8},fd_fdstat_get(r,i){if(s.fds[r]!=null){let{ret:o,fdstat:c}=s.fds[r].fd_fdstat_get();return c?.write_bytes(new DataView(s.inst.exports.memory.buffer),i),o}else return 8},fd_fdstat_set_flags(r,i){return s.fds[r]!=null?s.fds[r].fd_fdstat_set_flags(i):8},fd_fdstat_set_rights(r,i,o){return s.fds[r]!=null?s.fds[r].fd_fdstat_set_rights(i,o):8},fd_filestat_get(r,i){if(s.fds[r]!=null){let{ret:o,filestat:c}=s.fds[r].fd_filestat_get();return c?.write_bytes(new DataView(s.inst.exports.memory.buffer),i),o}else return 8},fd_filestat_set_size(r,i){return s.fds[r]!=null?s.fds[r].fd_filestat_set_size(i):8},fd_filestat_set_times(r,i,o,c){return s.fds[r]!=null?s.fds[r].fd_filestat_set_times(i,o,c):8},fd_pread(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=ue.read_bytes_array(_,i,o),p=0;for(let u of h){let{ret:m,data:b}=s.fds[r].fd_pread(u.buf_len,c);if(m!=0)return _.setUint32(d,p,!0),m;if(f.set(b,u.buf),p+=b.length,c+=BigInt(b.length),b.length!=u.buf_len)break}return _.setUint32(d,p,!0),0}else return 8},fd_prestat_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:c,prestat:d}=s.fds[r].fd_prestat_get();return d?.write_bytes(o,i),c}else return 8},fd_prestat_dir_name(r,i,o){if(s.fds[r]!=null){let{ret:c,prestat:d}=s.fds[r].fd_prestat_get();if(d==null)return c;let _=d.inner.pr_name;return new Uint8Array(s.inst.exports.memory.buffer).set(_.slice(0,o),i),_.byteLength>o?37:0}else return 8},fd_pwrite(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=pe.read_bytes_array(_,i,o),p=0;for(let u of h){let m=f.slice(u.buf,u.buf+u.buf_len),{ret:b,nwritten:x}=s.fds[r].fd_pwrite(m,c);if(b!=0)return _.setUint32(d,p,!0),b;if(p+=x,c+=BigInt(x),x!=m.byteLength)break}return _.setUint32(d,p,!0),0}else return 8},fd_read(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer),_=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let f=ue.read_bytes_array(d,i,o),h=0;for(let p of f){let{ret:u,data:m}=s.fds[r].fd_read(p.buf_len);if(u!=0)return d.setUint32(c,h,!0),u;if(_.set(m,p.buf),h+=m.length,m.length!=p.buf_len)break}return d.setUint32(c,h,!0),0}else return 8},fd_readdir(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=0;for(;;){let{ret:p,dirent:u}=s.fds[r].fd_readdir_single(c);if(p!=0)return _.setUint32(d,h,!0),p;if(u==null)break;if(o-h<u.head_length()){h=o;break}let m=new ArrayBuffer(u.head_length());if(u.write_head_bytes(new DataView(m),0),f.set(new Uint8Array(m).slice(0,Math.min(m.byteLength,o-h)),i),i+=u.head_length(),h+=u.head_length(),o-h<u.name_length()){h=o;break}u.write_name_bytes(f,i,o-h),i+=u.name_length(),h+=u.name_length(),c=u.d_next}return _.setUint32(d,h,!0),0}else return 8},fd_renumber(r,i){if(s.fds[r]!=null&&s.fds[i]!=null){let o=s.fds[i].fd_close();return o!=0?o:(s.fds[i]=s.fds[r],s.fds[r]=void 0,0)}else return 8},fd_seek(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:_,offset:f}=s.fds[r].fd_seek(i,o);return d.setBigInt64(c,f,!0),_}else return 8},fd_sync(r){return s.fds[r]!=null?s.fds[r].fd_sync():8},fd_tell(r,i){let o=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:c,offset:d}=s.fds[r].fd_tell();return o.setBigUint64(i,d,!0),c}else return 8},fd_write(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer),_=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let f=pe.read_bytes_array(d,i,o),h=0;for(let p of f){let u=_.slice(p.buf,p.buf+p.buf_len),{ret:m,nwritten:b}=s.fds[r].fd_write(u);if(m!=0)return d.setUint32(c,h,!0),m;if(h+=b,b!=u.byteLength)break}return d.setUint32(c,h,!0),0}else return 8},path_create_directory(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_create_directory(d)}else return 8},path_filestat_get(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=new TextDecoder("utf-8").decode(f.slice(o,o+c)),{ret:p,filestat:u}=s.fds[r].path_filestat_get(i,h);return u?.write_bytes(_,d),p}else return 8},path_filestat_set_times(r,i,o,c,d,_,f){let h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let p=new TextDecoder("utf-8").decode(h.slice(o,o+c));return s.fds[r].path_filestat_set_times(i,p,d,_,f)}else return 8},path_link(r,i,o,c,d,_,f){let h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null&&s.fds[d]!=null){let p=new TextDecoder("utf-8").decode(h.slice(o,o+c)),u=new TextDecoder("utf-8").decode(h.slice(_,_+f)),{ret:m,inode_obj:b}=s.fds[r].path_lookup(p,i);return b==null?m:s.fds[d].path_link(u,b,!1)}else return 8},path_open(r,i,o,c,d,_,f,h,p){let u=new DataView(s.inst.exports.memory.buffer),m=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let b=new TextDecoder("utf-8").decode(m.slice(o,o+c));I.log(b);let{ret:x,fd_obj:S}=s.fds[r].path_open(i,b,d,_,f,h);if(x!=0)return x;s.fds.push(S);let N=s.fds.length-1;return u.setUint32(p,N,!0),0}else return 8},path_readlink(r,i,o,c,d,_){let f=new DataView(s.inst.exports.memory.buffer),h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let p=new TextDecoder("utf-8").decode(h.slice(i,i+o));I.log(p);let{ret:u,data:m}=s.fds[r].path_readlink(p);if(m!=null){let b=new TextEncoder().encode(m);if(b.length>d)return f.setUint32(_,0,!0),8;h.set(b,c),f.setUint32(_,b.length,!0)}return u}else return 8},path_remove_directory(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_remove_directory(d)}else return 8},path_rename(r,i,o,c,d,_){let f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null&&s.fds[c]!=null){let h=new TextDecoder("utf-8").decode(f.slice(i,i+o)),p=new TextDecoder("utf-8").decode(f.slice(d,d+_)),{ret:u,inode_obj:m}=s.fds[r].path_unlink(h);if(m==null)return u;if(u=s.fds[c].path_link(p,m,!0),u!=0&&s.fds[r].path_link(h,m,!0)!=0)throw"path_link should always return success when relinking an inode back to the original place";return u}else return 8},path_symlink(r,i,o,c,d){let _=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[o]!=null){let f=new TextDecoder("utf-8").decode(_.slice(r,r+i)),h=new TextDecoder("utf-8").decode(_.slice(c,c+d));return 58}else return 8},path_unlink_file(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_unlink_file(d)}else return 8},poll_oneoff(r,i,o){if(o===0)return 28;if(o>1)return I.log("poll_oneoff: only a single subscription is supported"),58;let c=new DataView(s.inst.exports.memory.buffer),d=Re.read_bytes(c,r),_=d.eventtype,f=d.clockid,h=d.timeout;if(_!==Ze)return I.log("poll_oneoff: only clock subscriptions are supported"),58;let p;if(f===1)p=()=>BigInt(Math.round(performance.now()*1e6));else if(f===0)p=()=>BigInt(new Date().getTime())*1000000n;else return 28;let u=(d.flags&et)!==0?h:p()+h;for(;u>p(););return new Ee(d.userdata,0,_).write_bytes(c,i),0},proc_exit(r){throw new me(r)},proc_raise(r){throw"raised signal "+r},sched_yield(){},random_get(r,i){let o=new Uint8Array(s.inst.exports.memory.buffer).subarray(r,r+i);if("crypto"in globalThis&&(typeof SharedArrayBuffer>"u"||!(s.inst.exports.memory.buffer instanceof SharedArrayBuffer)))for(let c=0;c<i;c+=65536)crypto.getRandomValues(o.subarray(c,c+65536));else for(let c=0;c<i;c++)o[c]=Math.random()*256|0},sock_recv(r,i,o){throw"sockets not supported"},sock_send(r,i,o){throw"sockets not supported"},sock_shutdown(r,i){throw"sockets not supported"},sock_accept(r,i){throw"sockets not supported"}}}};var H=class{fd_allocate(e,t){return 58}fd_close(){return 0}fd_fdstat_get(){return{ret:58,fdstat:null}}fd_fdstat_set_flags(e){return 58}fd_fdstat_set_rights(e,t){return 58}fd_filestat_get(){return{ret:58,filestat:null}}fd_filestat_set_size(e){return 58}fd_filestat_set_times(e,t,n){return 58}fd_pread(e,t){return{ret:58,data:new Uint8Array}}fd_prestat_get(){return{ret:58,prestat:null}}fd_pwrite(e,t){return{ret:58,nwritten:0}}fd_read(e){return{ret:58,data:new Uint8Array}}fd_readdir_single(e){return{ret:58,dirent:null}}fd_seek(e,t){return{ret:58,offset:0n}}fd_sync(){return 0}fd_tell(){return{ret:58,offset:0n}}fd_write(e){return{ret:58,nwritten:0}}path_create_directory(e){return 58}path_filestat_get(e,t){return{ret:58,filestat:null}}path_filestat_set_times(e,t,n,a,s){return 58}path_link(e,t,n){return 58}path_unlink(e){return{ret:58,inode_obj:null}}path_lookup(e,t){return{ret:58,inode_obj:null}}path_open(e,t,n,a,s,r){return{ret:54,fd_obj:null}}path_readlink(e){return{ret:58,data:null}}path_remove_directory(e){return 58}path_rename(e,t,n){return 58}path_unlink_file(e){return 58}},D=class l{static issue_ino(){return l.next_ino++}static root_ino(){return 0n}constructor(){this.ino=l.issue_ino()}};D.next_ino=1n;var oe=class extends H{fd_allocate(e,t){if(!(this.file.size>e+t)){let n=new Uint8Array(Number(e+t));n.set(this.file.data,0),this.file.data=n}return 0}fd_fdstat_get(){return{ret:0,fdstat:new X(ie,0)}}fd_filestat_set_size(e){if(this.file.size>e)this.file.data=new Uint8Array(this.file.data.buffer.slice(0,Number(e)));else{let t=new Uint8Array(Number(e));t.set(this.file.data,0),this.file.data=t}return 0}fd_read(e){let t=this.file.data.slice(Number(this.file_pos),Number(this.file_pos+BigInt(e)));return this.file_pos+=BigInt(t.length),{ret:0,data:t}}fd_pread(e,t){return{ret:0,data:this.file.data.slice(Number(t),Number(t+BigInt(e)))}}fd_seek(e,t){let n;switch(t){case Ue:n=e;break;case Be:n=this.file_pos+e;break;case ve:n=BigInt(this.file.data.byteLength)+e;break;default:return{ret:28,offset:0n}}return n<0?{ret:28,offset:0n}:(this.file_pos=n,{ret:0,offset:this.file_pos})}fd_tell(){return{ret:0,offset:this.file_pos}}fd_write(e){if(this.file.readonly)return{ret:8,nwritten:0};if(this.file_pos+BigInt(e.byteLength)>this.file.size){let t=this.file.data;this.file.data=new Uint8Array(Number(this.file_pos+BigInt(e.byteLength))),this.file.data.set(t)}return this.file.data.set(e,Number(this.file_pos)),this.file_pos+=BigInt(e.byteLength),{ret:0,nwritten:e.byteLength}}fd_pwrite(e,t){if(this.file.readonly)return{ret:8,nwritten:0};if(t+BigInt(e.byteLength)>this.file.size){let n=this.file.data;this.file.data=new Uint8Array(Number(t+BigInt(e.byteLength))),this.file.data.set(n)}return this.file.data.set(e,Number(t)),{ret:0,nwritten:e.byteLength}}fd_filestat_get(){return{ret:0,filestat:this.file.stat()}}constructor(e){super(),this.file_pos=0n,this.file=e}},be=class extends H{fd_seek(e,t){return{ret:8,offset:0n}}fd_tell(){return{ret:8,offset:0n}}fd_allocate(e,t){return 8}fd_fdstat_get(){return{ret:0,fdstat:new X(L,0)}}fd_readdir_single(e){if(I.enabled&&(I.log("readdir_single",e),I.log(e,this.dir.contents.keys())),e==0n)return{ret:0,dirent:new ne(1n,this.dir.ino,".",L)};if(e==1n)return{ret:0,dirent:new ne(2n,this.dir.parent_ino(),"..",L)};if(e>=BigInt(this.dir.contents.size)+2n)return{ret:0,dirent:null};let[t,n]=Array.from(this.dir.contents.entries())[Number(e-2n)];return{ret:0,dirent:new ne(e+1n,n.ino,t,n.stat().filetype)}}path_filestat_get(e,t){let{ret:n,path:a}=Y.from(t);if(a==null)return{ret:n,filestat:null};let{ret:s,entry:r}=this.dir.get_entry_for_path(a);return r==null?{ret:s,filestat:null}:{ret:0,filestat:r.stat()}}path_lookup(e,t){let{ret:n,path:a}=Y.from(e);if(a==null)return{ret:n,inode_obj:null};let{ret:s,entry:r}=this.dir.get_entry_for_path(a);return r==null?{ret:s,inode_obj:null}:{ret:0,inode_obj:r}}path_open(e,t,n,a,s,r){let{ret:i,path:o}=Y.from(t);if(o==null)return{ret:i,fd_obj:null};let{ret:c,entry:d}=this.dir.get_entry_for_path(o);if(d==null){if(c!=44)return{ret:c,fd_obj:null};if((n&Se)==Se){let{ret:_,entry:f}=this.dir.create_entry_for_path(t,(n&ae)==ae);if(f==null)return{ret:_,fd_obj:null};d=f}else return{ret:44,fd_obj:null}}else if((n&We)==We)return{ret:20,fd_obj:null};return(n&ae)==ae&&d.stat().filetype!==L?{ret:54,fd_obj:null}:d.path_open(n,a,r)}path_create_directory(e){return this.path_open(0,e,Se|ae,0n,0n,0).ret}path_link(e,t,n){let{ret:a,path:s}=Y.from(e);if(s==null)return a;if(s.is_dir)return 44;let{ret:r,parent_entry:i,filename:o,entry:c}=this.dir.get_parent_dir_and_entry_for_path(s,!0);if(i==null||o==null)return r;if(c!=null){let d=t.stat().filetype==L,_=c.stat().filetype==L;if(d&&_)if(n&&c instanceof z){if(c.contents.size!=0)return 55}else return 20;else{if(d&&!_)return 54;if(!d&&_)return 31;if(!(t.stat().filetype==ie&&c.stat().filetype==ie))return 20}}return!n&&t.stat().filetype==L?63:(i.contents.set(o,t),0)}path_unlink(e){let{ret:t,path:n}=Y.from(e);if(n==null)return{ret:t,inode_obj:null};let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!0);return s==null||r==null?{ret:a,inode_obj:null}:i==null?{ret:44,inode_obj:null}:(s.contents.delete(r),{ret:0,inode_obj:i})}path_unlink_file(e){let{ret:t,path:n}=Y.from(e);if(n==null)return t;let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!1);return s==null||r==null||i==null?a:i.stat().filetype===L?31:(s.contents.delete(r),0)}path_remove_directory(e){let{ret:t,path:n}=Y.from(e);if(n==null)return t;let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!1);return s==null||r==null||i==null?a:!(i instanceof z)||i.stat().filetype!==L?54:i.contents.size!==0?55:s.contents.delete(r)?0:44}fd_filestat_get(){return{ret:0,filestat:this.dir.stat()}}fd_filestat_set_size(e){return 8}fd_read(e){return{ret:8,data:new Uint8Array}}fd_pread(e,t){return{ret:8,data:new Uint8Array}}fd_write(e){return{ret:8,nwritten:0}}fd_pwrite(e,t){return{ret:8,nwritten:0}}constructor(e){super(),this.dir=e}},ge=class extends be{fd_prestat_get(){return{ret:0,prestat:xe.dir(this.prestat_name)}}constructor(e,t){super(new z(t)),this.prestat_name=e}},$=class extends D{path_open(e,t,n){if(this.readonly&&(t&BigInt(64))==BigInt(64))return{ret:63,fd_obj:null};if((e&Ne)==Ne){if(this.readonly)return{ret:63,fd_obj:null};this.data=new Uint8Array([])}let a=new oe(this);return n&je&&a.fd_seek(0n,ve),{ret:0,fd_obj:a}}get size(){return BigInt(this.data.byteLength)}stat(){return new Q(this.ino,ie,this.size)}constructor(e,t){super(),this.data=new Uint8Array(e),this.readonly=!!t?.readonly}},Y=class nt{static from(e){let t=new nt;if(t.is_dir=e.endsWith("/"),e.startsWith("/"))return{ret:76,path:null};if(e.includes("\0"))return{ret:28,path:null};for(let n of e.split("/"))if(!(n===""||n===".")){if(n===".."){if(t.parts.pop()==null)return{ret:76,path:null};continue}t.parts.push(n)}return{ret:0,path:t}}to_path_string(){let e=this.parts.join("/");return this.is_dir&&(e+="/"),e}constructor(){this.parts=[],this.is_dir=!1}},z=class l extends D{parent_ino(){return this.parent==null?D.root_ino():this.parent.ino}path_open(e,t,n){return{ret:0,fd_obj:new be(this)}}stat(){return new Q(this.ino,L,0n)}get_entry_for_path(e){let t=this;for(let n of e.parts){if(!(t instanceof l))return{ret:54,entry:null};let a=t.contents.get(n);if(a!==void 0)t=a;else return I.log(n),{ret:44,entry:null}}return e.is_dir&&t.stat().filetype!=L?{ret:54,entry:null}:{ret:0,entry:t}}get_parent_dir_and_entry_for_path(e,t){let n=e.parts.pop();if(n===void 0)return{ret:28,parent_entry:null,filename:null,entry:null};let{ret:a,entry:s}=this.get_entry_for_path(e);if(s==null)return{ret:a,parent_entry:null,filename:null,entry:null};if(!(s instanceof l))return{ret:54,parent_entry:null,filename:null,entry:null};let r=s.contents.get(n);return r===void 0?t?{ret:0,parent_entry:s,filename:n,entry:null}:{ret:44,parent_entry:null,filename:null,entry:null}:e.is_dir&&r.stat().filetype!=L?{ret:54,parent_entry:null,filename:null,entry:null}:{ret:0,parent_entry:s,filename:n,entry:r}}create_entry_for_path(e,t){let{ret:n,path:a}=Y.from(e);if(a==null)return{ret:n,entry:null};let{ret:s,parent_entry:r,filename:i,entry:o}=this.get_parent_dir_and_entry_for_path(a,!0);if(r==null||i==null)return{ret:s,entry:null};if(o!=null)return{ret:20,entry:null};I.log("create",a);let c;return t?c=new l(new Map):c=new $(new ArrayBuffer(0)),r.contents.set(i,c),o=c,{ret:0,entry:o}}constructor(e){super(),this.parent=null,e instanceof Array?this.contents=new Map(e):this.contents=e;for(let t of this.contents.values())t instanceof l&&(t.parent=this)}},ce=class l extends H{fd_filestat_get(){return{ret:0,filestat:new Q(this.ino,Me,BigInt(0))}}fd_fdstat_get(){let e=new X(Me,0);return e.fs_rights_base=BigInt(64),{ret:0,fdstat:e}}fd_write(e){return this.write(e),{ret:0,nwritten:e.byteLength}}static lineBuffered(e){let t=new TextDecoder("utf-8",{fatal:!1}),n="";return new l(a=>{n+=t.decode(a,{stream:!0});let s=n.split(`
`);for(let[r,i]of s.entries())r<s.length-1?e(i):n=i})}constructor(e){super(),this.ino=D.issue_ino(),this.write=e}};var $e=new DataView(new ArrayBuffer);function y(l){return $e.buffer!==l.buffer&&($e=new DataView(l.buffer)),$e}function it(l){return l>>>0}var B=new TextDecoder("utf-8"),Ot=new TextEncoder("utf-8");function q(l,e,t){if(typeof l!="string")throw new TypeError("expected a string");if(l.length===0)return U=0,1;let n=0,a=0,s=0;for(;l.length>0;){a=e(a,n,1,n+l.length),n+=l.length;let{read:r,written:i}=Ot.encodeInto(l,new Uint8Array(t.buffer,a+s,n-s));s+=i,l=l.slice(r)}return n>s&&(a=e(a,n,1,s)),U=s,a}var U=0,le=class{constructor(){this.list=[],this.head=0}insert(e){this.head>=this.list.length&&this.list.push({next:this.list.length+1,val:void 0});let t=this.head,n=this.list[t];return this.head=n.next,n.next=-1,n.val=e,t}get(e){if(e>=this.list.length)throw new RangeError("handle index not valid");let t=this.list[e];if(t.next===-1)return t.val;throw new RangeError("handle index not valid")}remove(e){let t=this.get(e),n=this.list[e];return n.val=void 0,n.next=this.head,this.head=e,t}};function de(){throw new RangeError("invalid variant discriminant for bool")}var _e=class{constructor(){this._resource0_slab=new le}addToImports(e){"canonical_abi"in e||(e.canonical_abi={}),e.canonical_abi["resource_drop_rb-abi-value"]=t=>{this._resource0_slab.remove(t).drop()},e.canonical_abi["resource_clone_rb-abi-value"]=t=>{let n=this._resource0_slab.get(t);return this._resource0_slab.insert(n.clone())},e.canonical_abi["resource_get_rb-abi-value"]=t=>this._resource0_slab.get(t)._wasm_val,e.canonical_abi["resource_new_rb-abi-value"]=t=>{let n=this._registry0;return this._resource0_slab.insert(new K(t,this))}}async instantiate(e,t){if(t=t||{},this.addToImports(t),e instanceof WebAssembly.Instance)this.instance=e;else if(e instanceof WebAssembly.Module)this.instance=await WebAssembly.instantiate(e,t);else if(e instanceof ArrayBuffer||e instanceof Uint8Array){let{instance:n}=await WebAssembly.instantiate(e,t);this.instance=n}else{let{instance:n}=await WebAssembly.instantiateStreaming(e,t);this.instance=n}this._exports=this.instance.exports,this._registry0=new FinalizationRegistry(this._exports["canonical_abi_drop_rb-abi-value"])}rubyShowVersion(){this._exports["ruby-show-version: func() -> ()"]()}rubyInit(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=e,s=a.length,r=n(0,0,4,s*8);for(let i=0;i<a.length;i++){let o=a[i],c=r+i*8,d=q(o,n,t),_=U;y(t).setInt32(c+4,_,!0),y(t).setInt32(c+0,d,!0)}this._exports["ruby-init: func(args: list<string>) -> ()"](r,s)}rubyInitLoadpath(){this._exports["ruby-init-loadpath: func() -> ()"]()}rbEvalStringProtect(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=q(e,n,t),s=U,r=this._exports["rb-eval-string-protect: func(str: string) -> tuple<handle<rb-abi-value>, s32>"](a,s);return[this._resource0_slab.remove(y(t).getInt32(r+0,!0)),y(t).getInt32(r+4,!0)]}rbFuncallvProtect(e,t,n){let a=this._exports.memory,s=this._exports.cabi_realloc,r=e;if(!(r instanceof K))throw new TypeError("expected instance of RbAbiValue");let i=n,o=i.length,c=s(0,0,4,o*4);for(let _=0;_<i.length;_++){let f=i[_],h=c+_*4,p=f;if(!(p instanceof K))throw new TypeError("expected instance of RbAbiValue");y(a).setInt32(h+0,this._resource0_slab.insert(p.clone()),!0)}let d=this._exports["rb-funcallv-protect: func(recv: handle<rb-abi-value>, mid: u32, args: list<handle<rb-abi-value>>) -> tuple<handle<rb-abi-value>, s32>"](this._resource0_slab.insert(r.clone()),it(t),c,o);return[this._resource0_slab.remove(y(a).getInt32(d+0,!0)),y(a).getInt32(d+4,!0)]}rbIntern(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=q(e,n,t),s=U;return this._exports["rb-intern: func(name: string) -> u32"](a,s)>>>0}rbErrinfo(){let e=this._exports["rb-errinfo: func() -> handle<rb-abi-value>"]();return this._resource0_slab.remove(e)}rbClearErrinfo(){this._exports["rb-clear-errinfo: func() -> ()"]()}rstringPtr(e){let t=this._exports.memory,n=e;if(!(n instanceof K))throw new TypeError("expected instance of RbAbiValue");let a=this._exports["rstring-ptr: func(value: handle<rb-abi-value>) -> string"](this._resource0_slab.insert(n.clone())),s=y(t).getInt32(a+0,!0),r=y(t).getInt32(a+4,!0),i=B.decode(new Uint8Array(t.buffer,s,r));return this._exports["cabi_post_rstring-ptr"](a),i}rbVmBugreport(){this._exports["rb-vm-bugreport: func() -> ()"]()}rbGcEnable(){let t=this._exports["rb-gc-enable: func() -> bool"]();return t==0?!1:t==1?!0:de()}rbGcDisable(){let t=this._exports["rb-gc-disable: func() -> bool"]();return t==0?!1:t==1?!0:de()}rbSetShouldProhibitRewind(e){let n=this._exports["rb-set-should-prohibit-rewind: func(new-value: bool) -> bool"](e?1:0);return n==0?!1:n==1?!0:de()}},K=class{constructor(e,t){this._wasm_val=e,this._obj=t,this._refcnt=1,t._registry0.register(this,e,this)}clone(){return this._refcnt+=1,this}drop(){if(this._refcnt-=1,this._refcnt!==0)return;this._obj._registry0.unregister(this);let e=this._obj._exports["canonical_abi_drop_rb-abi-value"],t=this._wasm_val;delete this._obj,delete this._refcnt,delete this._wasm_val,e(t)}};function ot(l,e,t){"rb-js-abi-host"in l||(l["rb-js-abi-host"]={}),l["rb-js-abi-host"]["eval-js: func(code: string) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r){let i=t("memory"),o=a,c=s,d=B.decode(new Uint8Array(i.buffer,o,c)),f=e.evalJs(d);switch(f.tag){case"success":{let h=f.val;y(i).setInt8(r+0,0,!0),y(i).setInt32(r+4,n.insert(h),!0);break}case"failure":{let h=f.val;y(i).setInt8(r+0,1,!0),y(i).setInt32(r+4,n.insert(h),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["is-js: func(value: handle<js-abi-value>) -> bool"]=function(a){return e.isJs(n.get(a))?1:0},l["rb-js-abi-host"]["instance-of: func(value: handle<js-abi-value>, klass: handle<js-abi-value>) -> bool"]=function(a,s){return e.instanceOf(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["global-this: func() -> handle<js-abi-value>"]=function(){let a=e.globalThis();return n.insert(a)},l["rb-js-abi-host"]["int-to-js-number: func(value: s32) -> handle<js-abi-value>"]=function(a){let s=e.intToJsNumber(a);return n.insert(s)},l["rb-js-abi-host"]["float-to-js-number: func(value: float64) -> handle<js-abi-value>"]=function(a){let s=e.floatToJsNumber(a);return n.insert(s)},l["rb-js-abi-host"]["string-to-js-string: func(value: string) -> handle<js-abi-value>"]=function(a,s){let r=t("memory"),i=a,o=s,c=B.decode(new Uint8Array(r.buffer,i,o)),d=e.stringToJsString(c);return n.insert(d)},l["rb-js-abi-host"]["bool-to-js-bool: func(value: bool) -> handle<js-abi-value>"]=function(a){let s=a,r=e.boolToJsBool(s==0?!1:s==1?!0:de());return n.insert(r)},l["rb-js-abi-host"]["proc-to-js-function: func(value: u32) -> handle<js-abi-value>"]=function(a){let s=e.procToJsFunction(a>>>0);return n.insert(s)},l["rb-js-abi-host"]["rb-object-to-js-rb-value: func(raw-rb-abi-value: u32) -> handle<js-abi-value>"]=function(a){let s=e.rbObjectToJsRbValue(a>>>0);return n.insert(s)},l["rb-js-abi-host"]["js-value-to-string: func(value: handle<js-abi-value>) -> string"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),o=e.jsValueToString(n.get(a)),c=q(o,i,r),d=U;y(r).setInt32(s+4,d,!0),y(r).setInt32(s+0,c,!0)},l["rb-js-abi-host"]["js-value-to-integer: func(value: handle<js-abi-value>) -> variant { as-float(float64), bignum(string) }"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),c=e.jsValueToInteger(n.get(a));switch(c.tag){case"as-float":{let d=c.val;y(r).setInt8(s+0,0,!0),y(r).setFloat64(s+8,+d,!0);break}case"bignum":{let d=c.val;y(r).setInt8(s+0,1,!0);let _=q(d,i,r),f=U;y(r).setInt32(s+12,f,!0),y(r).setInt32(s+8,_,!0);break}default:throw new RangeError("invalid variant specified for RawInteger")}},l["rb-js-abi-host"]["export-js-value-to-host: func(value: handle<js-abi-value>) -> ()"]=function(a){e.exportJsValueToHost(n.get(a))},l["rb-js-abi-host"]["import-js-value-from-host: func() -> handle<js-abi-value>"]=function(){let a=e.importJsValueFromHost();return n.insert(a)},l["rb-js-abi-host"]["js-value-typeof: func(value: handle<js-abi-value>) -> string"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),o=e.jsValueTypeof(n.get(a)),c=q(o,i,r),d=U;y(r).setInt32(s+4,d,!0),y(r).setInt32(s+0,c,!0)},l["rb-js-abi-host"]["js-value-equal: func(lhs: handle<js-abi-value>, rhs: handle<js-abi-value>) -> bool"]=function(a,s){return e.jsValueEqual(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["js-value-strictly-equal: func(lhs: handle<js-abi-value>, rhs: handle<js-abi-value>) -> bool"]=function(a,s){return e.jsValueStrictlyEqual(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["reflect-apply: func(target: handle<js-abi-value>, this-argument: handle<js-abi-value>, arguments: list<handle<js-abi-value>>) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i,o){let c=t("memory"),d=i,_=r,f=[];for(let u=0;u<d;u++){let m=_+u*4;f.push(n.get(y(c).getInt32(m+0,!0)))}let p=e.reflectApply(n.get(a),n.get(s),f);switch(p.tag){case"success":{let u=p.val;y(c).setInt8(o+0,0,!0),y(c).setInt32(o+4,n.insert(u),!0);break}case"failure":{let u=p.val;y(c).setInt8(o+0,1,!0),y(c).setInt32(o+4,n.insert(u),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-construct: func(target: handle<js-abi-value>, arguments: list<handle<js-abi-value>>) -> handle<js-abi-value>"]=function(a,s,r){let i=t("memory"),o=r,c=s,d=[];for(let f=0;f<o;f++){let h=c+f*4;d.push(n.get(y(i).getInt32(h+0,!0)))}let _=e.reflectConstruct(n.get(a),d);return n.insert(_)},l["rb-js-abi-host"]["reflect-delete-property: func(target: handle<js-abi-value>, property-key: string) -> bool"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c));return e.reflectDeleteProperty(n.get(a),d)?1:0},l["rb-js-abi-host"]["reflect-get: func(target: handle<js-abi-value>, property-key: string) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i){let o=t("memory"),c=s,d=r,_=B.decode(new Uint8Array(o.buffer,c,d)),h=e.reflectGet(n.get(a),_);switch(h.tag){case"success":{let p=h.val;y(o).setInt8(i+0,0,!0),y(o).setInt32(i+4,n.insert(p),!0);break}case"failure":{let p=h.val;y(o).setInt8(i+0,1,!0),y(o).setInt32(i+4,n.insert(p),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-get-own-property-descriptor: func(target: handle<js-abi-value>, property-key: string) -> handle<js-abi-value>"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c)),_=e.reflectGetOwnPropertyDescriptor(n.get(a),d);return n.insert(_)},l["rb-js-abi-host"]["reflect-get-prototype-of: func(target: handle<js-abi-value>) -> handle<js-abi-value>"]=function(a){let s=e.reflectGetPrototypeOf(n.get(a));return n.insert(s)},l["rb-js-abi-host"]["reflect-has: func(target: handle<js-abi-value>, property-key: string) -> bool"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c));return e.reflectHas(n.get(a),d)?1:0},l["rb-js-abi-host"]["reflect-is-extensible: func(target: handle<js-abi-value>) -> bool"]=function(a){return e.reflectIsExtensible(n.get(a))?1:0},l["rb-js-abi-host"]["reflect-own-keys: func(target: handle<js-abi-value>) -> list<handle<js-abi-value>>"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),c=e.reflectOwnKeys(n.get(a)),d=c.length,_=i(0,0,4,d*4);for(let f=0;f<c.length;f++){let h=c[f],p=_+f*4;y(r).setInt32(p+0,n.insert(h),!0)}y(r).setInt32(s+4,d,!0),y(r).setInt32(s+0,_,!0)},l["rb-js-abi-host"]["reflect-prevent-extensions: func(target: handle<js-abi-value>) -> bool"]=function(a){return e.reflectPreventExtensions(n.get(a))?1:0},l["rb-js-abi-host"]["reflect-set: func(target: handle<js-abi-value>, property-key: string, value: handle<js-abi-value>) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i,o){let c=t("memory"),d=s,_=r,f=B.decode(new Uint8Array(c.buffer,d,_)),p=e.reflectSet(n.get(a),f,n.get(i));switch(p.tag){case"success":{let u=p.val;y(c).setInt8(o+0,0,!0),y(c).setInt32(o+4,n.insert(u),!0);break}case"failure":{let u=p.val;y(c).setInt8(o+0,1,!0),y(c).setInt32(o+4,n.insert(u),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-set-prototype-of: func(target: handle<js-abi-value>, prototype: handle<js-abi-value>) -> bool"]=function(a,s){return e.reflectSetPrototypeOf(n.get(a),n.get(s))?1:0},"canonical_abi"in l||(l.canonical_abi={});let n=new le;l.canonical_abi["resource_drop_js-abi-value"]=a=>{let s=n.remove(a);e.dropJsAbiValue&&e.dropJsAbiValue(s)}}var Ae=class extends _e{async setInstance(e){await this.instantiate(e)}},Ce=class{constructor(){}setUnderlying(e){this.underlying=e}rubyShowVersion(){this.underlying.rubyShowVersion()}rubyInit(e){this.underlying.rubyInit(e)}rubyInitLoadpath(){this.underlying.rubyInitLoadpath()}rbEvalStringProtect(e){return this.underlying.rbEvalStringProtect(e)}rbFuncallvProtect(e,t,n){return this.underlying.rbFuncallvProtect(e,t,n)}rbIntern(e){return this.underlying.rbIntern(e)}rbErrinfo(){return this.underlying.rbErrinfo()}rbClearErrinfo(){return this.underlying.rbClearErrinfo()}rstringPtr(e){return this.underlying.rstringPtr(e)}rbVmBugreport(){this.underlying.rbVmBugreport()}rbGcEnable(){return this.underlying.rbGcEnable()}rbGcDisable(){return this.underlying.rbGcDisable()}rbSetShouldProhibitRewind(e){return this.underlying.rbSetShouldProhibitRewind(e)}async setInstance(e){}addToImports(e){}};var Le=class l{static async instantiateModule(e){var t,n;let{module:a,wasip1:s}=e,r=new l,i={wasi_snapshot_preview1:s.wasiImport};r.addToImports(i),(t=e.addToImports)===null||t===void 0||t.call(e,i);let o=await WebAssembly.instantiate(a,i);try{await r.setInstance(o)}catch(c){throw console.error('Failed to instantiate Ruby VM. Please make sure that you have added `gem "js"` to your Gemfile.'),c}return(n=e.setMemory)===null||n===void 0||n.call(e,o.exports.memory),s.initialize(o),r.initialize(e.args),{vm:r,instance:o}}static async instantiateComponent(e){let t;return"getCoreModule"in e?t=async a=>{let{instantiate:s,getCoreModule:r,wasip2:i}=e,{cli:o,clocks:c,filesystem:d,io:_,random:f,sockets:h,http:p}=i,u=e.env?Object.assign(Object.assign({},o.environment),{getEnvironment:()=>{var x;return Array.from(new Map([...o.environment.getEnvironment(),...Object.entries((x=e.env)!==null&&x!==void 0?x:{})]).entries())}}):o.environment,m={"ruby:js/js-runtime":a,"wasi:cli/environment":u,"wasi:cli/exit":o.exit,"wasi:cli/stderr":o.stderr,"wasi:cli/stdin":o.stdin,"wasi:cli/stdout":o.stdout,"wasi:cli/terminal-input":o.terminalInput,"wasi:cli/terminal-output":o.terminalOutput,"wasi:cli/terminal-stderr":o.terminalStderr,"wasi:cli/terminal-stdin":o.terminalStdin,"wasi:cli/terminal-stdout":o.terminalStdout,"wasi:clocks/monotonic-clock":c.monotonicClock,"wasi:clocks/wall-clock":c.wallClock,"wasi:filesystem/preopens":d.preopens,"wasi:filesystem/types":d.types,"wasi:io/error":_.error,"wasi:io/poll":_.poll,"wasi:io/streams":_.streams,"wasi:random/random":f.random,"wasi:sockets/tcp":h.tcp,"wasi:http/types":p.types,"wasi:http/incoming-handler":p.incomingHandler,"wasi:http/outgoing-handler":p.outgoingHandler};return(await s(r,m,e.instantiateCore)).rubyRuntime}:t=e.instantiate,{vm:await this._instantiate({},t)}}constructor(e){this.instance=null,this.interfaceState={hasJSFrameAfterRbFrame:!1};let t=n=>{let a=["setInstance","addToImports","instantiate","rbSetShouldProhibitRewind","rbGcDisable","rbGcEnable"],s=["constructor"].concat(a);for(let r of Object.getOwnPropertyNames(_e.prototype)){if(s.includes(r))continue;let i=n[r];typeof i=="function"&&(n[r]=(...o)=>{if(this.interfaceState.hasJSFrameAfterRbFrame){let d=this.guest.rbSetShouldProhibitRewind(!0),_=this.guest.rbGcDisable(),f=Reflect.apply(i,n,o);return this.guest.rbSetShouldProhibitRewind(d),_||this.guest.rbGcEnable(),f}else return Reflect.apply(i,n,o)})}return n};this.guest=t(e??new Ae),this.transport=new qe,this.exceptionFormatter=new Ke}static async _instantiate(e,t){let n=new Ce,a=new l(n);class s{constructor(c){this.underlying=c}}let r=a.getImports(o=>new s(o),o=>o.underlying),i=await t(Object.assign(Object.assign({},r),{throwProhibitRewindException:o=>{a.throwProhibitRewindException(o)},procToJsFunction:()=>{let o=new J(i.exportRbValueToJs(),a,a.privateObject());return new s((...c)=>o.call("call",...c.map(d=>a.wrap(d))).toJS())},rbObjectToJsRbValue:()=>{let o=new J(i.exportRbValueToJs(),a,a.privateObject());return new s(o)},JsAbiValue:s}));return n.setUnderlying(i),a.initialize(e.args),a}initialize(e=["ruby.wasm","-EUTF-8","-e_=0"]){let t=e.map(n=>n+"\0");this.guest.rubyInit(t);try{this.eval(`
        # Require Bundler standalone setup
        if File.exist?("/bundle/bundler/setup.rb")
          # Some ruby-head + ruby.wasm revisions return from rubyInit with a partial
          # Gem module: Gem is defined, but RubyGems is not loaded yet and its API
          # helpers are still missing. Bundler standalone treats defined?(Gem) as
          # sufficient, so load RubyGems explicitly before requiring its setup file.
          require "rubygems" if defined?(Gem) && !Gem.respond_to?(:ruby_api_version)
          require "/bundle/bundler/setup.rb"
        elsif File.exist?("/bundle/setup.rb")
          # For non-CM builds, which doesn't use Bundler's standalone mode
          require "/bundle/setup.rb"
        end
      `)}catch(n){console.warn("Failed to load /bundle/setup",n)}}async setInstance(e){this.instance=e,await this.guest.setInstance(e)}addToImports(e){this.guest.addToImports(e),e["rb-js-abi-host"]={rb_wasm_throw_prohibit_rewind_exception:(t,n)=>{let a=this.instance.exports.memory,s=new TextDecoder().decode(new Uint8Array(a.buffer,t,n));this.throwProhibitRewindException(s)}},ot(e,this.getImports(t=>t,t=>t),t=>this.instance.exports[t])}throwProhibitRewindException(e){let t=`Ruby APIs that may rewind the VM stack are prohibited under nested VM operation (${e})
Nested VM operation means that the call stack has sandwitched JS frames like JS -> Ruby -> JS -> Ruby caused by something like \`window.rubyVM.eval("JS.global[:rubyVM].eval('Fiber.yield')")\`

Please check your call stack and make sure that you are **not** doing any of the following inside the nested Ruby frame:
  1. Switching fibers (e.g. Fiber#resume, Fiber.yield, and Fiber#transfer)
     Note that \`evalAsync\` JS API switches fibers internally
  2. Raising uncaught exceptions
     Please catch all exceptions inside the nested operation
  3. Calling Continuation APIs
`,n=new J(this.guest.rbErrinfo(),this,this.privateObject());throw n.call("nil?").toString()==="false"&&(t+=`
`+this.exceptionFormatter.format(n,this,this.privateObject())),new ke(t)}getImports(e,t){let n=s=>{for(let[r,i]of Object.entries(s))typeof i=="function"&&(s[r]=(...o)=>{let c=this.interfaceState.hasJSFrameAfterRbFrame;this.interfaceState.hasJSFrameAfterRbFrame=!0;let d=Reflect.apply(i,s,o);return this.interfaceState.hasJSFrameAfterRbFrame=c,d});return s};function a(s){return(...r)=>{try{return{tag:"success",val:s(...r)}}catch(i){if(i instanceof ke)throw i;return{tag:"failure",val:e(i)}}}}return n({evalJs:a(s=>e(Function(s)())),isJs:s=>!0,globalThis:()=>{if(typeof globalThis<"u")return e(globalThis);if(typeof global<"u")return e(global);if(typeof window<"u")return e(window);throw new Error("unable to locate global object")},intToJsNumber:s=>e(s),floatToJsNumber:s=>e(s),stringToJsString:s=>e(s),boolToJsBool:s=>e(s),procToJsFunction:s=>{let r=this.rbValueOfPointer(s);return e((...i)=>r.call("call",...i.map(o=>this.wrap(o))).toJS())},rbObjectToJsRbValue:s=>e(this.rbValueOfPointer(s)),jsValueToString:s=>(s=t(s),String(s)),jsValueToInteger(s){return s=t(s),typeof s=="number"?{tag:"as-float",val:s}:typeof s=="bigint"?{tag:"bignum",val:BigInt(s).toString(10)+"\0"}:typeof s=="string"?{tag:"bignum",val:s+"\0"}:typeof s>"u"?{tag:"as-float",val:0}:{tag:"as-float",val:Number(s)}},exportJsValueToHost:s=>{this.transport.takeJsValue(t(s))},importJsValueFromHost:()=>e(this.transport.consumeJsValue()),instanceOf:(s,r)=>(r=t(r),typeof r=="function"?t(s)instanceof r:!1),jsValueTypeof(s){return typeof t(s)},jsValueEqual(s,r){return t(s)==t(r)},jsValueStrictlyEqual(s,r){return t(s)===t(r)},reflectApply:a((s,r,i)=>{let o=i.map(c=>t(c));return e(Reflect.apply(t(s),t(r),o))}),reflectConstruct:function(s,r){throw new Error("Function not implemented.")},reflectDeleteProperty:function(s,r){throw new Error("Function not implemented.")},reflectGet:a((s,r)=>e(t(s)[r])),reflectGetOwnPropertyDescriptor:function(s,r){throw new Error("Function not implemented.")},reflectGetPrototypeOf:function(s){throw new Error("Function not implemented.")},reflectHas:function(s,r){throw new Error("Function not implemented.")},reflectIsExtensible:function(s){throw new Error("Function not implemented.")},reflectOwnKeys:function(s){throw new Error("Function not implemented.")},reflectPreventExtensions:function(s){throw new Error("Function not implemented.")},reflectSet:a((s,r,i)=>e(Reflect.set(t(s),r,t(i)))),reflectSetPrototypeOf:function(s,r){throw new Error("Function not implemented.")}})}printVersion(){this.guest.rubyShowVersion()}eval(e){return Fe(this,this.privateObject(),e)}evalAsync(e){let t=this.eval("require 'js'; JS");return _t(this,this.privateObject(),n=>{t.call("__eval_async_rb",this.wrap(e),n)})}wrap(e){return this.transport.importJsValue(e,this)}privateObject(){return{transport:this.transport,exceptionFormatter:this.exceptionFormatter}}rbValueOfPointer(e){let t=new K(e,this.guest);return new J(t,this,this.privateObject())}},qe=class{constructor(){this._takenJsValue=null}takeJsValue(e){this._takenJsValue=e}consumeJsValue(){return this._takenJsValue}exportJsValue(e){return e.call("__export_to_js"),this._takenJsValue}importJsValue(e,t){return this._takenJsValue=e,t.eval('require "js"; JS::Object').call("__import_from_js")}},J=class l{constructor(e,t,n){this.inner=e,this.vm=t,this.privateObject=n}call(e,...t){let n=t.map(a=>a.inner);return new l(ct(this.vm,this.privateObject,this.inner,e,n),this.vm,this.privateObject)}callAsync(e,...t){let n=this.vm.eval("require 'js'; JS");return _t(this.vm,this.privateObject,a=>{n.call("__call_async_method",this,this.vm.wrap(e),a,...t)})}[Symbol.toPrimitive](e){return e==="string"||e==="default"?this.toString():null}toString(){let e=ct(this.vm,this.privateObject,this.inner,"to_s",[]);return this.vm.guest.rstringPtr(e)}toJS(){let t=this.vm.eval("JS").call("try_convert",this);return t.call("nil?").toString()==="true"?null:this.privateObject.transport.exportJsValue(t)}},k;(function(l){l[l.None=0]="None",l[l.Return=1]="Return",l[l.Break=2]="Break",l[l.Next=3]="Next",l[l.Retry=4]="Retry",l[l.Redo=5]="Redo",l[l.Raise=6]="Raise",l[l.Throw=7]="Throw",l[l.Fatal=8]="Fatal",l[l.Mask=15]="Mask"})(k||(k={}));var Ke=class{constructor(){this.literalsCache=null,this.isFormmatting=!1}format(e,t,n){class a extends Error{}if(this.isFormmatting)throw new a("Unexpected exception occurred during formatting exception message");this.isFormmatting=!0;try{return this._format(e,t,n)}finally{this.isFormmatting=!1}}_format(e,t,n){let[a,s,r]=(()=>{if(this.literalsCache==null){let d=[Fe(t,n,"0"),Fe(t,n,"1"),Fe(t,n,`"
"`)];return this.literalsCache=d,d}else return this.literalsCache})(),i,o,c;try{i=e.call("class").toString()}catch{i="unknown"}try{c=e.call("message").toString()}catch{c="unknown"}try{o=e.call("backtrace")}catch{return this.formatString(i,c)}if(o.call("nil?").toString()==="true")return this.formatString(i,c);try{let d=o.call("at",a),_=o.call("drop",s).call("join",r);return this.formatString(i,c,[d.toString(),_.toString()])}catch{return this.formatString(i,c)}}formatString(e,t,n){return n?`${n[0]}: ${t} (${e})
${n[1]}`:`${e}: ${t}`}},lt=(l,e,t)=>{switch(l&k.Mask){case k.None:break;case k.Return:throw new F("unexpected return");case k.Next:throw new F("unexpected next");case k.Break:throw new F("unexpected break");case k.Redo:throw new F("unexpected redo");case k.Retry:throw new F("retry outside of rescue clause");case k.Throw:throw new F("unexpected throw");case k.Raise:case k.Fatal:let n=new J(e.guest.rbErrinfo(),e,t);throw n.call("nil?").toString()==="true"?new F("no exception object"):(e.guest.rbClearErrinfo(),new F(t.exceptionFormatter.format(n,e,t)));default:throw new F(`unknown error tag: ${l}`)}};function dt(l,e){try{return e()}catch(t){if(t instanceof F)throw t;try{l.guest.rbVmBugreport()}catch(n){console.error("Tried to report internal Ruby VM state but failed: ",n)}if(t instanceof WebAssembly.RuntimeError&&t.message==="unreachable"){let n=new F(`Something went wrong in Ruby VM: ${t}`);throw n.stack=t.stack,n}else throw t}}var ct=(l,e,t,n,a)=>{let s=l.guest.rbIntern(n+"\0");return dt(l,()=>{let[r,i]=l.guest.rbFuncallvProtect(t,s,a);return lt(i,l,e),r})},Fe=(l,e,t)=>dt(l,()=>{let[n,a]=l.guest.rbEvalStringProtect(t+"\0");return lt(a,l,e),new J(n,l,e)});function _t(l,e,t){return new Promise((n,a)=>{let s=l.wrap({resolve:n,reject:r=>{let i=new F(e.exceptionFormatter.format(r,l,e));a(i)}});t(s)})}var F=class extends Error{constructor(e){super(e)}},ke=class extends F{constructor(e){super("Ruby Fatal Error: "+e)}};var ft=[32,64,48,64,32,80,48,80,64,0,48,64,32,80,48,80,32,64,80,0,32,80,48,80,64,0,80,0,32,80,48,80,32,64,48,64,32,80,80,16,64,0,48,64,32,80,80,16,32,64,80,0,32,80,80,16,64,0,80,0,32,80,80,16,32,64,48,64,64,16,48,80,64,0,48,64,64,16,48,80,32,64,80,0,64,16,48,80,64,0,80,0,64,16,48,80,32,64,48,64,64,16,80,16,64,0,48,64,64,16,80,16,32,64,80,0,64,16,80,16,64,0,80,0,64,16,80,16,0,64,16,64,0,80,16,80,0,64,80,0,0,80,16,80,0,64,16,64,0,80,80,16,0,64,80,0,0,80,80,16,32,32,48,32,32,48,48,48,32,32,48,32,32,48,80,16,32,32,48,32,64,16,48,48,32,32,48,32,64,16,80,16,64,64,80,64,64,80,80,80,64,64,80,64,64,16,80,80,64,0,80,64,64,80,80,80,64,0,80,64,64,16,80,80,32,96,48,96,32,112,48,112,64,0,48,96,32,112,48,112,32,96,80,0,32,112,48,112,64,0,80,0,32,112,48,112,0,64,80,64,0,80,80,80,32,32,48,32,32,112,48,112,0,32,16,32,0,48,16,48,0,32,16,32,0,48,80,16,64,32,80,32,64,48,80,48,64,32,80,32,64,16,80,48,64,96,80,96,64,112,80,112,64,0,80,96,64,112,80,112,0,96,16,96,0,112,16,112,0,96,80,0,0,112,16,112,0,32,80,32,0,48,80,48],ee=640,te=480;function P(l,e){let t=document.createElement("canvas");return t.width=Math.max(1,l|0),t.height=Math.max(1,e|0),t}var we={\u5B8B\u4F53:'"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", "Noto Serif SC", serif',simsun:'"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", serif',\u9ED1\u4F53:'"GameSong", "PingFang SC", "Microsoft YaHei", sans-serif',arial:'Arial, Helvetica, "GameSong", sans-serif',"arial black":'"Arial Black", Arial, "GameSong", sans-serif'};function Tt(l){let e=String(l||"").split("").filter(Boolean);for(let t of e){let n=t.toLowerCase();if(we[t])return we[t];if(we[n])return we[n]}return we.\u5B8B\u4F53}var Ge=class{constructor(e){this.canvas=e.canvas,this.ctx=this.canvas.getContext("2d"),this.images=e.images,this.audioFiles=e.audioFiles,this.fs=e.fs,this.storage=e.storage,this.ui=e.ui,this.bmps=new Map,this.nextBmp=1,this.tilemaps=new Map,this.frozen=null,this.trans=null,this.lastFrameTime=0,this.keysHeld=new Set,this.touchHeld=new Set,this.dirOrder=[],this.latched=new Set,this.frameCount=0,this.fpsSamples=[],this.resetRequested=!1,this.measureCtx=P(4,4).getContext("2d"),this.tmp=P(64,64),this.tmpCtx=this.tmp.getContext("2d"),this.tmp2=P(64,64),this.tmp2Ctx=this.tmp2.getContext("2d"),this.vpCanvas=P(ee,te),this.vpCtx=this.vpCanvas.getContext("2d"),this.screenBuf=P(ee,te),this.screenCtx=this.screenBuf.getContext("2d"),this.audio=new Je(this.audioFiles),this.ctx.imageSmoothingEnabled=!1,this.lastList=[]}_reg(e){let t=this.nextBmp++,n=e.getContext("2d",{willReadFrequently:!1});return n.imageSmoothingEnabled=!1,this.bmps.set(t,{c:e,x:n,ver:0,at:null}),t}_b(e){return this.bmps.get(e)}findImage(e){let t=String(e).replace(/\\/g,"/").toLowerCase();if(this.images.has(t))return this.images.get(t);let n=t.replace(/\.(png|jpg|jpeg|bmp)$/,"");return this.images.has(n)?this.images.get(n):null}bmpNew(e,t){return this._reg(P(e,t))}bmpLoad(e){let t=this.findImage(e);if(!t)return-1;let n=P(t.width,t.height);return n.getContext("2d").drawImage(t,0,0),this._reg(n)}bmpClone(e){let t=this._b(e);if(!t)return this.bmpNew(1,1);let n=P(t.c.width,t.c.height);return n.getContext("2d").drawImage(t.c,0,0),this._reg(n)}bmpW(e){let t=this._b(e);return t?t.c.width:0}bmpH(e){let t=this._b(e);return t?t.c.height:0}bmpDispose(e){let t=this._b(e);t&&(t.c.width=0,t.c.height=0,this.bmps.delete(e))}bmpDisposeList(e){for(let t of String(e).split(","))t&&this.bmpDispose(+t)}_touch(e){e.ver++,e.at=null}bmpBlt(e,t,n,a,s,r,i,o,c){let d=this._b(e),_=this._b(a);!d||!_||i<=0||o<=0||c<=0||(d.x.globalAlpha=Math.min(1,c/255),e===a?(this._ensureTmp(i,o),this.tmpCtx.clearRect(0,0,i,o),this.tmpCtx.drawImage(_.c,s,r,i,o,0,0,i,o),d.x.drawImage(this.tmp,0,0,i,o,t,n,i,o)):d.x.drawImage(_.c,s,r,i,o,t,n,i,o),d.x.globalAlpha=1,this._touch(d))}bmpStretch(e,t,n,a,s,r,i,o,c,d,_){let f=this._b(e),h=this._b(r);!f||!h||c<=0||d<=0||a<=0||s<=0||_<=0||(f.x.globalAlpha=Math.min(1,_/255),f.x.imageSmoothingEnabled=!0,f.x.drawImage(h.c,i,o,c,d,t,n,a,s),f.x.imageSmoothingEnabled=!1,f.x.globalAlpha=1,this._touch(f))}bmpFill(e,t,n,a,s,r,i,o,c){let d=this._b(e);!d||a<=0||s<=0||(d.x.clearRect(t,n,a,s),c>0&&(d.x.fillStyle=`rgba(${r|0},${i|0},${o|0},${c/255})`,d.x.fillRect(t,n,a,s)),this._touch(d))}bmpClear(e){let t=this._b(e);t&&(t.x.clearRect(0,0,t.c.width,t.c.height),this._touch(t))}bmpGetPixel(e,t,n){let a=this._b(e);if(!a||t<0||n<0||t>=a.c.width||n>=a.c.height)return"0,0,0,0";let s=a.x.getImageData(t,n,1,1).data;return`${s[0]},${s[1]},${s[2]},${s[3]}`}bmpSetPixel(e,t,n,a,s,r,i){let o=this._b(e);if(!o)return;let c=o.x.createImageData(1,1);c.data[0]=a,c.data[1]=s,c.data[2]=r,c.data[3]=i,o.x.putImageData(c,t,n),this._touch(o)}bmpHue(e,t){let n=this._b(e);if(!n||!t)return;let a=n.c.width,s=n.c.height,r=n.x.getImageData(0,0,a,s),i=r.data,o=(t%360+360)%360;for(let c=0;c<i.length;c+=4){if(i[c+3]===0)continue;let d=i[c]/255,_=i[c+1]/255,f=i[c+2]/255,h=Math.max(d,_,f),p=Math.min(d,_,f),u=h,m=h-p;if(m===0)continue;let b=m/h,x;h===d?x=(_-f)/m%6:h===_?x=(f-d)/m+2:x=(d-_)/m+4,x=x*60+o,x=(x%360+360)%360;let S=u*b,N=S*(1-Math.abs(x/60%2-1)),T=u-S,O,A,C;x<60?[O,A,C]=[S,N,0]:x<120?[O,A,C]=[N,S,0]:x<180?[O,A,C]=[0,S,N]:x<240?[O,A,C]=[0,N,S]:x<300?[O,A,C]=[N,0,S]:[O,A,C]=[S,0,N],i[c]=(O+T)*255,i[c+1]=(A+T)*255,i[c+2]=(C+T)*255}n.x.putImageData(r,0,0),this._touch(n)}_font(e,t,n,a){return`${a?"italic ":""}${n?"bold ":""}${t}px ${Tt(e)}`}_isSong(e){let t=String(e||"").split(",")[0].trim().toLowerCase();return t===""||t==="\u5B8B\u4F53"||t==="simsun"||t==="\u65B0\u5B8B\u4F53"||t==="nsimsun"}_cellW(e,t){return e.codePointAt(0)<128?Math.round(t/2):t}textSize(e,t,n,a,s){if(e=String(e),this._isSong(t)){let i=0;for(let o of e)i+=this._cellW(o,n);return i}let r=this.measureCtx;return r.font=this._font(t,n,a,s),Math.ceil(r.measureText(e).width)}bmpText(e,t,n,a,s,r,i,o,c,d,_,f,h,p,u){let m=this._b(e);if(!m||(r=String(r),!r.length||u<=0))return;let b=m.x;b.font=this._font(o,c,d,_),b.fillStyle=`rgba(${f|0},${h|0},${p|0},${u/255})`,b.textBaseline="middle";let x=this._isSong(o),S=x?[...r]:null,N=x?S.reduce((W,G)=>W+this._cellW(G,c),0):b.measureText(r).width,T=1;a>0&&N>a&&(T=Math.max(.4,a/N));let O=N*T,A=t;i===1?A=t+(a-O)/2:i===2&&(A=t+a-O);let C=Math.round(n+s/2+1);if(b.save(),b.beginPath(),b.rect(t,n,Math.max(a,O),s),b.clip(),!x)T!==1?(b.translate(A,0),b.scale(T,1),b.fillText(r,0,C)):b.fillText(r,Math.round(A),C);else{b.translate(Math.round(A),0),T!==1&&b.scale(T,1);let W=0;for(let G of S){let M=this._cellW(G,c);if(G!==" "&&G!=="\u3000"){let De=b.measureText(G).width;De>M+.5?(b.save(),b.translate(W,0),b.scale(M/De,1),b.fillText(G,0,C),b.restore()):b.fillText(G,W+(M-De)/2,C)}W+=M}}b.restore(),this._touch(m)}_ensureTmp(e,t){(this.tmp.width<e||this.tmp.height<t)&&(this.tmp.width=Math.max(this.tmp.width,e),this.tmp.height=Math.max(this.tmp.height,t),this.tmpCtx.imageSmoothingEnabled=!1)}_ensureTmp2(e,t){(this.tmp2.width<e||this.tmp2.height<t)&&(this.tmp2.width=Math.max(this.tmp2.width,e),this.tmp2.height=Math.max(this.tmp2.height,t),this.tmp2Ctx.imageSmoothingEnabled=!1)}tmConfig(e,t,n,a,s,r,i,o){let c=this.tilemaps.get(e)||{};this._releaseTileCache(c),c.tileset=t,c.autotiles=String(n).split(",").map(Number),c.xs=a,c.ys=s,c.zs=r,c.data=i?Int16Array.from(String(i).split(","),Number):null,c.prio=o?Int16Array.from(String(o).split(","),Number):null,c.cache=new Map,this.tilemaps.set(e,c)}_releaseTileCache(e){if(!(!e||!e.cache)){for(let t of e.cache.values())t.width=0,t.height=0;e.cache.clear()}}tmDispose(e){this._releaseTileCache(this.tilemaps.get(e)),this.tilemaps.delete(e)}_tileCanvas(e,t,n){if(t>=384){let d=this._b(e.tileset);if(!d)return null;let _=t-384;return[d.c,_%8*32,(_/8|0)*32]}let a=(t/48|0)-1,s=this._b(e.autotiles[a]);if(!s||a<0)return null;let r=Math.max(1,s.c.width/96|0),i=s.c.height===32?0:n%r,o=t*8+i,c=e.cache.get(o);if(!c){c=P(32,32);let d=c.getContext("2d");if(s.c.height===32)d.drawImage(s.c,n%Math.max(1,s.c.width/32|0)*32,0,32,32,0,0,32,32);else{let _=t%48;for(let f=0;f<4;f++){let h=ft[(_*4+f)*2]+i*96,p=ft[(_*4+f)*2+1];d.drawImage(s.c,h,p,16,16,f%2*16,(f/2|0)*16,16,16)}}e.cache.set(o,c)}return[c,0,0]}_tilemapItems(e,t){let n=this.tilemaps.get(e[2]);if(!n||!n.data)return;let a=e[3],s=e[4],r=e[5],i=e[7],o=Math.floor(a/32),c=Math.floor(s/32),d=22,_=17,f=[],h=new Map,p=n.xs,u=n.ys,m=n.zs;for(let S=c;S<c+_;S++)if(!(S<0||S>=u)){for(let N=o;N<o+d;N++)if(!(N<0||N>=p))for(let T=0;T<m;T++){let O=n.data[N+S*p+T*p*u];if(O<48)continue;let A=n.prio&&O<n.prio.length?n.prio[O]:0,C=N*32-a,W=S*32-s;if(A===0)f.push(O,C,W);else{let G=32*(S+A+1)-s,M=h.get(G);M||(M=[],h.set(G,M)),M.push(O,C,W)}}}let b=this,x=S=>N=>{for(let T=0;T<S.length;T+=3){let O=b._tileCanvas(n,S[T],r);O&&N.drawImage(O[0],O[1],O[2],32,32,S[T+1],S[T+2],32,32)}};t.push({z:0,seq:i,draw:x(f)});for(let[S,N]of h)t.push({z:S,seq:i,draw:x(N)})}_compose(e,t){t.save(),t.setTransform(1,0,0,1,0,0),t.globalAlpha=1,t.globalCompositeOperation="source-over",t.fillStyle="#000",t.fillRect(0,0,ee,te);let n=new Map,a=[];for(let r of e)if(r[0]===0){let i={rec:r,z:r[6],seq:r[18],items:[],isVp:!0};n.set(r[1],i)}for(let r of n.values())r.rec[9]&&a.push(r);for(let r of e){let i=r[0];if(i===0)continue;let o=r[1],c=a;if(o){let d=n.get(o);if(!d||!d.rec[9])continue;c=d.items}i===1?c.push({z:r[5],seq:r[26],rec:r}):i===2?c.push({z:r[3],seq:r[18],rec:r}):i===3?c.push({z:r[6],seq:r[24],rec:r}):i===4&&this._tilemapItems(r,c)}let s=(r,i)=>r.z-i.z||r.seq-i.seq;a.sort(s);for(let r of a)r.isVp?this._drawViewport(t,r,s):this._drawItem(t,r,0,0,ee,te);t.restore()}_drawViewport(e,t,n){let a=t.rec,s=a[2],r=a[3],i=a[4],o=a[5];if(i<=0||o<=0)return;if(t.items.sort(n),!(a[13]>0||a[14]||a[15]||a[16]||a[17]>0)){e.save(),e.beginPath(),e.rect(s,r,i,o),e.clip(),e.translate(s-a[7],r-a[8]);for(let _ of t.items)this._drawItem(e,_,a[7],a[8],i,o);e.restore();return}let d=this.vpCtx;d.setTransform(1,0,0,1,0,0),d.globalAlpha=1,d.globalCompositeOperation="source-over",d.clearRect(0,0,ee,te),d.drawImage(e.canvas,s,r,i,o,0,0,i,o),d.save(),d.beginPath(),d.rect(0,0,i,o),d.clip(),d.translate(-a[7],-a[8]);for(let _ of t.items)this._drawItem(d,_,a[7],a[8],i,o);d.restore(),ut(d,0,0,i,o,a[14],a[15],a[16],a[17]),a[13]>0&&(d.globalCompositeOperation="source-atop",d.globalAlpha=a[13]/255,d.fillStyle=`rgb(${a[10]},${a[11]},${a[12]})`,d.fillRect(0,0,i,o),d.globalAlpha=1,d.globalCompositeOperation="source-over"),e.drawImage(this.vpCanvas,0,0,i,o,s,r,i,o)}_drawItem(e,t,n,a,s,r){if(t.draw){t.draw(e);return}let i=t.rec;switch(i[0]){case 1:this._drawSprite(e,i);break;case 2:this._drawPlane(e,i,n,a,s,r);break;case 3:this._drawWindow(e,i);break;default:break}}_blend(e,t){e.globalCompositeOperation=t===1?"lighter":t===2?"difference":"source-over"}_drawSprite(e,t){let n=this._b(t[2]);if(!n)return;let a=t[8],s=t[9],r=t[10],i=t[11];if(a<0&&(r+=a,a=0),s<0&&(i+=s,s=0),r=Math.min(r,n.c.width-a),i=Math.min(i,n.c.height-s),r<=0||i<=0)return;let o=n.c,c=a,d=s,_=t[22]>0,f=t[23]!==0||t[24]!==0||t[25]!==0||t[26]>0;if(_||f){this._ensureTmp2(r,i);let m=this.tmp2Ctx;m.setTransform(1,0,0,1,0,0),m.globalAlpha=1,m.globalCompositeOperation="copy",m.drawImage(n.c,a,s,r,i,0,0,r,i),m.globalCompositeOperation="source-over",f&&(ut(m,0,0,r,i,t[23],t[24],t[25],t[26]),m.globalCompositeOperation="destination-in",m.drawImage(n.c,a,s,r,i,0,0,r,i),m.globalCompositeOperation="source-over"),_&&(m.globalCompositeOperation="source-atop",m.globalAlpha=t[22]/255,m.fillStyle=`rgb(${t[19]},${t[20]},${t[21]})`,m.fillRect(0,0,r,i),m.globalAlpha=1,m.globalCompositeOperation="source-over"),o=this.tmp2,c=0,d=0}e.save(),e.translate(t[3],t[4]),t[14]&&e.rotate(-t[14]*Math.PI/180);let h=t[12]*(t[15]?-1:1),p=t[13];(h!==1||p!==1)&&e.scale(h,p),(h!==1&&h!==-1||p!==1)&&(e.imageSmoothingEnabled=!0),e.globalAlpha=Math.min(1,t[16]/255),this._blend(e,t[17]);let u=t[18];if(u>0&&u<i){let m=i-u;e.drawImage(o,c,d,r,m,-t[6],-t[7],r,m),e.globalAlpha=Math.min(1,t[16]/255)*.5,e.drawImage(o,c,d+m,r,u,-t[6],-t[7]+m,r,u)}else u>=i&&(e.globalAlpha=Math.min(1,t[16]/255)*.5),e.drawImage(o,c,d,r,i,-t[6],-t[7],r,i);e.restore()}_drawPlane(e,t,n,a,s,r){let i=this._b(t[2]);if(!i)return;let o=t[6]||1,c=t[7]||1,d=i.c.width*o,_=i.c.height*c;if(d<=0||_<=0)return;e.save(),e.globalAlpha=Math.min(1,t[8]/255),this._blend(e,t[9]);let f=-((t[4]%d+d)%d)+n,h=-((t[5]%_+_)%_)+a;for(let p=h;p<a+r;p+=_)for(let u=f;u<n+s;u+=d)e.drawImage(i.c,0,0,i.c.width,i.c.height,u,p,d,_);t[13]>0&&(e.globalCompositeOperation="source-atop"),e.restore()}_drawWindow(e,t){let n=t[4],a=t[5],s=t[7],r=t[8];if(s<=0||r<=0)return;let i=this._b(t[2]),o=t[11]/255;if(e.save(),e.translate(n,a),i&&o>0){let f=i.c,h=o*(t[12]/255);if(h>0&&s>4&&r>4)if(e.globalAlpha=h,t[21])e.imageSmoothingEnabled=!0,e.drawImage(f,0,0,128,128,2,2,s-4,r-4),e.imageSmoothingEnabled=!1;else{e.save(),e.beginPath(),e.rect(2,2,s-4,r-4),e.clip();for(let p=2;p<r-2;p+=128)for(let u=2;u<s-2;u+=128)e.drawImage(f,0,0,128,128,u,p,128,128);e.restore()}e.globalAlpha=o,e.save(),e.beginPath(),e.rect(16,0,Math.max(0,s-32),r),e.clip();for(let p=16;p<s-16;p+=32)e.drawImage(f,144,0,32,16,p,0,32,16),e.drawImage(f,144,48,32,16,p,r-16,32,16);e.restore(),e.save(),e.beginPath(),e.rect(0,16,s,Math.max(0,r-32)),e.clip();for(let p=16;p<r-16;p+=32)e.drawImage(f,128,16,16,32,0,p,16,32),e.drawImage(f,176,16,16,32,s-16,p,16,32);e.restore(),e.drawImage(f,128,0,16,16,0,0,16,16),e.drawImage(f,176,0,16,16,s-16,0,16,16),e.drawImage(f,128,48,16,16,0,r-16,16,16),e.drawImage(f,176,48,16,16,s-16,r-16,16,16)}let c=t[16],d=t[17];i&&t[18]>=0&&c>0&&d>0&&(e.save(),e.beginPath(),e.rect(16,16,s-32,r-32),e.clip(),e.globalAlpha=t[18]/255*(t[13]/255),It(e,i.c,16+t[14],16+t[15],c,d),e.restore());let _=this._b(t[3]);if(_&&t[13]>0&&(e.save(),e.beginPath(),e.rect(16,16,Math.max(0,s-32),Math.max(0,r-32)),e.clip(),e.globalAlpha=t[13]/255,e.drawImage(_.c,16-t[9],16-t[10]),e.restore()),i&&o>0&&t[23]){let f=i.c,h=t[23];e.globalAlpha=o;let p=(s-16)/2|0,u=(r-16)/2|0;h&1&&e.drawImage(f,144,24,8,16,4,u,8,16),h&2&&e.drawImage(f,168,24,8,16,s-12,u,8,16),h&4&&e.drawImage(f,152,16,16,8,p,4,16,8),h&8&&e.drawImage(f,152,40,16,8,p,r-12,16,8)}if(i&&t[19]>=0){let f=[[160,64],[176,64],[160,80],[176,80]][t[19]&3];e.globalAlpha=t[20]/255*o,e.drawImage(i.c,f[0],f[1],16,16,(s-16)/2|0,r-16,16,16)}e.restore()}frame(e,t){let n;try{n=JSON.parse(e)}catch(r){console.error("bad display list",r,e.slice(0,200)),n=this.lastList}this.lastList=n,this.frameCount++;let a=this.ctx;if(this.frozen&&!this.trans)a.drawImage(this.frozen,0,0);else if(this._compose(n,a),this.trans){let r=this.trans;r.i++;let i=Math.max(0,1-r.i/Math.max(1,r.d));i>0&&(a.globalAlpha=i,a.drawImage(this.frozen,0,0),a.globalAlpha=1)}let s=1e3/Math.max(1,t||40);return new Promise(r=>{let i=o=>{!this.lastFrameTime||o-this.lastFrameTime>=s-3||o<this.lastFrameTime?(this.lastFrameTime&&o-this.lastFrameTime>s*4?this.lastFrameTime=o:this.lastFrameTime=this.lastFrameTime?this.lastFrameTime+s:o,o-this.lastFrameTime>s&&(this.lastFrameTime=o),r(this.resetRequested?1:0)):requestAnimationFrame(i)};requestAnimationFrame(i)})}freeze(){this.frozenCanvas||(this.frozenCanvas=P(ee,te));let e=this.frozenCanvas.getContext("2d");e.globalAlpha=1,e.drawImage(this.canvas,0,0),this.frozen=this.frozenCanvas}transitionBegin(e){if(this.frozen){if(e<=0){this.frozen=null,this.trans=null;return}this.trans={d:e,i:0}}}transitionEnd(){this.frozen=null,this.trans=null}snapToBitmap(){let e=P(ee,te);return e.getContext("2d").drawImage(this.canvas,0,0),this._reg(e)}keys(){let e=new Set([...this.keysHeld,...this.touchHeld,...this.latched]);return this.latched.clear(),[...e].join(",")}dir4(){let e=new Set([...this.keysHeld,...this.touchHeld]);for(let t=this.dirOrder.length-1;t>=0;t--)if(e.has(this.dirOrder[t]))return this.dirOrder[t];return 0}pressCode(e,t,n){let a=n?this.touchHeld:this.keysHeld;t?(a.add(e),this.latched.add(e),(e===2||e===4||e===6||e===8)&&(this.dirOrder=this.dirOrder.filter(s=>s!==e),this.dirOrder.push(e))):a.delete(e)}clearInput(){this.keysHeld.clear(),this.touchHeld.clear(),this.latched.clear()}bgmPlay(e,t,n){this.audio.play("bgm",e,t,n)}bgmStop(){this.audio.stop("bgm")}bgmFade(e){this.audio.fade("bgm",e)}bgsPlay(e,t,n){this.audio.play("bgs",e,t,n)}bgsStop(){this.audio.stop("bgs")}bgsFade(e){this.audio.fade("bgs",e)}mePlay(e,t,n){this.audio.playME(e,t,n)}meStop(){this.audio.stopME()}meFade(e){this.audio.fadeME(e)}sePlay(e,t,n){this.audio.playSE(e,t,n)}seStop(){this.audio.stopSE()}persist(e){let t=this.fs.read(e);t&&this.storage.save(e,t)}unpersist(e){this.storage.remove(e)}msgbox(e){return this.ui.alert(String(e))}inputText(e,t,n){return this.ui.prompt(String(e),String(t),n|0)}log(e){console.log("[ruby]",String(e))}now(){return performance.now()}};function It(l,e,t,n,a,s){let c=Math.max(0,a-4),d=Math.max(0,s-4);l.imageSmoothingEnabled=!1,c>0&&d>0&&l.drawImage(e,130,66,28,28,t+2,n+2,c,d),l.drawImage(e,128,64,2,2,t,n,2,2),l.drawImage(e,158,64,2,2,t+a-2,n,2,2),l.drawImage(e,128,94,2,2,t,n+s-2,2,2),l.drawImage(e,158,94,2,2,t+a-2,n+s-2,2,2),c>0&&(l.drawImage(e,130,64,28,2,t+2,n,c,2),l.drawImage(e,130,94,28,2,t+2,n+s-2,c,2)),d>0&&(l.drawImage(e,128,66,2,28,t,n+2,2,d),l.drawImage(e,158,66,2,28,t+a-2,n+2,2,d))}function ut(l,e,t,n,a,s,r,i,o){if(!s&&!r&&!i&&!(o>0))return;l.save(),l.setTransform(1,0,0,1,0,0),l.globalAlpha=1;let c=m=>{l.globalCompositeOperation=m};o>0&&(c("saturation"),l.globalAlpha=Math.min(1,o/255),l.fillStyle="#808080",l.fillRect(e,t,n,a),l.globalAlpha=1);let d=Math.max(0,s),_=Math.max(0,r),f=Math.max(0,i);(d||_||f)&&(c("lighter"),l.fillStyle=`rgb(${d},${_},${f})`,l.fillRect(e,t,n,a));let h=Math.max(0,-s),p=Math.max(0,-r),u=Math.max(0,-i);(h||p||u)&&(c("difference"),l.fillStyle="#fff",l.fillRect(e,t,n,a),c("lighter"),l.fillStyle=`rgb(${h},${p},${u})`,l.fillRect(e,t,n,a),c("difference"),l.fillStyle="#fff",l.fillRect(e,t,n,a)),l.restore()}var Je=class{constructor(e){this.files=e,this.ctx=null,this.ch={bgm:null,bgs:null},this.me=null,this.seBuffers=new Map,this.seActive=new Set,this.master={bgm:1,se:1},this.bgmPausedForME=!1}unlock(){if(!this.ctx){let e=window.AudioContext||window.webkitAudioContext;e&&(this.ctx=new e)}this.ctx&&this.ctx.state==="suspended"&&this.ctx.resume();for(let e of["bgm","bgs"]){let t=this.ch[e];t&&t.el.paused&&t.wantPlay&&t.el.play().catch(()=>{})}}url(e){let t=String(e).replace(/\\/g,"/").toLowerCase().replace(/\.(mp3|ogg|wav|mid|midi|m4a)$/,"");return this.files.get(t)||null}setMaster(e,t){this.master[e]=t;for(let n of["bgm","bgs"])this._applyVol(this.ch[n],n==="bgm"?this.master.bgm:this.master.se);this.me&&this._applyVol(this.me,this.master.bgm)}_applyVol(e,t){e&&(e.el.volume=Math.max(0,Math.min(1,e.vol*t*(e.fadeMul??1))))}play(e,t,n,a){let s=this.url(t),r=this.ch[e];if(!s){this.stop(e);return}if(r&&r.url===s){r.vol=n/100,r.fadeMul=1,r.fadeTimer&&(clearInterval(r.fadeTimer),r.fadeTimer=null),r.el.playbackRate=a/100,this._applyVol(r,e==="bgm"?this.master.bgm:this.master.se),r.el.paused&&!(e==="bgm"&&this.me)&&r.el.play().catch(()=>{});return}this.stop(e);let i=new Audio(s);i.loop=!0,i.preservesPitch=!1,i.mozPreservesPitch=!1,i.webkitPreservesPitch=!1,i.playbackRate=a/100;let o={el:i,url:s,vol:n/100,fadeMul:1,wantPlay:!0};this.ch[e]=o,this._applyVol(o,e==="bgm"?this.master.bgm:this.master.se),e==="bgm"&&this.me||i.play().catch(()=>{})}stop(e){let t=this.ch[e];t&&(t.fadeTimer&&clearInterval(t.fadeTimer),t.el.pause(),t.el.src="",t.wantPlay=!1),this.ch[e]=null}_fadeEl(e,t,n){if(!e)return;e.fadeTimer&&clearInterval(e.fadeTimer);let a=Math.max(1,Math.round(t/50)),s=0;e.fadeTimer=setInterval(()=>{s++,e.fadeMul=Math.max(0,1-s/a),this._applyVol(e,this.master.bgm),s>=a&&(clearInterval(e.fadeTimer),e.fadeTimer=null,n())},50)}fade(e,t){let n=this.ch[e];this._fadeEl(n,t,()=>{this.ch[e]===n&&this.stop(e)})}playME(e,t,n){let a=this.url(e);if(this.stopME(),!a)return;let s=new Audio(a);s.preservesPitch=!1,s.playbackRate=n/100;let r={el:s,url:a,vol:t/100,fadeMul:1};this.me=r,this._applyVol(r,this.master.bgm);let i=this.ch.bgm;i&&i.el.pause(),s.onended=()=>{this.me===r&&(this.me=null);let o=this.ch.bgm;o&&o.wantPlay&&o.el.play().catch(()=>{})},s.play().catch(()=>{s.onended()})}stopME(){let e=this.me;e&&(e.el.onended=null,e.el.pause(),e.el.src=""),this.me=null;let t=this.ch.bgm;e&&t&&t.wantPlay&&t.el.play().catch(()=>{})}fadeME(e){let t=this.me;this._fadeEl(t,e,()=>{this.me===t&&this.stopME()})}async _seBuffer(e){if(this.seBuffers.has(e))return this.seBuffers.get(e);let t=fetch(e).then(n=>n.arrayBuffer()).then(n=>new Promise((a,s)=>this.ctx.decodeAudioData(n,a,s))).catch(()=>null);return this.seBuffers.set(e,t),t}playSE(e,t,n){let a=this.url(e);!a||!this.ctx||this._seBuffer(a).then(s=>{if(!s)return;let r=this.ctx.createBufferSource();r.buffer=s,r.playbackRate.value=n/100;let i=this.ctx.createGain();i.gain.value=Math.max(0,Math.min(1,t/100*this.master.se)),r.connect(i).connect(this.ctx.destination),this.seActive.add(r),r.onended=()=>this.seActive.delete(r),r.start()})}preloadSE(e){if(this.ctx)for(let t of e){let n=this.url(t);n&&this._seBuffer(n)}}stopSE(){for(let e of this.seActive)try{e.stop()}catch{}this.seActive.clear()}pauseAll(){for(let e of["bgm","bgs"]){let t=this.ch[e];t&&t.el.pause()}this.me&&this.me.el.pause(),this.ctx&&this.ctx.state==="running"&&this.ctx.suspend()}resumeAll(){if(this.ctx&&this.ctx.state==="suspended"&&this.ctx.resume(),this.me)this.me.el.play().catch(()=>{});else{let t=this.ch.bgm;t&&t.wantPlay&&t.el.play().catch(()=>{})}let e=this.ch.bgs;e&&e.wantPlay&&e.el.play().catch(()=>{})}};var pt=`# RGSS1 core classes for ruby.wasm. Rendering is delegated to JS (globalThis.RG).\r
require 'js'\r
\r
module RGWeb\r
  JSRG = JS.global[:RG]\r
  @elements = []          # live drawables (Sprite/Plane/Window/Tilemap/Viewport)\r
  @seq = 0\r
  @dispose_queue = []\r
  class << self\r
    attr_reader :elements\r
    def call(name, *args)\r
      JSRG.call(name, *args)\r
    end\r
    def next_seq\r
      @seq += 1\r
    end\r
    def register(o)\r
      @elements << o\r
    end\r
    def unregister(o)\r
      @elements.delete(o)\r
    end\r
    def queue_dispose(id)\r
      @dispose_queue << id\r
    end\r
    def flush_dispose\r
      return if @dispose_queue.empty?\r
      call(:bmpDisposeList, @dispose_queue.join(','))\r
      @dispose_queue.clear\r
    end\r
    def display_list\r
      out = []\r
      @elements.each do |e|\r
        r = e.__record\r
        out << r if r\r
      end\r
      '[' + out.join(',') + ']'\r
    end\r
    def await_js(name, *args)\r
      JSRG.call(name, *args).await\r
    end\r
    def num(v)\r
      v.to_i\r
    end\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Color\r
  attr_reader :red, :green, :blue, :alpha\r
  def initialize(r = 0, g = 0, b = 0, a = 255)\r
    set(r, g, b, a)\r
  end\r
  def set(r, g = 0, b = 0, a = 255)\r
    if r.is_a?(Color)\r
      c = r\r
      @red, @green, @blue, @alpha = c.red, c.green, c.blue, c.alpha\r
    else\r
      self.red = r; self.green = g; self.blue = b; self.alpha = a\r
    end\r
    self\r
  end\r
  def red=(v);   @red   = __c(v); end\r
  def green=(v); @green = __c(v); end\r
  def blue=(v);  @blue  = __c(v); end\r
  def alpha=(v); @alpha = __c(v); end\r
  def __c(v)\r
    v = v.to_f\r
    v < 0 ? 0.0 : (v > 255 ? 255.0 : v)\r
  end\r
  def ==(o)\r
    o.is_a?(Color) && @red == o.red && @green == o.green && @blue == o.blue && @alpha == o.alpha\r
  end\r
  def to_s\r
    format('(%f, %f, %f, %f)', @red, @green, @blue, @alpha)\r
  end\r
  alias inspect to_s\r
  def _dump(_d = 0)\r
    [@red, @green, @blue, @alpha].pack('E4')\r
  end\r
  def self._load(s)\r
    new(*s.unpack('E4'))\r
  end\r
  def __css\r
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@alpha.to_i}"\r
  end\r
end\r
\r
class Tone\r
  attr_reader :red, :green, :blue, :gray\r
  def initialize(r = 0, g = 0, b = 0, gray = 0)\r
    set(r, g, b, gray)\r
  end\r
  def set(r, g = 0, b = 0, gray = 0)\r
    if r.is_a?(Tone)\r
      t = r\r
      @red, @green, @blue, @gray = t.red, t.green, t.blue, t.gray\r
    else\r
      self.red = r; self.green = g; self.blue = b; self.gray = gray\r
    end\r
    self\r
  end\r
  def __c(v)\r
    v = v.to_f\r
    v < -255 ? -255.0 : (v > 255 ? 255.0 : v)\r
  end\r
  def red=(v);   @red   = __c(v); end\r
  def green=(v); @green = __c(v); end\r
  def blue=(v);  @blue  = __c(v); end\r
  def gray=(v)\r
    v = v.to_f\r
    @gray = v < 0 ? 0.0 : (v > 255 ? 255.0 : v)\r
  end\r
  def ==(o)\r
    o.is_a?(Tone) && @red == o.red && @green == o.green && @blue == o.blue && @gray == o.gray\r
  end\r
  def to_s\r
    format('(%f, %f, %f, %f)', @red, @green, @blue, @gray)\r
  end\r
  alias inspect to_s\r
  def _dump(_d = 0)\r
    [@red, @green, @blue, @gray].pack('E4')\r
  end\r
  def self._load(s)\r
    new(*s.unpack('E4'))\r
  end\r
  def __css\r
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@gray.to_i}"\r
  end\r
end\r
\r
class Rect\r
  attr_reader :x, :y, :width, :height\r
  def initialize(x = 0, y = 0, w = 0, h = 0)\r
    set(x, y, w, h)\r
  end\r
  def set(x, y = 0, w = 0, h = 0)\r
    if x.is_a?(Rect)\r
      r = x\r
      @x, @y, @width, @height = r.x, r.y, r.width, r.height\r
    else\r
      @x = x.to_i; @y = y.to_i; @width = w.to_i; @height = h.to_i\r
    end\r
    self\r
  end\r
  def x=(v); @x = v.to_i; end\r
  def y=(v); @y = v.to_i; end\r
  def width=(v); @width = v.to_i; end\r
  def height=(v); @height = v.to_i; end\r
  def empty\r
    @x = @y = @width = @height = 0\r
    self\r
  end\r
  def ==(o)\r
    o.is_a?(Rect) && @x == o.x && @y == o.y && @width == o.width && @height == o.height\r
  end\r
  def to_s\r
    "(#{@x}, #{@y}, #{@width}, #{@height})"\r
  end\r
  alias inspect to_s\r
  def _dump(_d = 0)\r
    [@x, @y, @width, @height].pack('l4')\r
  end\r
  def self._load(s)\r
    new(*s.unpack('l4'))\r
  end\r
end\r
\r
class Table\r
  attr_reader :xsize, :ysize, :zsize, :__ver, :__data\r
  def initialize(x, y = 0, z = 0)\r
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)\r
    @xsize = [x, 0].max\r
    @ysize = [y, 1].max\r
    @zsize = [z, 1].max\r
    @__data = Array.new(@xsize * @ysize * @zsize, 0)\r
    @__ver = 0\r
  end\r
  def [](x, y = 0, z = 0)\r
    return nil if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize\r
    @__data[x + (y + z * @ysize) * @xsize]\r
  end\r
  def []=(*args)\r
    v = args.pop\r
    x = args[0]; y = args[1] || 0; z = args[2] || 0\r
    return v if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize\r
    v = v.to_i\r
    v = ((v + 32768) & 0xFFFF) - 32768\r
    @__data[x + (y + z * @ysize) * @xsize] = v\r
    @__ver = (@__ver || 0) + 1\r
    v\r
  end\r
  def resize(x, y = 0, z = 0)\r
    old = @__data; ox = @xsize; oy = @ysize; oz = @zsize\r
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)\r
    @xsize = [x, 0].max; @ysize = [y, 1].max; @zsize = [z, 1].max\r
    @__data = Array.new(@xsize * @ysize * @zsize, 0)\r
    [oz, @zsize].min.times do |k|\r
      [oy, @ysize].min.times do |j|\r
        [ox, @xsize].min.times do |i|\r
          @__data[i + (j + k * @ysize) * @xsize] = old[i + (j + k * oy) * ox]\r
        end\r
      end\r
    end\r
    @__ver = (@__ver || 0) + 1\r
    self\r
  end\r
  def _dump(_d = 0)\r
    [@dim, @xsize, @ysize, @zsize, @__data.size].pack('l5') + @__data.pack('s*')\r
  end\r
  def self._load(s)\r
    dim, x, y, z, n = s.unpack('l5')\r
    t = allocate\r
    t.__init_load(dim, x, y, z, s[20, n * 2].unpack('s*'))\r
    t\r
  end\r
  def __init_load(dim, x, y, z, data)\r
    @dim = dim; @xsize = x; @ysize = y; @zsize = z; @__data = data; @__ver = 0\r
  end\r
  def __version\r
    @__ver || 0\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Font\r
  class << self\r
    attr_accessor :default_name, :default_size, :default_bold, :default_italic\r
    attr_writer :default_color\r
    def default_color\r
      @default_color ||= Color.new(255, 255, 255, 255)\r
    end\r
    def exist?(_name)\r
      true\r
    end\r
  end\r
  @default_name = ['\u5B8B\u4F53']\r
  @default_size = 22\r
  @default_bold = false\r
  @default_italic = false\r
  attr_accessor :name, :size, :bold, :italic\r
  attr_reader :color\r
  def initialize(name = Font.default_name, size = Font.default_size)\r
    @name = name.is_a?(Array) ? name.dup : name\r
    @size = size\r
    @bold = Font.default_bold\r
    @italic = Font.default_italic\r
    @color = Font.default_color.dup\r
  end\r
  def color=(c)\r
    @color = c.is_a?(Color) ? c : Color.new\r
  end\r
  def initialize_copy(o)\r
    super\r
    @color = o.color.dup\r
    @name = o.name.dup if o.name.respond_to?(:dup)\r
  end\r
  def __names\r
    n = @name\r
    n = n.join("\\u0001") if n.is_a?(Array)\r
    n.to_s\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Bitmap\r
  attr_reader :__id\r
  def self.__finalizer(id)\r
    proc { RGWeb.queue_dispose(id) }\r
  end\r
  def initialize(*args)\r
    if args.size == 1\r
      path = args[0].to_s\r
      id = RGWeb.call(:bmpLoad, path).to_i\r
      raise Errno::ENOENT, path if id < 0\r
      @__id = id\r
    else\r
      w = args[0].to_i; h = args[1].to_i\r
      raise ArgumentError, 'failed to create bitmap' if w <= 0 || h <= 0\r
      @__id = RGWeb.call(:bmpNew, w, h).to_i\r
    end\r
    __setup\r
  end\r
  def __setup\r
    @width = RGWeb.call(:bmpW, @__id).to_i\r
    @height = RGWeb.call(:bmpH, @__id).to_i\r
    @font = Font.new\r
    @disposed = false\r
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))\r
  end\r
  def initialize_copy(o)\r
    @__id = RGWeb.call(:bmpClone, o.__id).to_i\r
    @width = o.width; @height = o.height\r
    @font = o.font.dup\r
    @disposed = false\r
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))\r
  end\r
  def font\r
    @font\r
  end\r
  def font=(f)\r
    @font = f\r
  end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    ObjectSpace.undefine_finalizer(self)\r
    RGWeb.call(:bmpDispose, @__id)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def width\r
    @width\r
  end\r
  def height\r
    @height\r
  end\r
  def rect\r
    Rect.new(0, 0, @width, @height)\r
  end\r
  def blt(x, y, src, rect, opacity = 255)\r
    return if src.nil? || src.disposed?\r
    RGWeb.call(:bmpBlt, @__id, x.to_i, y.to_i, src.__id, rect.x, rect.y, rect.width, rect.height, opacity.to_i)\r
  end\r
  def stretch_blt(dest, src, srect, opacity = 255)\r
    return if src.nil? || src.disposed?\r
    RGWeb.call(:bmpStretch, @__id, dest.x, dest.y, dest.width, dest.height, src.__id, srect.x, srect.y, srect.width, srect.height, opacity.to_i)\r
  end\r
  def fill_rect(*a)\r
    if a[0].is_a?(Rect)\r
      r = a[0]; c = a[1]\r
      x, y, w, h = r.x, r.y, r.width, r.height\r
    else\r
      x, y, w, h, c = a\r
    end\r
    RGWeb.call(:bmpFill, @__id, x.to_i, y.to_i, w.to_i, h.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)\r
  end\r
  def clear\r
    RGWeb.call(:bmpClear, @__id)\r
  end\r
  def get_pixel(x, y)\r
    s = RGWeb.call(:bmpGetPixel, @__id, x.to_i, y.to_i).to_s\r
    Color.new(*s.split(',').map(&:to_i))\r
  end\r
  def set_pixel(x, y, c)\r
    RGWeb.call(:bmpSetPixel, @__id, x.to_i, y.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)\r
  end\r
  def hue_change(h)\r
    return if h.to_i % 360 == 0\r
    RGWeb.call(:bmpHue, @__id, h.to_i)\r
  end\r
  def draw_text(*a)\r
    if a[0].is_a?(Rect)\r
      r = a[0]\r
      x, y, w, h = r.x, r.y, r.width, r.height\r
      str = a[1]; align = a[2] || 0\r
    else\r
      x, y, w, h, str = a[0], a[1], a[2], a[3], a[4]\r
      align = a[5] || 0\r
    end\r
    str = str.to_s\r
    return if str.empty?\r
    str = RGWeb.utf8(str)\r
    f = @font\r
    c = f.color\r
    RGWeb.call(:bmpText, @__id, x.to_i, y.to_i, w.to_i, h.to_i, str, align.to_i, f.__names, f.size.to_i,\r
               f.bold ? true : false, f.italic ? true : false, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)\r
  end\r
  def text_size(str)\r
    str = RGWeb.utf8(str.to_s)\r
    f = @font\r
    w = RGWeb.call(:textSize, str, f.__names, f.size.to_i, f.bold ? true : false, f.italic ? true : false).to_i\r
    Rect.new(0, 0, w, f.size.to_i)\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Viewport\r
  attr_reader :rect, :color, :tone, :__seq\r
  attr_accessor :visible, :ox, :oy\r
  attr_reader :z\r
  @@ids = 0\r
  def initialize(*a)\r
    @rect = a[0].is_a?(Rect) ? a[0].dup : Rect.new(a[0] || 0, a[1] || 0, a[2] || 640, a[3] || 480)\r
    @@ids += 1\r
    @__vid = @@ids\r
    @visible = true\r
    @z = 0; @ox = 0; @oy = 0\r
    @color = Color.new(0, 0, 0, 0)\r
    @tone = Tone.new(0, 0, 0, 0)\r
    @flash_color = nil; @flash_count = 0; @flash_dur = 0\r
    @disposed = false\r
    @__seq = RGWeb.next_seq\r
    RGWeb.register(self)\r
  end\r
  def __vid\r
    @__vid\r
  end\r
  def z=(v); @z = v.to_i; end\r
  def rect=(r); @rect = r.dup; end\r
  def color=(c); @color = c; end\r
  def tone=(t); @tone = t; end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    RGWeb.unregister(self)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def flash(color, duration)\r
    @flash_color = color; @flash_dur = duration; @flash_count = duration\r
  end\r
  def update\r
    @flash_count -= 1 if @flash_count > 0\r
  end\r
  def __record\r
    c = @color\r
    if @flash_count > 0 && @flash_color\r
      a = @flash_color.alpha * @flash_count / @flash_dur\r
      c = Color.new(@flash_color.red, @flash_color.green, @flash_color.blue, [a, c.alpha].max) if a > c.alpha\r
    end\r
    "[0,#{@__vid},#{@rect.x},#{@rect.y},#{@rect.width},#{@rect.height},#{@z},#{@ox.to_i},#{@oy.to_i},#{@visible ? 1 : 0},#{c.__css},#{@tone.__css},#{@__seq}]"\r
  end\r
end\r
\r
module RGWeb\r
  module ViewportChild\r
    def __vpid\r
      v = @viewport\r
      v && !v.disposed? ? v.__vid : 0\r
    end\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Sprite\r
  include RGWeb::ViewportChild\r
  attr_reader :viewport, :bitmap, :src_rect, :color, :tone, :z\r
  attr_accessor :visible, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :angle, :mirror, :bush_depth, :blend_type\r
  attr_reader :opacity\r
  def initialize(viewport = nil)\r
    @viewport = viewport\r
    @bitmap = nil\r
    @src_rect = Rect.new(0, 0, 0, 0)\r
    @visible = true\r
    @x = @y = @z = @ox = @oy = 0\r
    @zoom_x = @zoom_y = 1.0\r
    @angle = 0\r
    @mirror = false\r
    @bush_depth = 0\r
    @opacity = 255\r
    @blend_type = 0\r
    @color = Color.new(0, 0, 0, 0)\r
    @tone = Tone.new(0, 0, 0, 0)\r
    @flash_color = nil; @flash_count = 0; @flash_dur = 0\r
    @disposed = false\r
    @__seq = RGWeb.next_seq\r
    RGWeb.register(self)\r
  end\r
  def bitmap=(b)\r
    @bitmap = b\r
    @src_rect.set(0, 0, b.width, b.height) if b && !b.disposed?\r
  end\r
  def src_rect=(r); @src_rect = r; end\r
  def color=(c); @color = c; end\r
  def tone=(t); @tone = t; end\r
  def z=(v); @z = v.to_i; end\r
  def opacity=(v)\r
    v = v.to_i\r
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)\r
  end\r
  def viewport=(v); @viewport = v; end\r
  def width\r
    @src_rect.width\r
  end\r
  def height\r
    @src_rect.height\r
  end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    RGWeb.unregister(self)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def flash(color, duration)\r
    @flash_color = color; @flash_dur = duration; @flash_count = duration\r
  end\r
  def update\r
    @flash_count -= 1 if @flash_count > 0\r
  end\r
  def __record\r
    return nil unless @visible\r
    b = @bitmap\r
    return nil if b.nil? || b.disposed?\r
    return nil if @opacity <= 0\r
    c = @color\r
    if @flash_count > 0\r
      return nil if @flash_color.nil?\r
      a = @flash_color.alpha * @flash_count / @flash_dur\r
      c = @flash_color.dup.tap { |cc| cc.alpha = a } if a > c.alpha\r
    end\r
    sr = @src_rect\r
    "[1,#{__vpid},#{b.__id},#{@x.to_i},#{@y.to_i},#{@z},#{@ox.to_i},#{@oy.to_i},#{sr.x},#{sr.y},#{sr.width},#{sr.height},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@angle.to_f},#{@mirror ? 1 : 0},#{@opacity},#{@blend_type.to_i},#{@bush_depth.to_i},#{c.__css},#{@tone.__css},#{@__seq}]"\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Plane\r
  include RGWeb::ViewportChild\r
  attr_reader :viewport, :bitmap, :color, :tone, :z, :opacity\r
  attr_accessor :visible, :ox, :oy, :zoom_x, :zoom_y, :blend_type\r
  def initialize(viewport = nil)\r
    @viewport = viewport\r
    @bitmap = nil\r
    @visible = true\r
    @z = @ox = @oy = 0\r
    @zoom_x = @zoom_y = 1.0\r
    @opacity = 255\r
    @blend_type = 0\r
    @color = Color.new(0, 0, 0, 0)\r
    @tone = Tone.new(0, 0, 0, 0)\r
    @disposed = false\r
    @__seq = RGWeb.next_seq\r
    RGWeb.register(self)\r
  end\r
  def bitmap=(b); @bitmap = b; end\r
  def color=(c); @color = c; end\r
  def tone=(t); @tone = t; end\r
  def z=(v); @z = v.to_i; end\r
  def opacity=(v)\r
    v = v.to_i\r
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)\r
  end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    RGWeb.unregister(self)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def __record\r
    return nil unless @visible\r
    b = @bitmap\r
    return nil if b.nil? || b.disposed? || @opacity <= 0\r
    "[2,#{__vpid},#{b.__id},#{@z},#{@ox.to_i},#{@oy.to_i},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@opacity},#{@blend_type.to_i},#{@color.__css},#{@tone.__css},#{@__seq}]"\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Window\r
  include RGWeb::ViewportChild\r
  attr_reader :viewport, :windowskin, :contents, :cursor_rect, :z\r
  attr_reader :x, :y, :width, :height, :opacity, :back_opacity, :contents_opacity\r
  attr_accessor :stretch, :active, :visible, :pause, :ox, :oy\r
  def initialize(viewport = nil)\r
    @viewport = viewport\r
    @windowskin = nil\r
    @contents = nil\r
    @stretch = true\r
    @cursor_rect = Rect.new(0, 0, 0, 0)\r
    @active = true\r
    @visible = true\r
    @pause = false\r
    @x = @y = @width = @height = @z = @ox = @oy = 0\r
    @opacity = 255; @back_opacity = 255; @contents_opacity = 255\r
    @cursor_count = 0\r
    @pause_count = 0\r
    @disposed = false\r
    @__seq = RGWeb.next_seq\r
    RGWeb.register(self)\r
  end\r
  def windowskin=(b); @windowskin = b; end\r
  def contents=(b); @contents = b; end\r
  def cursor_rect=(r); @cursor_rect = r; end\r
  def x=(v); @x = v.to_i; end\r
  def y=(v); @y = v.to_i; end\r
  def width=(v); @width = v.to_i; end\r
  def height=(v); @height = v.to_i; end\r
  def z=(v); @z = v.to_i; end\r
  def opacity=(v); @opacity = [[v.to_i, 0].max, 255].min; end\r
  def back_opacity=(v); @back_opacity = [[v.to_i, 0].max, 255].min; end\r
  def contents_opacity=(v); @contents_opacity = [[v.to_i, 0].max, 255].min; end\r
  def pause=(v)\r
    @pause_count = 0 if v && !@pause\r
    @pause = v\r
  end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    @contents.dispose if false\r
    RGWeb.unregister(self)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def update\r
    @cursor_count = (@cursor_count + 1) % 32 if @active\r
    @pause_count += 1 if @pause\r
  end\r
  def __record\r
    return nil unless @visible\r
    return nil if @width <= 0 || @height <= 0\r
    sk = @windowskin && !@windowskin.disposed? ? @windowskin.__id : 0\r
    ct = @contents && !@contents.disposed? ? @contents.__id : 0\r
    cr = @cursor_rect\r
    ca = -1\r
    if cr.width > 0 && cr.height > 0\r
      if @active\r
        i = @cursor_count\r
        ca = i < 16 ? 255 - i * 8 : 127 + (i - 16) * 8\r
      else\r
        ca = 255\r
      end\r
    end\r
    pf = -1; pa = 0\r
    if @pause\r
      pf = (@pause_count / 8) % 4\r
      pa = [@pause_count * 32, 255].min\r
    end\r
    arrows = 0\r
    if ct != 0\r
      cw = @contents.width; chh = @contents.height\r
      arrows |= 1 if @ox > 0\r
      arrows |= 2 if cw - @ox > @width - 32\r
      arrows |= 4 if @oy > 0\r
      arrows |= 8 if chh - @oy > @height - 32\r
    end\r
    "[3,#{__vpid},#{sk},#{ct},#{@x},#{@y},#{@z},#{@width},#{@height},#{@ox.to_i},#{@oy.to_i},#{@opacity},#{@back_opacity},#{@contents_opacity},#{cr.x},#{cr.y},#{cr.width},#{cr.height},#{ca},#{pf},#{pa},#{@stretch ? 1 : 0},#{@active ? 1 : 0},#{arrows},#{@__seq}]"\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
class Tilemap\r
  include RGWeb::ViewportChild\r
  class AutotileArray\r
    def initialize(tm)\r
      @tm = tm\r
      @a = Array.new(7)\r
    end\r
    def [](i)\r
      @a[i]\r
    end\r
    def []=(i, b)\r
      @a[i] = b\r
      @tm.__dirty!\r
    end\r
    def __ids\r
      @a.map { |b| b && !b.disposed? ? b.__id : 0 }.join(',')\r
    end\r
  end\r
  @@ids = 0\r
  attr_reader :viewport, :tileset, :autotiles, :map_data, :flash_data, :priorities\r
  attr_accessor :visible, :ox, :oy\r
  def initialize(viewport = nil)\r
    @viewport = viewport\r
    @@ids += 1\r
    @__tid = @@ids\r
    @autotiles = AutotileArray.new(self)\r
    @tileset = nil; @map_data = nil; @flash_data = nil; @priorities = nil\r
    @visible = true\r
    @ox = @oy = 0\r
    @ani = 0\r
    @dirty = true\r
    @sent_ver = nil\r
    @disposed = false\r
    @__seq = RGWeb.next_seq\r
    RGWeb.register(self)\r
  end\r
  def __dirty!\r
    @dirty = true\r
  end\r
  def tileset=(b); @tileset = b; @dirty = true; end\r
  def map_data=(t); @map_data = t; @dirty = true; end\r
  def priorities=(t); @priorities = t; @dirty = true; end\r
  def flash_data=(t); @flash_data = t; end\r
  def dispose\r
    return if @disposed\r
    @disposed = true\r
    RGWeb.unregister(self)\r
    RGWeb.call(:tmDispose, @__tid)\r
  end\r
  def disposed?\r
    @disposed\r
  end\r
  def update\r
    @ani += 1\r
  end\r
  def __record\r
    return nil unless @visible\r
    return nil if @map_data.nil?\r
    ver = [@map_data.__version, @priorities ? @priorities.__version : 0]\r
    if @dirty || ver != @sent_ver\r
      md = @map_data\r
      RGWeb.call(:tmConfig, @__tid, @tileset && !@tileset.disposed? ? @tileset.__id : 0, @autotiles.__ids,\r
                 md.xsize, md.ysize, md.zsize, md.__data.join(','), @priorities ? @priorities.__data.join(',') : '')\r
      @dirty = false\r
      @sent_ver = ver\r
    end\r
    "[4,#{__vpid},#{@__tid},#{@ox.to_i},#{@oy.to_i},#{(@ani / 16) % 4},1,#{@__seq}]"\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
module Graphics\r
  @frame_rate = 40\r
  @frame_count = 0\r
  class << self\r
    attr_accessor :frame_count\r
    attr_reader :frame_rate\r
    def frame_rate=(v)\r
      @frame_rate = [[v.to_i, 10].max, 120].min\r
    end\r
    def update\r
      RGWeb.flush_dispose\r
      r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)\r
      @frame_count += 1\r
      RGWeb.after_frame(r)\r
      nil\r
    end\r
    def freeze\r
      RGWeb.call(:freeze)\r
      nil\r
    end\r
    def transition(duration = 8, _filename = '', _vague = 40)\r
      duration = duration.to_i\r
      RGWeb.call(:transitionBegin, duration)\r
      if duration > 0\r
        duration.times do\r
          RGWeb.flush_dispose\r
          r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)\r
          @frame_count += 1\r
          RGWeb.after_frame(r)\r
        end\r
      end\r
      RGWeb.call(:transitionEnd)\r
      nil\r
    end\r
    def frame_reset\r
      nil\r
    end\r
    def width\r
      640\r
    end\r
    def height\r
      480\r
    end\r
    def snap_to_bitmap\r
      b = Bitmap.allocate\r
      b.instance_variable_set(:@__id, RGWeb.call(:snapToBitmap).to_i)\r
      b.__setup\r
      b\r
    end\r
  end\r
end\r
\r
module RGWeb\r
  def self.after_frame(r)\r
    return if r.to_i == 0\r
    # reset requested from web UI\r
    raise Reset if defined?(Reset) && Reset.is_a?(Class)\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
module Input\r
  DOWN = 2; LEFT = 4; RIGHT = 6; UP = 8\r
  A = 11; B = 12; C = 13; X = 14; Y = 15; Z = 16; L = 17; R = 18\r
  SHIFT = 21; CTRL = 22; ALT = 23\r
  F5 = 25; F6 = 26; F7 = 27; F8 = 28; F9 = 29\r
  @cnt = Array.new(32, 0)\r
  @dir4 = 0\r
  class << self\r
    def update\r
      s = RGWeb.call(:keys).to_s\r
      held = s.empty? ? [] : s.split(',').map(&:to_i)\r
      32.times do |k|\r
        @cnt[k] = held.include?(k) ? @cnt[k] + 1 : 0\r
      end\r
      @dir4 = held.empty? ? 0 : RGWeb.call(:dir4).to_i\r
      nil\r
    end\r
    def press?(k)\r
      k = k.to_i\r
      k >= 0 && k < 32 && @cnt[k] > 0\r
    end\r
    def trigger?(k)\r
      k = k.to_i\r
      k >= 0 && k < 32 && @cnt[k] == 1\r
    end\r
    def repeat?(k)\r
      k = k.to_i\r
      return false unless k >= 0 && k < 32\r
      c = @cnt[k]\r
      c == 1 || (c > 15 && (c - 16) % 4 == 0)\r
    end\r
    def dir4\r
      return @dir4 if @dir4 != 0 && @cnt[@dir4] > 0\r
      [2, 4, 6, 8].each { |d| return d if @cnt[d] > 0 }\r
      0\r
    end\r
    def dir8\r
      d = @cnt\r
      up = d[8] > 0; down = d[2] > 0; left = d[4] > 0; right = d[6] > 0\r
      if up && left then 7\r
      elsif up && right then 9\r
      elsif down && left then 1\r
      elsif down && right then 3\r
      else dir4\r
      end\r
    end\r
  end\r
end\r
\r
# ---------------------------------------------------------------------------\r
module Audio\r
  class << self\r
    def __n(name)\r
      RGWeb.utf8(name.to_s)\r
    end\r
    def bgm_play(name, volume = 100, pitch = 100)\r
      RGWeb.call(:bgmPlay, __n(name), volume.to_i, pitch.to_i)\r
    end\r
    def bgm_stop; RGWeb.call(:bgmStop); end\r
    def bgm_fade(ms); RGWeb.call(:bgmFade, ms.to_i); end\r
    def bgs_play(name, volume = 80, pitch = 100)\r
      RGWeb.call(:bgsPlay, __n(name), volume.to_i, pitch.to_i)\r
    end\r
    def bgs_stop; RGWeb.call(:bgsStop); end\r
    def bgs_fade(ms); RGWeb.call(:bgsFade, ms.to_i); end\r
    def me_play(name, volume = 100, pitch = 100)\r
      RGWeb.call(:mePlay, __n(name), volume.to_i, pitch.to_i)\r
    end\r
    def me_stop; RGWeb.call(:meStop); end\r
    def me_fade(ms); RGWeb.call(:meFade, ms.to_i); end\r
    def se_play(name, volume = 80, pitch = 100)\r
      RGWeb.call(:sePlay, __n(name), volume.to_i, pitch.to_i)\r
    end\r
    def se_stop; RGWeb.call(:seStop); end\r
  end\r
end\r
`;var ht=`# Ruby 1.8 / RGSS1 kernel compatibility for ruby.wasm (Ruby 3.4)\r
require "zlib"\r
module RGWeb\r
  class << self\r
    def utf8(s)\r
      return s.to_s unless s.is_a?(String)\r
      return s if s.encoding == Encoding::UTF_8 && s.valid_encoding?\r
      t = s.dup.force_encoding('UTF-8')\r
      t.valid_encoding? ? t : t.scrub('?')\r
    end\r
    # 1.8 Marshal data has no encoding info: mark every String as UTF-8.\r
    def fix_enc(o, seen = {})\r
      case o\r
      when String\r
        o.force_encoding('UTF-8') unless o.frozen? || o.encoding == Encoding::UTF_8\r
        o\r
      when Array\r
        return o if seen[o.object_id]\r
        seen[o.object_id] = true\r
        o.each_with_index do |e, i|\r
          if e.is_a?(String) && e.frozen? && e.encoding != Encoding::UTF_8\r
            o[i] = e.dup.force_encoding('UTF-8')\r
          else\r
            fix_enc(e, seen)\r
          end\r
        end\r
        o\r
      when Hash\r
        return o if seen[o.object_id]\r
        seen[o.object_id] = true\r
        if o.keys.any? { |k| k.is_a?(String) && k.encoding != Encoding::UTF_8 }\r
          pairs = o.to_a\r
          o.clear\r
          pairs.each { |k, v| o[k.is_a?(String) ? k.dup.force_encoding('UTF-8') : k] = fix_enc(v, seen) }\r
        else\r
          o.each_value { |v| fix_enc(v, seen) }\r
        end\r
        o\r
      when Numeric, NilClass, TrueClass, FalseClass, Symbol, Table, Color, Tone, Rect, Bitmap, Class, Module\r
        o\r
      else\r
        return o if seen[o.object_id]\r
        seen[o.object_id] = true\r
        o.instance_variables.each do |iv|\r
          v = o.instance_variable_get(iv)\r
          if v.is_a?(String) && v.frozen? && v.encoding != Encoding::UTF_8\r
            o.instance_variable_set(iv, v.dup.force_encoding('UTF-8'))\r
          else\r
            fix_enc(v, seen)\r
          end\r
        end\r
        o\r
      end\r
    end\r
    # byte-based slicing (Ruby 1.8 String#slice semantics) that never splits a UTF-8 char\r
    def bslice(s, start, len)\r
      s = utf8(s)\r
      out = +''\r
      pos = 0\r
      s.each_char do |ch|\r
        b = ch.bytesize\r
        if pos >= start && pos + b <= start + len\r
          out << ch\r
        end\r
        pos += b\r
        break if pos >= start + len\r
      end\r
      out\r
    end\r
    def msgbox(text)\r
      await_js(:msgbox, utf8(text.to_s))\r
      nil\r
    end\r
  end\r
end\r
\r
module Kernel\r
  def load_data(fn)\r
    fn = RGWeb.utf8(fn.to_s)\r
    data = File.open(fn, 'rb') { |f| f.read }\r
    obj = RGWeb.fix_enc(Marshal.load(data))\r
    RGWeb.patch_common_events(obj) if fn =~ /CommonEvents\\.rxdata\\z/i\r
    obj\r
  end\r
  def save_data(obj, fn)\r
    File.open(RGWeb.utf8(fn.to_s), 'wb') { |f| Marshal.dump(obj, f) }\r
    nil\r
  end\r
  # RGSS: p / print show a message box\r
  def p(*args)\r
    return nil if args.empty?\r
    RGWeb.msgbox(args.map { |a| a.is_a?(String) ? RGWeb.utf8(a) : a.inspect }.join("\\n"))\r
    args.size == 1 ? args[0] : args\r
  end\r
  def print(*args)\r
    RGWeb.msgbox(args.map { |a| RGWeb.utf8(a.to_s) }.join)\r
    nil\r
  end\r
  alias_method :__rg_rand, :rand\r
  # Ruby 1.8: rand(x) uses x.to_i.abs, rand(0)/rand(nil) -> float\r
  def rand(max = 0)\r
    n = max.is_a?(Range) ? nil : max.to_i.abs\r
    return __rg_rand(max) if n.nil?\r
    n == 0 ? __rg_rand : __rg_rand(n)\r
  end\r
  module_function :rand, :load_data, :save_data\r
  public :rand, :load_data, :save_data, :p, :print\r
end\r
\r
class Array\r
  # Ruby 1.8: Array#to_s == join\r
  def to_s\r
    join\r
  end\r
end\r
\r
class Hash\r
  def index(v)\r
    key(v)\r
  end unless method_defined?(:index)\r
end\r
\r
class Object\r
  # Ruby 1.8 Object#type\r
  def type\r
    self.class\r
  end unless method_defined?(:type)\r
end\r
\r
class Integer\r
  def to_sym_18\r
    self\r
  end\r
end\r
\r
class Win32API\r
  def initialize(dll, func, *_args)\r
    @dll = dll.to_s\r
    @func = func.to_s\r
  end\r
  def call(*_args)\r
    0\r
  end\r
  alias Call call\r
end\r
\r
# ---------------------------------------------------------------------------\r
# Persist written files (save games) to browser storage\r
class File\r
  class << self\r
    alias_method :__rg_open, :open\r
    def open(name, mode = 'r', *rest, &blk)\r
      name = RGWeb.utf8(name.to_s)\r
      f = __rg_open(name, mode, *rest)\r
      f.__rg_mark_write(name) if mode.is_a?(String) && mode =~ /[wa+]/\r
      return f unless blk\r
      begin\r
        blk.call(f)\r
      ensure\r
        f.close unless f.closed?\r
      end\r
    end\r
    alias_method :__rg_delete, :delete\r
    def delete(*names)\r
      r = __rg_delete(*names)\r
      names.each { |n| RGWeb.call(:unpersist, RGWeb.utf8(n.to_s)) }\r
      r\r
    end\r
    alias unlink delete\r
  end\r
  def __rg_mark_write(n)\r
    @__rg_wpath = n\r
  end\r
  alias_method :__rg_close, :close\r
  def close\r
    r = __rg_close\r
    if @__rg_wpath && @__rg_wpath !~ /errors\\.txt\\z/\r
      RGWeb.call(:persist, @__rg_wpath)\r
    end\r
    r\r
  end\r
end\r
\r
$DEBUG = false\r
$BTEST = false\r
\r
module RGWeb\r
  # \u516C\u5171\u4E8B\u4EF6 4\u300C\u98DF\u7269\u996E\u6C34\u300D\uFF08\u5E76\u884C\uFF09\u91CC\u7684\u6570\u503C\u6821\u9A8C\uFF1A\u7ECF\u9A8C CRC\uFF08\u53D8\u91CF 152\uFF09\u6216\u6F5C\u80FD\u6821\u9A8C\uFF08\u53D8\u91CF 153\uFF09\r
  # \u5BF9\u4E0D\u4E0A\u65F6\u6E05\u96F6\u53D8\u91CF 19..89 \u5E76\u5F3A\u5236\u5B58\u6863\u3002\u672C\u9879\u76EE\u81EA\u7528\uFF0C\u6309\u9700\u6C42\u5173\u95ED\uFF1A\u628A\u8BE5\u6761\u4EF6\u5206\u6B67\u6539\u4E3A\u6052\u5047\u3002\r
  def self.patch_common_events(ces)\r
    n = 0\r
    ces.each do |ce|\r
      next unless ce && ce.list\r
      ce.list.each do |c|\r
        next unless c.code == 111 && c.parameters[0] == 12 && c.parameters[1].is_a?(String)\r
        if c.parameters[1].include?('$game_variables[152]')\r
          c.parameters[1] = 'false'\r
          n += 1\r
        end\r
      end\r
    end\r
    n\r
  end\r
end\r
`;var mt=`module RPG\r
  module Cache\r
    @cache = {}\r
    def self.load_bitmap(folder_name, filename, hue = 0)\r
      path = folder_name + filename\r
      if not @cache.include?(path) or @cache[path].disposed?\r
        if filename != ""\r
          @cache[path] = Bitmap.new(path)\r
        else\r
          @cache[path] = Bitmap.new(32, 32)\r
        end\r
      end\r
      if hue == 0\r
        @cache[path]\r
      else\r
        key = [path, hue]\r
        if not @cache.include?(key) or @cache[key].disposed?\r
          @cache[key] = @cache[path].clone\r
          @cache[key].hue_change(hue)\r
        end\r
        @cache[key]\r
      end\r
    end\r
    def self.animation(filename, hue)\r
      self.load_bitmap("Graphics/Animations/", filename, hue)\r
    end\r
    def self.autotile(filename)\r
      self.load_bitmap("Graphics/Autotiles/", filename)\r
    end\r
    def self.battleback(filename)\r
      self.load_bitmap("Graphics/Battlebacks/", filename)\r
    end\r
    def self.battler(filename, hue)\r
      self.load_bitmap("Graphics/Battlers/", filename, hue)\r
    end\r
    def self.character(filename, hue)\r
      self.load_bitmap("Graphics/Characters/", filename, hue)\r
    end\r
    def self.fog(filename, hue)\r
      self.load_bitmap("Graphics/Fogs/", filename, hue)\r
    end\r
    def self.gameover(filename)\r
      self.load_bitmap("Graphics/Gameovers/", filename)\r
    end\r
    def self.icon(filename)\r
      self.load_bitmap("Graphics/Icons/", filename)\r
    end\r
    def self.panorama(filename, hue)\r
      self.load_bitmap("Graphics/Panoramas/", filename, hue)\r
    end\r
    def self.picture(filename)\r
      self.load_bitmap("Graphics/Pictures/", filename)\r
    end\r
    def self.tileset(filename)\r
      self.load_bitmap("Graphics/Tilesets/", filename)\r
    end\r
    def self.title(filename)\r
      self.load_bitmap("Graphics/Titles/", filename)\r
    end\r
    def self.windowskin(filename)\r
      self.load_bitmap("Graphics/Windowskins/", filename)\r
    end\r
    def self.tile(filename, tile_id, hue)\r
      key = [filename, tile_id, hue]\r
      if not @cache.include?(key) or @cache[key].disposed?\r
        @cache[key] = Bitmap.new(32, 32)\r
        x = (tile_id - 384) % 8 * 32\r
        y = (tile_id - 384) / 8 * 32\r
        rect = Rect.new(x, y, 32, 32)\r
        @cache[key].blt(0, 0, self.tileset(filename), rect)\r
        @cache[key].hue_change(hue)\r
      end\r
      @cache[key]\r
    end\r
    def self.clear\r
      @cache = {}\r
      GC.start\r
    end\r
  end\r
\r
  class Sprite < ::Sprite\r
    @@_animations = []\r
    @@_reference_count = {}\r
    def initialize(viewport = nil)\r
      super(viewport)\r
      @_whiten_duration = 0\r
      @_appear_duration = 0\r
      @_escape_duration = 0\r
      @_collapse_duration = 0\r
      @_damage_duration = 0\r
      @_animation_duration = 0\r
      @_blink = false\r
    end\r
    def dispose\r
      dispose_damage\r
      dispose_animation\r
      dispose_loop_animation\r
      super\r
    end\r
    def whiten\r
      self.blend_type = 0\r
      self.color.set(255, 255, 255, 128)\r
      self.opacity = 255\r
      @_whiten_duration = 16\r
      @_appear_duration = 0\r
      @_escape_duration = 0\r
      @_collapse_duration = 0\r
    end\r
    def appear\r
      self.blend_type = 0\r
      self.color.set(0, 0, 0, 0)\r
      self.opacity = 0\r
      @_appear_duration = 16\r
      @_whiten_duration = 0\r
      @_escape_duration = 0\r
      @_collapse_duration = 0\r
    end\r
    def escape\r
      self.blend_type = 0\r
      self.color.set(0, 0, 0, 0)\r
      self.opacity = 255\r
      @_escape_duration = 32\r
      @_whiten_duration = 0\r
      @_appear_duration = 0\r
      @_collapse_duration = 0\r
    end\r
    def collapse\r
      self.blend_type = 1\r
      self.color.set(255, 64, 64, 255)\r
      self.opacity = 255\r
      @_collapse_duration = 48\r
      @_whiten_duration = 0\r
      @_appear_duration = 0\r
      @_escape_duration = 0\r
    end\r
    def damage(value, critical)\r
      dispose_damage\r
      if value.is_a?(Numeric)\r
        damage_string = value.abs.to_s\r
      else\r
        damage_string = value.to_s\r
      end\r
      bitmap = Bitmap.new(160, 48)\r
      bitmap.font.name = "Arial Black"\r
      bitmap.font.size = 32\r
      bitmap.font.color.set(0, 0, 0)\r
      bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)\r
      bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)\r
      bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)\r
      bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)\r
      if value.is_a?(Numeric) and value < 0\r
        bitmap.font.color.set(176, 255, 144)\r
      else\r
        bitmap.font.color.set(255, 255, 255)\r
      end\r
      bitmap.draw_text(0, 12, 160, 36, damage_string, 1)\r
      if critical\r
        bitmap.font.size = 20\r
        bitmap.font.color.set(0, 0, 0)\r
        bitmap.draw_text(-1, -1, 160, 20, "CRITICAL", 1)\r
        bitmap.draw_text(+1, -1, 160, 20, "CRITICAL", 1)\r
        bitmap.draw_text(-1, +1, 160, 20, "CRITICAL", 1)\r
        bitmap.draw_text(+1, +1, 160, 20, "CRITICAL", 1)\r
        bitmap.font.color.set(255, 255, 255)\r
        bitmap.draw_text(0, 0, 160, 20, "CRITICAL", 1)\r
      end\r
      @_damage_sprite = ::Sprite.new(self.viewport)\r
      @_damage_sprite.bitmap = bitmap\r
      @_damage_sprite.ox = 80\r
      @_damage_sprite.oy = 20\r
      @_damage_sprite.x = self.x\r
      @_damage_sprite.y = self.y - self.oy / 2\r
      @_damage_sprite.z = 3000\r
      @_damage_duration = 40\r
    end\r
    def animation(animation, hit)\r
      dispose_animation\r
      @_animation = animation\r
      return if @_animation == nil\r
      @_animation_hit = hit\r
      @_animation_duration = @_animation.frame_max\r
      animation_name = @_animation.animation_name\r
      animation_hue = @_animation.animation_hue\r
      bitmap = RPG::Cache.animation(animation_name, animation_hue)\r
      if @@_reference_count.include?(bitmap)\r
        @@_reference_count[bitmap] += 1\r
      else\r
        @@_reference_count[bitmap] = 1\r
      end\r
      @_animation_sprites = []\r
      if @_animation.position != 3 or not @@_animations.include?(animation)\r
        for i in 0..15\r
          sprite = ::Sprite.new(self.viewport)\r
          sprite.bitmap = bitmap\r
          sprite.visible = false\r
          @_animation_sprites.push(sprite)\r
        end\r
        unless @@_animations.include?(animation)\r
          @@_animations.push(animation)\r
        end\r
      end\r
      update_animation\r
    end\r
    def loop_animation(animation)\r
      return if animation == @_loop_animation\r
      dispose_loop_animation\r
      @_loop_animation = animation\r
      return if @_loop_animation == nil\r
      @_loop_animation_index = 0\r
      animation_name = @_loop_animation.animation_name\r
      animation_hue = @_loop_animation.animation_hue\r
      bitmap = RPG::Cache.animation(animation_name, animation_hue)\r
      if @@_reference_count.include?(bitmap)\r
        @@_reference_count[bitmap] += 1\r
      else\r
        @@_reference_count[bitmap] = 1\r
      end\r
      @_loop_animation_sprites = []\r
      for i in 0..15\r
        sprite = ::Sprite.new(self.viewport)\r
        sprite.bitmap = bitmap\r
        sprite.visible = false\r
        @_loop_animation_sprites.push(sprite)\r
      end\r
      update_loop_animation\r
    end\r
    def dispose_damage\r
      if @_damage_sprite != nil\r
        @_damage_sprite.bitmap.dispose\r
        @_damage_sprite.dispose\r
        @_damage_sprite = nil\r
        @_damage_duration = 0\r
      end\r
    end\r
    def dispose_animation\r
      if @_animation_sprites != nil\r
        sprite = @_animation_sprites[0]\r
        if sprite != nil\r
          @@_reference_count[sprite.bitmap] -= 1\r
          if @@_reference_count[sprite.bitmap] == 0\r
            sprite.bitmap.dispose\r
          end\r
        end\r
        for sprite in @_animation_sprites\r
          sprite.dispose\r
        end\r
        @_animation_sprites = nil\r
        @_animation = nil\r
      end\r
    end\r
    def dispose_loop_animation\r
      if @_loop_animation_sprites != nil\r
        sprite = @_loop_animation_sprites[0]\r
        if sprite != nil\r
          @@_reference_count[sprite.bitmap] -= 1\r
          if @@_reference_count[sprite.bitmap] == 0\r
            sprite.bitmap.dispose\r
          end\r
        end\r
        for sprite in @_loop_animation_sprites\r
          sprite.dispose\r
        end\r
        @_loop_animation_sprites = nil\r
        @_loop_animation = nil\r
      end\r
    end\r
    def blink_on\r
      unless @_blink\r
        @_blink = true\r
        @_blink_count = 0\r
      end\r
    end\r
    def blink_off\r
      if @_blink\r
        @_blink = false\r
        self.color.set(0, 0, 0, 0)\r
      end\r
    end\r
    def blink?\r
      @_blink\r
    end\r
    def effect?\r
      @_whiten_duration > 0 or\r
      @_appear_duration > 0 or\r
      @_escape_duration > 0 or\r
      @_collapse_duration > 0 or\r
      @_damage_duration > 0 or\r
      @_animation_duration > 0\r
    end\r
    def update\r
      super\r
      if @_whiten_duration > 0\r
        @_whiten_duration -= 1\r
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10\r
      end\r
      if @_appear_duration > 0\r
        @_appear_duration -= 1\r
        self.opacity = (16 - @_appear_duration) * 16\r
      end\r
      if @_escape_duration > 0\r
        @_escape_duration -= 1\r
        self.opacity = 256 - (32 - @_escape_duration) * 10\r
      end\r
      if @_collapse_duration > 0\r
        @_collapse_duration -= 1\r
        self.opacity = 256 - (48 - @_collapse_duration) * 6\r
      end\r
      if @_damage_duration > 0\r
        @_damage_duration -= 1\r
        case @_damage_duration\r
        when 38..39\r
          @_damage_sprite.y -= 4\r
        when 36..37\r
          @_damage_sprite.y -= 2\r
        when 34..35\r
          @_damage_sprite.y += 2\r
        when 28..33\r
          @_damage_sprite.y += 4\r
        end\r
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32\r
        if @_damage_duration == 0\r
          dispose_damage\r
        end\r
      end\r
      if @_animation != nil and (Graphics.frame_count % 2 == 0)\r
        @_animation_duration -= 1\r
        update_animation\r
      end\r
      if @_loop_animation != nil and (Graphics.frame_count % 2 == 0)\r
        update_loop_animation\r
        @_loop_animation_index += 1\r
        @_loop_animation_index %= @_loop_animation.frame_max\r
      end\r
      if @_blink\r
        @_blink_count = (@_blink_count + 1) % 32\r
        if @_blink_count < 16\r
          alpha = (16 - @_blink_count) * 6\r
        else\r
          alpha = (@_blink_count - 16) * 6\r
        end\r
        self.color.set(255, 255, 255, alpha)\r
      end\r
      @@_animations.clear\r
    end\r
    def update_animation\r
      if @_animation_duration > 0\r
        frame_index = @_animation.frame_max - @_animation_duration\r
        cell_data = @_animation.frames[frame_index].cell_data\r
        position = @_animation.position\r
        animation_set_sprites(@_animation_sprites, cell_data, position)\r
        for timing in @_animation.timings\r
          if timing.frame == frame_index\r
            animation_process_timing(timing, @_animation_hit)\r
          end\r
        end\r
      else\r
        dispose_animation\r
      end\r
    end\r
    def update_loop_animation\r
      frame_index = @_loop_animation_index\r
      cell_data = @_loop_animation.frames[frame_index].cell_data\r
      position = @_loop_animation.position\r
      animation_set_sprites(@_loop_animation_sprites, cell_data, position)\r
      for timing in @_loop_animation.timings\r
        if timing.frame == frame_index\r
          animation_process_timing(timing, true)\r
        end\r
      end\r
    end\r
    def animation_set_sprites(sprites, cell_data, position)\r
      for i in 0..15\r
        sprite = sprites[i]\r
        pattern = cell_data[i, 0]\r
        if sprite == nil or pattern == nil or pattern == -1\r
          sprite.visible = false if sprite != nil\r
          next\r
        end\r
        sprite.visible = true\r
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)\r
        if position == 3\r
          if self.viewport != nil\r
            sprite.x = self.viewport.rect.width / 2\r
            sprite.y = self.viewport.rect.height - 160\r
          else\r
            sprite.x = 320\r
            sprite.y = 240\r
          end\r
        else\r
          sprite.x = self.x - self.ox + self.src_rect.width / 2\r
          sprite.y = self.y - self.oy + self.src_rect.height / 2\r
          sprite.y -= self.src_rect.height / 4 if position == 0\r
          sprite.y += self.src_rect.height / 4 if position == 2\r
        end\r
        sprite.x += cell_data[i, 1]\r
        sprite.y += cell_data[i, 2]\r
        sprite.z = 2000\r
        sprite.ox = 96\r
        sprite.oy = 96\r
        sprite.zoom_x = cell_data[i, 3] / 100.0\r
        sprite.zoom_y = cell_data[i, 3] / 100.0\r
        sprite.angle = cell_data[i, 4]\r
        sprite.mirror = (cell_data[i, 5] == 1)\r
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0\r
        sprite.blend_type = cell_data[i, 7]\r
      end\r
    end\r
    def animation_process_timing(timing, hit)\r
      if (timing.condition == 0) or\r
         (timing.condition == 1 and hit == true) or\r
         (timing.condition == 2 and hit == false)\r
        if timing.se.name != ""\r
          se = timing.se\r
          Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)\r
        end\r
        case timing.flash_scope\r
        when 1\r
          self.flash(timing.flash_color, timing.flash_duration * 2)\r
        when 2\r
          if self.viewport != nil\r
            self.viewport.flash(timing.flash_color, timing.flash_duration * 2)\r
          end\r
        when 3\r
          self.flash(nil, timing.flash_duration * 2)\r
        end\r
      end\r
    end\r
    def x=(x)\r
      sx = x - self.x\r
      if sx != 0\r
        if @_animation_sprites != nil\r
          for i in 0..15\r
            @_animation_sprites[i].x += sx\r
          end\r
        end\r
        if @_loop_animation_sprites != nil\r
          for i in 0..15\r
            @_loop_animation_sprites[i].x += sx\r
          end\r
        end\r
      end\r
      super\r
    end\r
    def y=(y)\r
      sy = y - self.y\r
      if sy != 0\r
        if @_animation_sprites != nil\r
          for i in 0..15\r
            @_animation_sprites[i].y += sy\r
          end\r
        end\r
        if @_loop_animation_sprites != nil\r
          for i in 0..15\r
            @_loop_animation_sprites[i].y += sy\r
          end\r
        end\r
      end\r
      super\r
    end\r
  end\r
\r
  class Weather\r
    def initialize(viewport = nil)\r
      @type = 0\r
      @max = 0\r
      @ox = 0\r
      @oy = 0\r
      color1 = Color.new(255, 255, 255, 255)\r
      color2 = Color.new(255, 255, 255, 128)\r
      @rain_bitmap = Bitmap.new(7, 56)\r
      for i in 0..6\r
        @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)\r
      end\r
      @storm_bitmap = Bitmap.new(34, 64)\r
      for i in 0..31\r
        @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)\r
        @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)\r
        @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)\r
      end\r
      @snow_bitmap = Bitmap.new(6, 6)\r
      @snow_bitmap.fill_rect(0, 1, 6, 4, color2)\r
      @snow_bitmap.fill_rect(1, 0, 4, 6, color2)\r
      @snow_bitmap.fill_rect(1, 2, 4, 2, color1)\r
      @snow_bitmap.fill_rect(2, 1, 2, 4, color1)\r
      @sprites = []\r
      for i in 1..40\r
        sprite = Sprite.new(viewport)\r
        sprite.z = 1000\r
        sprite.visible = false\r
        sprite.opacity = 0\r
        @sprites.push(sprite)\r
      end\r
    end\r
    def dispose\r
      for sprite in @sprites\r
        sprite.dispose\r
      end\r
      @rain_bitmap.dispose\r
      @storm_bitmap.dispose\r
      @snow_bitmap.dispose\r
    end\r
    def type=(type)\r
      return if @type == type\r
      @type = type\r
      case @type\r
      when 1\r
        bitmap = @rain_bitmap\r
      when 2\r
        bitmap = @storm_bitmap\r
      when 3\r
        bitmap = @snow_bitmap\r
      else\r
        bitmap = nil\r
      end\r
      for i in 1..40\r
        sprite = @sprites[i]\r
        if sprite != nil\r
          sprite.visible = (i <= @max)\r
          sprite.bitmap = bitmap\r
        end\r
      end\r
    end\r
    def ox=(ox)\r
      return if @ox == ox;\r
      @ox = ox\r
      for sprite in @sprites\r
        sprite.ox = @ox\r
      end\r
    end\r
    def oy=(oy)\r
      return if @oy == oy;\r
      @oy = oy\r
      for sprite in @sprites\r
        sprite.oy = @oy\r
      end\r
    end\r
    def max=(max)\r
      return if @max == max;\r
      @max = [[max, 0].max, 40].min\r
      for i in 1..40\r
        sprite = @sprites[i]\r
        if sprite != nil\r
          sprite.visible = (i <= @max)\r
        end\r
      end\r
    end\r
    def update\r
      return if @type == 0\r
      for i in 1..@max\r
        sprite = @sprites[i]\r
        if sprite == nil\r
          break\r
        end\r
        if @type == 1\r
          sprite.x -= 2\r
          sprite.y += 16\r
          sprite.opacity -= 8\r
        end\r
        if @type == 2\r
          sprite.x -= 8\r
          sprite.y += 16\r
          sprite.opacity -= 12\r
        end\r
        if @type == 3\r
          sprite.x -= 2\r
          sprite.y += 8\r
          sprite.opacity -= 8\r
        end\r
        x = sprite.x - @ox\r
        y = sprite.y - @oy\r
        if sprite.opacity < 64 or x < -50 or x > 750 or y < -300 or y > 500\r
          sprite.x = rand(800) - 50 + @ox\r
          sprite.y = rand(800) - 200 + @oy\r
          sprite.opacity = 255\r
        end\r
      end\r
    end\r
    attr_reader :type\r
    attr_reader :max\r
    attr_reader :ox\r
    attr_reader :oy\r
  end\r
\r
  class Map\r
    def initialize(width, height)\r
      @tileset_id = 1\r
      @width = width\r
      @height = height\r
      @autoplay_bgm = false\r
      @bgm = RPG::AudioFile.new\r
      @autoplay_bgs = false\r
      @bgs = RPG::AudioFile.new("", 80)\r
      @encounter_list = []\r
      @encounter_step = 30\r
      @data = Table.new(width, height, 3)\r
      @events = {}\r
    end\r
    attr_accessor :tileset_id\r
    attr_accessor :width\r
    attr_accessor :height\r
    attr_accessor :autoplay_bgm\r
    attr_accessor :bgm\r
    attr_accessor :autoplay_bgs\r
    attr_accessor :bgs\r
    attr_accessor :encounter_list\r
    attr_accessor :encounter_step\r
    attr_accessor :data\r
    attr_accessor :events\r
  end\r
\r
  class MapInfo\r
    def initialize\r
      @name = ""\r
      @parent_id = 0\r
      @order = 0\r
      @expanded = false\r
      @scroll_x = 0\r
      @scroll_y = 0\r
    end\r
    attr_accessor :name\r
    attr_accessor :parent_id\r
    attr_accessor :order\r
    attr_accessor :expanded\r
    attr_accessor :scroll_x\r
    attr_accessor :scroll_y\r
  end\r
\r
  class Event\r
    class Page\r
      class Condition\r
        def initialize\r
          @switch1_valid = false\r
          @switch2_valid = false\r
          @variable_valid = false\r
          @self_switch_valid = false\r
          @switch1_id = 1\r
          @switch2_id = 1\r
          @variable_id = 1\r
          @variable_value = 0\r
          @self_switch_ch = "A"\r
        end\r
        attr_accessor :switch1_valid\r
        attr_accessor :switch2_valid\r
        attr_accessor :variable_valid\r
        attr_accessor :self_switch_valid\r
        attr_accessor :switch1_id\r
        attr_accessor :switch2_id\r
        attr_accessor :variable_id\r
        attr_accessor :variable_value\r
        attr_accessor :self_switch_ch\r
      end\r
\r
      class Graphic\r
        def initialize\r
          @tile_id = 0\r
          @character_name = ""\r
          @character_hue = 0\r
          @direction = 2\r
          @pattern = 0\r
          @opacity = 255\r
          @blend_type = 0\r
        end\r
        attr_accessor :tile_id\r
        attr_accessor :character_name\r
        attr_accessor :character_hue\r
        attr_accessor :direction\r
        attr_accessor :pattern\r
        attr_accessor :opacity\r
        attr_accessor :blend_type\r
      end\r
\r
      def initialize\r
        @condition = RPG::Event::Page::Condition.new\r
        @graphic = RPG::Event::Page::Graphic.new\r
        @move_type = 0\r
        @move_speed = 3\r
        @move_frequency = 3\r
        @move_route = RPG::MoveRoute.new\r
        @walk_anime = true\r
        @step_anime = false\r
        @direction_fix = false\r
        @through = false\r
        @always_on_top = false\r
        @trigger = 0\r
        @list = [RPG::EventCommand.new]\r
      end\r
      attr_accessor :condition\r
      attr_accessor :graphic\r
      attr_accessor :move_type\r
      attr_accessor :move_speed\r
      attr_accessor :move_frequency\r
      attr_accessor :move_route\r
      attr_accessor :walk_anime\r
      attr_accessor :step_anime\r
      attr_accessor :direction_fix\r
      attr_accessor :through\r
      attr_accessor :always_on_top\r
      attr_accessor :trigger\r
      attr_accessor :list\r
    end\r
\r
    def initialize(x, y)\r
      @id = 0\r
      @name = ""\r
      @x = x\r
      @y = y\r
      @pages = [RPG::Event::Page.new]\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :x\r
    attr_accessor :y\r
    attr_accessor :pages\r
  end\r
\r
  class EventCommand\r
    def initialize(code = 0, indent = 0, parameters = [])\r
      @code = code\r
      @indent = indent\r
      @parameters = parameters\r
    end\r
    attr_accessor :code\r
    attr_accessor :indent\r
    attr_accessor :parameters\r
  end\r
\r
  class MoveRoute\r
    def initialize\r
      @repeat = true\r
      @skippable = false\r
      @list = [RPG::MoveCommand.new]\r
    end\r
    attr_accessor :repeat\r
    attr_accessor :skippable\r
    attr_accessor :list\r
  end\r
\r
  class MoveCommand\r
    def initialize(code = 0, parameters = [])\r
      @code = code\r
      @parameters = parameters\r
    end\r
    attr_accessor :code\r
    attr_accessor :parameters\r
  end\r
\r
  class Actor\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @class_id = 1\r
      @initial_level = 1\r
      @final_level = 99\r
      @exp_basis = 30\r
      @exp_inflation = 30\r
      @character_name = ""\r
      @character_hue = 0\r
      @battler_name = ""\r
      @battler_hue = 0\r
      @parameters = Table.new(6,100)\r
      for i in 1..99\r
        @parameters[0,i] = 500+i*50\r
        @parameters[1,i] = 500+i*50\r
        @parameters[2,i] = 50+i*5\r
        @parameters[3,i] = 50+i*5\r
        @parameters[4,i] = 50+i*5\r
        @parameters[5,i] = 50+i*5\r
      end\r
      @weapon_id = 0\r
      @armor1_id = 0\r
      @armor2_id = 0\r
      @armor3_id = 0\r
      @armor4_id = 0\r
      @weapon_fix = false\r
      @armor1_fix = false\r
      @armor2_fix = false\r
      @armor3_fix = false\r
      @armor4_fix = false\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :class_id\r
    attr_accessor :initial_level\r
    attr_accessor :final_level\r
    attr_accessor :exp_basis\r
    attr_accessor :exp_inflation\r
    attr_accessor :character_name\r
    attr_accessor :character_hue\r
    attr_accessor :battler_name\r
    attr_accessor :battler_hue\r
    attr_accessor :parameters\r
    attr_accessor :weapon_id\r
    attr_accessor :armor1_id\r
    attr_accessor :armor2_id\r
    attr_accessor :armor3_id\r
    attr_accessor :armor4_id\r
    attr_accessor :weapon_fix\r
    attr_accessor :armor1_fix\r
    attr_accessor :armor2_fix\r
    attr_accessor :armor3_fix\r
    attr_accessor :armor4_fix\r
  end\r
\r
  class Class\r
    class Learning\r
      def initialize\r
        @level = 1\r
        @skill_id = 1\r
      end\r
      attr_accessor :level\r
      attr_accessor :skill_id\r
    end\r
\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @position = 0\r
      @weapon_set = []\r
      @armor_set = []\r
      @element_ranks = Table.new(1)\r
      @state_ranks = Table.new(1)\r
      @learnings = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :position\r
    attr_accessor :weapon_set\r
    attr_accessor :armor_set\r
    attr_accessor :element_ranks\r
    attr_accessor :state_ranks\r
    attr_accessor :learnings\r
  end\r
\r
  class Skill\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @icon_name = ""\r
      @description = ""\r
      @scope = 0\r
      @occasion = 1\r
      @animation1_id = 0\r
      @animation2_id = 0\r
      @menu_se = RPG::AudioFile.new("", 80)\r
      @common_event_id = 0\r
      @sp_cost = 0\r
      @power = 0\r
      @atk_f = 0\r
      @eva_f = 0\r
      @str_f = 0\r
      @dex_f = 0\r
      @agi_f = 0\r
      @int_f = 100\r
      @hit = 100\r
      @pdef_f = 0\r
      @mdef_f = 100\r
      @variance = 15\r
      @element_set = []\r
      @plus_state_set = []\r
      @minus_state_set = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :icon_name\r
    attr_accessor :description\r
    attr_accessor :scope\r
    attr_accessor :occasion\r
    attr_accessor :animation1_id\r
    attr_accessor :animation2_id\r
    attr_accessor :menu_se\r
    attr_accessor :common_event_id\r
    attr_accessor :sp_cost\r
    attr_accessor :power\r
    attr_accessor :atk_f\r
    attr_accessor :eva_f\r
    attr_accessor :str_f\r
    attr_accessor :dex_f\r
    attr_accessor :agi_f\r
    attr_accessor :int_f\r
    attr_accessor :hit\r
    attr_accessor :pdef_f\r
    attr_accessor :mdef_f\r
    attr_accessor :variance\r
    attr_accessor :element_set\r
    attr_accessor :plus_state_set\r
    attr_accessor :minus_state_set\r
  end\r
\r
  class Item\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @icon_name = ""\r
      @description = ""\r
      @scope = 0\r
      @occasion = 0\r
      @animation1_id = 0\r
      @animation2_id = 0\r
      @menu_se = RPG::AudioFile.new("", 80)\r
      @common_event_id = 0\r
      @price = 0\r
      @consumable = true\r
      @parameter_type = 0\r
      @parameter_points = 0\r
      @recover_hp_rate = 0\r
      @recover_hp = 0\r
      @recover_sp_rate = 0\r
      @recover_sp = 0\r
      @hit = 100\r
      @pdef_f = 0\r
      @mdef_f = 0\r
      @variance = 0\r
      @element_set = []\r
      @plus_state_set = []\r
      @minus_state_set = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :icon_name\r
    attr_accessor :description\r
    attr_accessor :scope\r
    attr_accessor :occasion\r
    attr_accessor :animation1_id\r
    attr_accessor :animation2_id\r
    attr_accessor :menu_se\r
    attr_accessor :common_event_id\r
    attr_accessor :price\r
    attr_accessor :consumable\r
    attr_accessor :parameter_type\r
    attr_accessor :parameter_points\r
    attr_accessor :recover_hp_rate\r
    attr_accessor :recover_hp\r
    attr_accessor :recover_sp_rate\r
    attr_accessor :recover_sp\r
    attr_accessor :hit\r
    attr_accessor :pdef_f\r
    attr_accessor :mdef_f\r
    attr_accessor :variance\r
    attr_accessor :element_set\r
    attr_accessor :plus_state_set\r
    attr_accessor :minus_state_set\r
  end\r
\r
  class Weapon\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @icon_name = ""\r
      @description = ""\r
      @animation1_id = 0\r
      @animation2_id = 0\r
      @price = 0\r
      @atk = 0\r
      @pdef = 0\r
      @mdef = 0\r
      @str_plus = 0\r
      @dex_plus = 0\r
      @agi_plus = 0\r
      @int_plus = 0\r
      @element_set = []\r
      @plus_state_set = []\r
      @minus_state_set = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :icon_name\r
    attr_accessor :description\r
    attr_accessor :animation1_id\r
    attr_accessor :animation2_id\r
    attr_accessor :price\r
    attr_accessor :atk\r
    attr_accessor :pdef\r
    attr_accessor :mdef\r
    attr_accessor :str_plus\r
    attr_accessor :dex_plus\r
    attr_accessor :agi_plus\r
    attr_accessor :int_plus\r
    attr_accessor :element_set\r
    attr_accessor :plus_state_set\r
    attr_accessor :minus_state_set\r
  end\r
\r
  class Armor\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @icon_name = ""\r
      @description = ""\r
      @kind = 0\r
      @auto_state_id = 0\r
      @price = 0\r
      @pdef = 0\r
      @mdef = 0\r
      @eva = 0\r
      @str_plus = 0\r
      @dex_plus = 0\r
      @agi_plus = 0\r
      @int_plus = 0\r
      @guard_element_set = []\r
      @guard_state_set = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :icon_name\r
    attr_accessor :description\r
    attr_accessor :kind\r
    attr_accessor :auto_state_id\r
    attr_accessor :price\r
    attr_accessor :pdef\r
    attr_accessor :mdef\r
    attr_accessor :eva\r
    attr_accessor :str_plus\r
    attr_accessor :dex_plus\r
    attr_accessor :agi_plus\r
    attr_accessor :int_plus\r
    attr_accessor :guard_element_set\r
    attr_accessor :guard_state_set\r
  end\r
\r
  class Enemy\r
    class Action\r
      def initialize\r
        @kind = 0\r
        @basic = 0\r
        @skill_id = 1\r
        @condition_turn_a = 0\r
        @condition_turn_b = 1\r
        @condition_hp = 100\r
        @condition_level = 1\r
        @condition_switch_id = 0\r
        @rating = 5\r
      end\r
      attr_accessor :kind\r
      attr_accessor :basic\r
      attr_accessor :skill_id\r
      attr_accessor :condition_turn_a\r
      attr_accessor :condition_turn_b\r
      attr_accessor :condition_hp\r
      attr_accessor :condition_level\r
      attr_accessor :condition_switch_id\r
      attr_accessor :rating\r
    end\r
\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @battler_name = ""\r
      @battler_hue = 0\r
      @maxhp = 500\r
      @maxsp = 500\r
      @str = 50\r
      @dex = 50\r
      @agi = 50\r
      @int = 50\r
      @atk = 100\r
      @pdef = 100\r
      @mdef = 100\r
      @eva = 0\r
      @animation1_id = 0\r
      @animation2_id = 0\r
      @element_ranks = Table.new(1)\r
      @state_ranks = Table.new(1)\r
      @actions = [RPG::Enemy::Action.new]\r
      @exp = 0\r
      @gold = 0\r
      @item_id = 0\r
      @weapon_id = 0\r
      @armor_id = 0\r
      @treasure_prob = 100\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :battler_name\r
    attr_accessor :battler_hue\r
    attr_accessor :maxhp\r
    attr_accessor :maxsp\r
    attr_accessor :str\r
    attr_accessor :dex\r
    attr_accessor :agi\r
    attr_accessor :int\r
    attr_accessor :atk\r
    attr_accessor :pdef\r
    attr_accessor :mdef\r
    attr_accessor :eva\r
    attr_accessor :animation1_id\r
    attr_accessor :animation2_id\r
    attr_accessor :element_ranks\r
    attr_accessor :state_ranks\r
    attr_accessor :actions\r
    attr_accessor :exp\r
    attr_accessor :gold\r
    attr_accessor :item_id\r
    attr_accessor :weapon_id\r
    attr_accessor :armor_id\r
    attr_accessor :treasure_prob\r
  end\r
\r
  class Troop\r
    class Member\r
      def initialize\r
        @enemy_id = 1\r
        @x = 0\r
        @y = 0\r
        @hidden = false\r
        @immortal = false\r
      end\r
      attr_accessor :enemy_id\r
      attr_accessor :x\r
      attr_accessor :y\r
      attr_accessor :hidden\r
      attr_accessor :immortal\r
    end\r
\r
    class Page\r
      class Condition\r
        def initialize\r
          @turn_valid = false\r
          @enemy_valid = false\r
          @actor_valid = false\r
          @switch_valid = false\r
          @turn_a = 0\r
          @turn_b = 0\r
          @enemy_index = 0\r
          @enemy_hp = 50\r
          @actor_id = 1\r
          @actor_hp = 50\r
          @switch_id = 1\r
        end\r
        attr_accessor :turn_valid\r
        attr_accessor :enemy_valid\r
        attr_accessor :actor_valid\r
        attr_accessor :switch_valid\r
        attr_accessor :turn_a\r
        attr_accessor :turn_b\r
        attr_accessor :enemy_index\r
        attr_accessor :enemy_hp\r
        attr_accessor :actor_id\r
        attr_accessor :actor_hp\r
        attr_accessor :switch_id\r
      end\r
\r
      def initialize\r
        @condition = RPG::Troop::Page::Condition.new\r
        @span = 0\r
        @list = [RPG::EventCommand.new]\r
      end\r
      attr_accessor :condition\r
      attr_accessor :span\r
      attr_accessor :list\r
    end\r
\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @members = []\r
      @pages = [RPG::BattleEventPage.new]\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :members\r
    attr_accessor :pages\r
  end\r
\r
  class State\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @animation_id = 0\r
      @restriction = 0\r
      @nonresistance = false\r
      @zero_hp = false\r
      @cant_get_exp = false\r
      @cant_evade = false\r
      @slip_damage = false\r
      @rating = 5\r
      @hit_rate = 100\r
      @maxhp_rate = 100\r
      @maxsp_rate = 100\r
      @str_rate = 100\r
      @dex_rate = 100\r
      @agi_rate = 100\r
      @int_rate = 100\r
      @atk_rate = 100\r
      @pdef_rate = 100\r
      @mdef_rate = 100\r
      @eva = 0\r
      @battle_only = true\r
      @hold_turn = 0\r
      @auto_release_prob = 0\r
      @shock_release_prob = 0\r
      @guard_element_set = []\r
      @plus_state_set = []\r
      @minus_state_set = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :animation_id\r
    attr_accessor :restriction\r
    attr_accessor :nonresistance\r
    attr_accessor :zero_hp\r
    attr_accessor :cant_get_exp\r
    attr_accessor :cant_evade\r
    attr_accessor :slip_damage\r
    attr_accessor :rating\r
    attr_accessor :hit_rate\r
    attr_accessor :maxhp_rate\r
    attr_accessor :maxsp_rate\r
    attr_accessor :str_rate\r
    attr_accessor :dex_rate\r
    attr_accessor :agi_rate\r
    attr_accessor :int_rate\r
    attr_accessor :atk_rate\r
    attr_accessor :pdef_rate\r
    attr_accessor :mdef_rate\r
    attr_accessor :eva\r
    attr_accessor :battle_only\r
    attr_accessor :hold_turn\r
    attr_accessor :auto_release_prob\r
    attr_accessor :shock_release_prob\r
    attr_accessor :guard_element_set\r
    attr_accessor :plus_state_set\r
    attr_accessor :minus_state_set\r
  end\r
\r
  class Animation\r
    class Frame\r
      def initialize\r
        @cell_max = 0\r
        @cell_data = Table.new(0, 0)\r
      end\r
      attr_accessor :cell_max\r
      attr_accessor :cell_data\r
    end\r
\r
    class Timing\r
      def initialize\r
        @frame = 0\r
        @se = RPG::AudioFile.new("", 80)\r
        @flash_scope = 0\r
        @flash_color = Color.new(255,255,255,255)\r
        @flash_duration = 5\r
        @condition = 0\r
      end\r
      attr_accessor :frame\r
      attr_accessor :se\r
      attr_accessor :flash_scope\r
      attr_accessor :flash_color\r
      attr_accessor :flash_duration\r
      attr_accessor :condition\r
    end\r
\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @animation_name = ""\r
      @animation_hue = 0\r
      @position = 1\r
      @frame_max = 1\r
      @frames = [RPG::Animation::Frame.new]\r
      @timings = []\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :animation_name\r
    attr_accessor :animation_hue\r
    attr_accessor :position\r
    attr_accessor :frame_max\r
    attr_accessor :frames\r
    attr_accessor :timings\r
  end\r
\r
  class Tileset\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @tileset_name = ""\r
      @autotile_names = [""]*7\r
      @panorama_name = ""\r
      @panorama_hue = 0\r
      @fog_name = ""\r
      @fog_hue = 0\r
      @fog_opacity = 64\r
      @fog_blend_type = 0\r
      @fog_zoom = 200\r
      @fog_sx = 0\r
      @fog_sy = 0\r
      @battleback_name = ""\r
      @passages = Table.new(384)\r
      @priorities = Table.new(384)\r
      @priorities[0] = 5\r
      @terrain_tags = Table.new(384)\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :tileset_name\r
    attr_accessor :autotile_names\r
    attr_accessor :panorama_name\r
    attr_accessor :panorama_hue\r
    attr_accessor :fog_name\r
    attr_accessor :fog_hue\r
    attr_accessor :fog_opacity\r
    attr_accessor :fog_blend_type\r
    attr_accessor :fog_zoom\r
    attr_accessor :fog_sx\r
    attr_accessor :fog_sy\r
    attr_accessor :battleback_name\r
    attr_accessor :passages\r
    attr_accessor :priorities\r
    attr_accessor :terrain_tags\r
  end\r
\r
  class CommonEvent\r
    def initialize\r
      @id = 0\r
      @name = ""\r
      @trigger = 0\r
      @switch_id = 1\r
      @list = [RPG::EventCommand.new]\r
    end\r
    attr_accessor :id\r
    attr_accessor :name\r
    attr_accessor :trigger\r
    attr_accessor :switch_id\r
    attr_accessor :list\r
  end\r
\r
  class System\r
    class Words\r
      def initialize\r
        @gold = ""\r
        @hp = ""\r
        @sp = ""\r
        @str = ""\r
        @dex = ""\r
        @agi = ""\r
        @int = ""\r
        @atk = ""\r
        @pdef = ""\r
        @mdef = ""\r
        @weapon = ""\r
        @armor1 = ""\r
        @armor2 = ""\r
        @armor3 = ""\r
        @armor4 = ""\r
        @attack = ""\r
        @skill = ""\r
        @guard = ""\r
        @item = ""\r
        @equip = ""\r
      end\r
      attr_accessor :gold\r
      attr_accessor :hp\r
      attr_accessor :sp\r
      attr_accessor :str\r
      attr_accessor :dex\r
      attr_accessor :agi\r
      attr_accessor :int\r
      attr_accessor :atk\r
      attr_accessor :pdef\r
      attr_accessor :mdef\r
      attr_accessor :weapon\r
      attr_accessor :armor1\r
      attr_accessor :armor2\r
      attr_accessor :armor3\r
      attr_accessor :armor4\r
      attr_accessor :attack\r
      attr_accessor :skill\r
      attr_accessor :guard\r
      attr_accessor :item\r
      attr_accessor :equip\r
    end\r
\r
    class TestBattler\r
      def initialize\r
        @actor_id = 1\r
        @level = 1\r
        @weapon_id = 0\r
        @armor1_id = 0\r
        @armor2_id = 0\r
        @armor3_id = 0\r
        @armor4_id = 0\r
      end\r
      attr_accessor :actor_id\r
      attr_accessor :level\r
      attr_accessor :weapon_id\r
      attr_accessor :armor1_id\r
      attr_accessor :armor2_id\r
      attr_accessor :armor3_id\r
      attr_accessor :armor4_id\r
    end\r
\r
    def initialize\r
      @magic_number = 0\r
      @party_members = [1]\r
      @elements = [nil, ""]\r
      @switches = [nil, ""]\r
      @variables = [nil, ""]\r
      @windowskin_name = ""\r
      @title_name = ""\r
      @gameover_name = ""\r
      @battle_transition = ""\r
      @title_bgm = RPG::AudioFile.new\r
      @battle_bgm = RPG::AudioFile.new\r
      @battle_end_me = RPG::AudioFile.new\r
      @gameover_me = RPG::AudioFile.new\r
      @cursor_se = RPG::AudioFile.new("", 80)\r
      @decision_se = RPG::AudioFile.new("", 80)\r
      @cancel_se = RPG::AudioFile.new("", 80)\r
      @buzzer_se = RPG::AudioFile.new("", 80)\r
      @equip_se = RPG::AudioFile.new("", 80)\r
      @shop_se = RPG::AudioFile.new("", 80)\r
      @save_se = RPG::AudioFile.new("", 80)\r
      @load_se = RPG::AudioFile.new("", 80)\r
      @battle_start_se = RPG::AudioFile.new("", 80)\r
      @escape_se = RPG::AudioFile.new("", 80)\r
      @actor_collapse_se = RPG::AudioFile.new("", 80)\r
      @enemy_collapse_se = RPG::AudioFile.new("", 80)\r
      @words = RPG::System::Words.new\r
      @test_battlers = []\r
      @test_troop_id = 1\r
      @start_map_id = 1\r
      @start_x = 0\r
      @start_y = 0\r
      @battleback_name = ""\r
      @battler_name = ""\r
      @battler_hue = 0\r
      @edit_map_id = 1\r
    end\r
    attr_accessor :magic_number\r
    attr_accessor :party_members\r
    attr_accessor :elements\r
    attr_accessor :switches\r
    attr_accessor :variables\r
    attr_accessor :windowskin_name\r
    attr_accessor :title_name\r
    attr_accessor :gameover_name\r
    attr_accessor :battle_transition\r
    attr_accessor :title_bgm\r
    attr_accessor :battle_bgm\r
    attr_accessor :battle_end_me\r
    attr_accessor :gameover_me\r
    attr_accessor :cursor_se\r
    attr_accessor :decision_se\r
    attr_accessor :cancel_se\r
    attr_accessor :buzzer_se\r
    attr_accessor :equip_se\r
    attr_accessor :shop_se\r
    attr_accessor :save_se\r
    attr_accessor :load_se\r
    attr_accessor :battle_start_se\r
    attr_accessor :escape_se\r
    attr_accessor :actor_collapse_se\r
    attr_accessor :enemy_collapse_se\r
    attr_accessor :words\r
    attr_accessor :test_battlers\r
    attr_accessor :test_troop_id\r
    attr_accessor :start_map_id\r
    attr_accessor :start_x\r
    attr_accessor :start_y\r
    attr_accessor :battleback_name\r
    attr_accessor :battler_name\r
    attr_accessor :battler_hue\r
    attr_accessor :edit_map_id\r
  end\r
\r
  class AudioFile\r
    def initialize(name = "", volume = 100, pitch = 100)\r
      @name = name\r
      @volume = volume\r
      @pitch = pitch\r
    end\r
    attr_accessor :name\r
    attr_accessor :volume\r
    attr_accessor :pitch\r
  end\r
end\r
`;var bt=`require 'js'\r
Dir.chdir('/game')\r
$RG_JS = JS.global[:RG]\r
begin\r
  scripts = JS.global[:RGScripts]\r
  n = scripts[:length].to_i\r
  n.times do |i|\r
    s = scripts[i]\r
    name = s[0].to_s\r
    code = s[1].to_s\r
    TOPLEVEL_BINDING.eval(code, name, 1)\r
  end\r
  $RG_JS.call(:onExit)\r
rescue SystemExit\r
  $RG_JS.call(:onExit)\r
rescue Exception => e\r
  bt = (e.backtrace || [])[0, 16].join("\\n")\r
  $RG_JS.call(:onError, "#{e.class}: #{e.message}\\n#{bt}")\r
end\r
nil\r
`;var se="bjyxts121:",g=l=>document.getElementById(l),Xe=matchMedia("(pointer: coarse)").matches||"ontouchstart"in window;function fe(l,e){g("load-text").textContent=l,e!=null&&(g("load-bar-inner").style.width=`${Math.round(e*100)}%`)}async function kt(l,e){let t=await fetch(l);if(!t.ok)throw new Error(`\u4E0B\u8F7D\u5931\u8D25: ${l} (${t.status})`);let n=+t.headers.get("content-length")||0;if(!t.body||!n){let c=await t.arrayBuffer();return e(1),c}let a=t.body.getReader(),s=[],r=0;for(;;){let{done:c,value:d}=await a.read();if(c)break;s.push(d),r+=d.length,e(Math.min(1,r/n))}let i=new Uint8Array(r),o=0;for(let c of s)i.set(c,o),o+=c.length;return i.buffer}var Pe=class extends Map{get(e){let t=super.get(e);if(t!==void 0)return t;let n=String(e).toLowerCase();for(let[a,s]of this)if(a.toLowerCase()===n)return s}has(e){return this.get(e)!==void 0}};function Gt(l,e){let t=l;for(let n of e){let a=t.contents.get(n);a||(a=new z(new Pe),a.parent=t,t.contents.set(n,a)),t=a}return t}function gt(l,e,t){let n=e.split("/").filter(Boolean),a=n.pop();Gt(l,n).contents.set(a,new $(t))}function yt(l,e){let t=String(e).replace(/\\/g,"/").split("/").filter(a=>a&&a!=="."),n=l;for(let a of t)if(!(n instanceof z)||(n=n.contents.get(a),!n))return null;return n instanceof $?n:null}function Pt(l){let e="";for(let t=0;t<l.length;t+=32768)e+=String.fromCharCode.apply(null,l.subarray(t,t+32768));return btoa(e)}function Dt(l){let e=atob(l),t=new Uint8Array(e.length);for(let n=0;n<e.length;n++)t[n]=e.charCodeAt(n);return t}var Qe={save(l,e){try{localStorage.setItem(se+l,Pt(e))}catch(t){console.error(t),re.toast("\u5B58\u6863\u5199\u5165\u6D4F\u89C8\u5668\u5B58\u50A8\u5931\u8D25\uFF08\u7A7A\u95F4\u4E0D\u8DB3\u6216\u5904\u4E8E\u9690\u79C1\u6A21\u5F0F\uFF09")}},remove(l){localStorage.removeItem(se+l)},all(){let l=[];for(let e=0;e<localStorage.length;e++){let t=localStorage.key(e);if(!t||!t.startsWith(se))continue;let n=t.slice(se.length);if(!n.startsWith("#"))try{l.push([n,Dt(localStorage.getItem(t))])}catch(a){console.warn("\u8DF3\u8FC7\u65E0\u6CD5\u89E3\u7801\u7684\u672C\u5730\u5B58\u6863\u9879",n,a)}}return l}},re={alert(l){return new Promise(e=>{let t=g("dialog");g("dlg-text").textContent=l,g("dlg-input").style.display="none",g("dlg-cancel").style.display="none",t.classList.add("show"),R&&R.clearInput();let n=g("dlg-ok"),a=()=>{t.classList.remove("show"),n.onclick=null,document.removeEventListener("keydown",s,!0),e(0)},s=r=>{(r.key==="Enter"||r.key==="Escape"||r.key===" ")&&(r.preventDefault(),r.stopPropagation(),a())};n.onclick=a,setTimeout(()=>document.addEventListener("keydown",s,!0),150)})},prompt(l,e,t){return new Promise(n=>{let a=g("dialog"),s=g("dlg-input");g("dlg-text").textContent=l,s.style.display="",s.value=e||"",s.maxLength=t>0?t:524288,g("dlg-cancel").style.display="",a.classList.add("show"),R&&R.clearInput(),setTimeout(()=>{s.focus(),s.select()},50);let r=i=>{a.classList.remove("show"),g("dlg-ok").onclick=null,g("dlg-cancel").onclick=null,s.onkeydown=null,s.blur(),R&&R.clearInput(),n(i)};g("dlg-ok").onclick=()=>{let i=s.value.trim();t>0&&(i=[...i].slice(0,t).join("")),r(i||e||"")},g("dlg-cancel").onclick=()=>r(e||""),s.onkeydown=i=>{i.stopPropagation(),i.key==="Enter"&&!i.isComposing&&g("dlg-ok").onclick()}})},toast(l){let e=g("toast");e.textContent=l,e.classList.add("show"),clearTimeout(re._tt),re._tt=setTimeout(()=>e.classList.remove("show"),2600)}},R=null,wt={ArrowDown:[2],ArrowLeft:[4],ArrowRight:[6],ArrowUp:[8],Numpad2:[2],Numpad4:[4],Numpad6:[6],Numpad8:[8],Enter:[13],NumpadEnter:[13],Space:[13],KeyC:[13],Escape:[12],KeyX:[12],Numpad0:[12],Backspace:[12],ShiftLeft:[11,21],ShiftRight:[11,21],KeyZ:[11],KeyA:[14],KeyS:[15],KeyD:[16],KeyQ:[17],PageUp:[17],KeyW:[18],PageDown:[18],ControlLeft:[22],ControlRight:[22],AltLeft:[23],AltRight:[23],F5:[25],F6:[26],F7:[27],F8:[28],F9:[29]};function zt(){window.addEventListener("keydown",l=>{if(g("dialog").classList.contains("show")||g("settings").classList.contains("show"))return;let e=wt[l.code];if(e){l.preventDefault();for(let t of e)R.pressCode(t,!0,!1)}}),window.addEventListener("keyup",l=>{let e=wt[l.code];if(e){l.preventDefault();for(let t of e)R.pressCode(t,!1,!1)}}),window.addEventListener("blur",()=>R&&R.clearInput())}function Ut(){let l=g("dpad"),e=null,t=0,n=r=>{if(r!==t){t&&R.pressCode(t,!1,!0),t=r,r&&(R.pressCode(r,!0,!0),navigator.vibrate&&navigator.vibrate(8));for(let i of l.querySelectorAll(".dir"))i.classList.toggle("on",+i.dataset.code===r)}},a=r=>{let i=l.getBoundingClientRect(),o=r.clientX-(i.left+i.width/2),c=r.clientY-(i.top+i.height/2);return Math.hypot(o,c)<i.width*.12?0:Math.abs(o)>Math.abs(c)?o>0?6:4:c>0?2:8};l.addEventListener("pointerdown",r=>{r.preventDefault(),e=r.pointerId,l.setPointerCapture(r.pointerId),R.audio.unlock(),n(a(r))}),l.addEventListener("pointermove",r=>{r.pointerId===e&&n(a(r))});let s=r=>{r.pointerId===e&&(e=null,n(0))};l.addEventListener("pointerup",s),l.addEventListener("pointercancel",s),l.addEventListener("lostpointercapture",s);for(let r of document.querySelectorAll(".btn[data-code]")){let i=r.dataset.code.split(",").map(Number),o=new Set,c=_=>{_.preventDefault(),r.setPointerCapture(_.pointerId),o.add(_.pointerId),R.audio.unlock(),r.classList.add("on");for(let f of i)R.pressCode(f,!0,!0);navigator.vibrate&&navigator.vibrate(10)},d=_=>{if(o.delete(_.pointerId)&&!o.size){r.classList.remove("on");for(let f of i)R.pressCode(f,!1,!0)}};r.addEventListener("pointerdown",c),r.addEventListener("pointerup",d),r.addEventListener("pointercancel",d),r.addEventListener("lostpointercapture",d)}document.addEventListener("contextmenu",r=>r.preventDefault())}function ye(){let l=window.innerWidth,e=window.innerHeight,t=e>l;document.body.classList.toggle("portrait",t&&Xe);let n=document.body.classList.contains("pad-on"),a=0;n&&(a=Math.min(200,Math.max(120,l*.17)));let s=Math.min(e/480,(l-a*2)/640),r=!1;n&&s<e/480*.72&&(s=Math.min(e/480,l/640),r=!0),document.body.classList.toggle("pad-overlay",r);let i=g("screen");i.style.width=`${Math.floor(640*s)}px`,i.style.height=`${Math.floor(480*s)}px`;let o=r?a:Math.max(a,(l-Math.floor(640*s))/2);document.documentElement.style.setProperty("--side",`${o}px`),document.documentElement.style.setProperty("--pad",`${Math.min(o*.86,e*.46)}px`)}async function Rt(){let l=document.documentElement;try{!document.fullscreenElement&&l.requestFullscreen?await l.requestFullscreen({navigationUI:"hide"}):l.webkitRequestFullscreen&&l.webkitRequestFullscreen()}catch{}try{screen.orientation&&screen.orientation.lock&&await screen.orientation.lock("landscape")}catch{}}function Bt(){let l=g("settings");g("gear").addEventListener("click",()=>{l.classList.add("show"),R.clearInput()}),g("set-close").addEventListener("click",()=>l.classList.remove("show")),g("set-full").addEventListener("click",()=>{document.fullscreenElement?document.exitFullscreen():Rt()}),g("set-pad").addEventListener("click",()=>{document.body.classList.toggle("pad-on"),localStorage.setItem(se+"#pad",document.body.classList.contains("pad-on")?"1":"0"),ye()});let e=(s,r)=>{let i=g(s),o=`${se}#vol_${r}`;i.value=localStorage.getItem(o)??"100";let c=()=>{R.audio.setMaster(r,i.value/100),localStorage.setItem(o,i.value)};i.addEventListener("input",c),c()};e("set-bgm","bgm"),e("set-se","se"),g("set-export").addEventListener("click",()=>{let s=yt(window.__gameRoot,"Gmud.sav");if(!s){re.toast("\u8FD8\u6CA1\u6709\u5B58\u6863");return}let r=new Blob([s.data],{type:"application/octet-stream"}),i=document.createElement("a");i.href=URL.createObjectURL(r);let o=new Date;i.download=`Gmud_${o.getFullYear()}${String(o.getMonth()+1).padStart(2,"0")}${String(o.getDate()).padStart(2,"0")}.sav`,i.click(),setTimeout(()=>URL.revokeObjectURL(i.href),2e3)}),g("set-import").addEventListener("click",()=>g("import-file").click()),g("import-file").addEventListener("change",async s=>{let r=s.target.files[0];if(!r)return;let i=new Uint8Array(await r.arrayBuffer());if(i.length<8){re.toast("\u6587\u4EF6\u65E0\u6548");return}Qe.save("Gmud.sav",i),await re.alert("\u5B58\u6863\u5DF2\u5BFC\u5165\uFF08\u4E0E PC \u7248 Gmud.sav \u901A\u7528\uFF09\u3002\u9875\u9762\u5C06\u91CD\u65B0\u8F7D\u5165\u3002"),location.reload()}),g("set-reset").addEventListener("click",async()=>{location.reload()});let t=s=>{g("cheat-msg").textContent=s},n=s=>{let r=g(s).value.trim();return/^\d+$/.test(r)?Math.min(Number(r),2147483647):null},a=s=>{R&&(R.cheatQueue=s,t("\u5904\u7406\u4E2D\u2026"))};R.cheatQueue="",R.cheatTake=()=>{let s=R.cheatQueue;return R.cheatQueue="",s},R.cheatReport=s=>{let r=String(s).split("|");if(r[0]!=="ok"){t(r.slice(1).join("|")||"\u5931\u8D25");return}g("cheat-exp").value=r[1],g("cheat-pot").value=r[2],g("cheat-gold").value=r[3],t(R.cheatApplied?`\u5DF2\u4FEE\u6539\u300C${r[4]}\u300D\u7684\u6570\u503C\u3002\u60F3\u4FDD\u7559\u8BF7\u56DE\u5230\u6E38\u620F\uFF0C\u5728\u83DC\u5355\u300C\u529F\u80FD\u300D\u91CC\u5B58\u6863\u3002`:`\u5F53\u524D\u89D2\u8272\uFF1A${r[4]}`),R.cheatApplied=!1},g("cheat-read").addEventListener("click",()=>a("get")),g("cheat-add").addEventListener("click",()=>{let s=n("cheat-exp"),r=n("cheat-pot");if(s===null||r===null){t("\u8BF7\u5148\u70B9\u300C\u8BFB\u53D6\u5F53\u524D\u300D");return}g("cheat-exp").value=s+1e7,g("cheat-pot").value=r+1e7,t("\u5DF2\u586B\u5165\uFF0C\u70B9\u300C\u5E94\u7528\u4FEE\u6539\u300D\u751F\u6548\u3002")}),g("cheat-apply").addEventListener("click",()=>{let s=n("cheat-exp"),r=n("cheat-pot"),i=n("cheat-gold");if(s===null||r===null||i===null){t("\u8BF7\u8F93\u5165\u975E\u8D1F\u6574\u6570\uFF08\u53EF\u5148\u70B9\u300C\u8BFB\u53D6\u5F53\u524D\u300D\uFF09");return}R.cheatApplied=!0,a(`set|${s}|${r}|${Math.min(i,9999999)}`)}),g("gear").addEventListener("click",()=>a("get")),localStorage.getItem(se+"#pad")==="0"&&document.body.classList.remove("pad-on")}async function Mt(){Xe&&document.body.classList.add("touch","pad-on"),ye(),window.addEventListener("resize",ye),window.addEventListener("orientationchange",()=>setTimeout(ye,200)),fe("\u8BFB\u53D6\u8D44\u6E90\u6E05\u5355\u2026",0);let l=await(await fetch("game/manifest.json")).json(),e=(async()=>{let u=await kt(l.wasm,m=>fe(`\u4E0B\u8F7D\u5F15\u64CE ${Math.round(m*100)}%`,m*.7));return fe("\u7F16\u8BD1\u5F15\u64CE\u2026",.72),WebAssembly.compile(u)})(),t=new Map,n=Promise.all(l.images.map(u=>new Promise(m=>{let b=new Image;b.onload=()=>{t.set(u.replace(/\.(png|jpg|jpeg|bmp)$/i,"").toLowerCase(),b),m()},b.onerror=()=>{console.warn("image failed",u),m()},b.src=`game/${encodeURI(u)}`}))),a=new Map;for(let u of l.audio)a.set(u.replace(/\.(mp3|ogg|wav|m4a)$/i,"").toLowerCase(),`game/${encodeURI(u)}`);let s=new z(new Pe);window.__gameRoot=s;let r=Promise.all(l.data.map(async u=>{let m=await fetch(`game/${encodeURI(u)}`);gt(s,u,new Uint8Array(await m.arrayBuffer()))})),i=fetch("game/scripts.json").then(u=>u.json()),o=document.fonts&&document.fonts.load?Promise.race([document.fonts.load("22px GameSong","\u82F1\u96C4\u575B\u8BF4"),new Promise(u=>setTimeout(u,15e3))]).catch(()=>{}):Promise.resolve(),[c,d]=await Promise.all([e,i,n,r,o]).then(u=>[u[0],u[1]]);for(let[u,m]of Qe.all())u.startsWith("#")||gt(s,u,m);fe("\u542F\u52A8 Ruby \u865A\u62DF\u673A\u2026",.85);let _=[new oe(new $([])),ce.lineBuffered(u=>console.log("[stdout]",u)),ce.lineBuffered(u=>console.warn("[stderr]",u)),new ge("/game",s.contents)],f=_[3];window.__gameRoot=f.dir;let h=new Ye(["ruby"],[],_,{debug:!1}),{vm:p}=await Le.instantiateModule({module:c,wasip1:h});window.__vm=p,R=new Ge({canvas:g("screen"),images:t,audioFiles:a,fs:{read:u=>{let m=yt(window.__gameRoot,u);return m?m.data:null}},storage:Qe,ui:re}),window.RG=R,window.RGScripts=d,R.onExit=()=>{R.audio.pauseAll(),g("ended").classList.add("show")},R.onError=u=>{console.error(String(u)),R.audio.pauseAll(),g("err-text").textContent=String(u),g("error").classList.add("show")},zt(),Ut(),Bt(),ye(),fe("\u52A0\u8F7D\u811A\u672C\u2026",.92),p.eval(pt),p.eval(ht),p.eval(mt),fe("\u51C6\u5907\u5C31\u7EEA",1),await new Promise(u=>{g("loading").classList.add("ready");let m=async()=>{g("start-btn").removeEventListener("click",m),R.audio.unlock(),R.audio.preloadSE(l.audio.filter(b=>b.startsWith("Audio/SE/")).map(b=>b.replace(/\.[^.]+$/,""))),Xe&&Rt(),g("loading").classList.remove("show"),u()};g("start-btn").addEventListener("click",m)}),document.addEventListener("visibilitychange",()=>{document.hidden?R.audio.pauseAll():R.audio.resumeAll()});try{await p.evalAsync(bt)}catch(u){R.onError(u&&u.message?u.message:String(u))}}Mt().catch(l=>{console.error(l),g("load-text").textContent=`\u52A0\u8F7D\u5931\u8D25\uFF1A${l.message||l}`});})();
