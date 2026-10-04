(()=>{var ue=class l{static read_bytes(e,t){let n=new l;return n.buf=e.getUint32(t,!0),n.buf_len=e.getUint32(t+4,!0),n}static read_bytes_array(e,t,n){let a=[];for(let s=0;s<n;s++)a.push(l.read_bytes(e,t+8*s));return a}},pe=class l{static read_bytes(e,t){let n=new l;return n.buf=e.getUint32(t,!0),n.buf_len=e.getUint32(t+4,!0),n}static read_bytes_array(e,t,n){let a=[];for(let s=0;s<n;s++)a.push(l.read_bytes(e,t+8*s));return a}},Ue=0,Be=1,ve=2;var je=2,L=3,ie=4;var ne=class{head_length(){return 24}name_length(){return this.dir_name.byteLength}write_head_bytes(e,t){e.setBigUint64(t,this.d_next,!0),e.setBigUint64(t+8,this.d_ino,!0),e.setUint32(t+16,this.dir_name.length,!0),e.setUint8(t+20,this.d_type)}write_name_bytes(e,t,n){e.set(this.dir_name.slice(0,Math.min(this.dir_name.byteLength,n)),t)}constructor(e,t,n,a){let s=new TextEncoder().encode(n);this.d_next=e,this.d_ino=t,this.d_namlen=s.byteLength,this.d_type=a,this.dir_name=s}};var Me=1;var X=class{write_bytes(e,t){e.setUint8(t,this.fs_filetype),e.setUint16(t+2,this.fs_flags,!0),e.setBigUint64(t+8,this.fs_rights_base,!0),e.setBigUint64(t+16,this.fs_rights_inherited,!0)}constructor(e,t){this.fs_rights_base=0n,this.fs_rights_inherited=0n,this.fs_filetype=e,this.fs_flags=t}};var Se=1,ae=2,We=4,Ne=8,Q=class{write_bytes(e,t){e.setBigUint64(t,this.dev,!0),e.setBigUint64(t+8,this.ino,!0),e.setUint8(t+16,this.filetype),e.setBigUint64(t+24,this.nlink,!0),e.setBigUint64(t+32,this.size,!0),e.setBigUint64(t+38,this.atim,!0),e.setBigUint64(t+46,this.mtim,!0),e.setBigUint64(t+52,this.ctim,!0)}constructor(e,t,n){this.dev=0n,this.nlink=0n,this.atim=0n,this.mtim=0n,this.ctim=0n,this.ino=e,this.filetype=t,this.size=n}},Ze=0;var et=1,Re=class l{static read_bytes(e,t){return new l(e.getBigUint64(t,!0),e.getUint8(t+8),e.getUint32(t+16,!0),e.getBigUint64(t+24,!0),e.getUint16(t+36,!0))}constructor(e,t,n,a,s){this.userdata=e,this.eventtype=t,this.clockid=n,this.timeout=a,this.flags=s}},Ee=class{write_bytes(e,t){e.setBigUint64(t,this.userdata,!0),e.setUint16(t+8,this.error,!0),e.setUint8(t+10,this.eventtype)}constructor(e,t,n){this.userdata=e,this.error=t,this.eventtype=n}};var Et=0,ze=class{write_bytes(e,t){e.setUint32(t,this.pr_name.byteLength,!0)}constructor(e){this.pr_name=new TextEncoder().encode(e)}},xe=class l{static dir(e){let t=new l;return t.tag=Et,t.inner=new ze(e),t}write_bytes(e,t){e.setUint32(t,this.tag,!0),this.inner.write_bytes(e,t+4)}};var xt=class{enable(e){this.log=vt(e===void 0?!0:e,this.prefix)}get enabled(){return this.isEnabled}constructor(e){this.isEnabled=e,this.prefix="wasi:",this.enable(e)}};function vt(l,e){return l?console.log.bind(console,"%c%s","color: #265BA0",e):()=>{}}var I=new xt(!1);var me=class extends Error{constructor(e){super("exit with exit code "+e),this.code=e}},Ye=class{start(e){this.inst=e;try{return e.exports._start(),0}catch(t){if(t instanceof me)return t.code;throw t}}initialize(e){this.inst=e,e.exports._initialize&&e.exports._initialize()}constructor(e,t,n,a={}){this.args=[],this.env=[],this.fds=[],I.enable(a.debug),this.args=e,this.env=t,this.fds=n;let s=this;this.wasiImport={args_sizes_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);o.setUint32(r,s.args.length,!0);let c=0;for(let d of s.args)c+=d.length+1;return o.setUint32(i,c,!0),I.log(o.getUint32(r,!0),o.getUint32(i,!0)),0},args_get(r,i){let o=new DataView(s.inst.exports.memory.buffer),c=new Uint8Array(s.inst.exports.memory.buffer),d=i;for(let _=0;_<s.args.length;_++){o.setUint32(r,i,!0),r+=4;let f=new TextEncoder().encode(s.args[_]);c.set(f,i),o.setUint8(i+f.length,0),i+=f.length+1}return I.enabled&&I.log(new TextDecoder("utf-8").decode(c.slice(d,i))),0},environ_sizes_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);o.setUint32(r,s.env.length,!0);let c=0;for(let d of s.env)c+=new TextEncoder().encode(d).length+1;return o.setUint32(i,c,!0),I.log(o.getUint32(r,!0),o.getUint32(i,!0)),0},environ_get(r,i){let o=new DataView(s.inst.exports.memory.buffer),c=new Uint8Array(s.inst.exports.memory.buffer),d=i;for(let _=0;_<s.env.length;_++){o.setUint32(r,i,!0),r+=4;let f=new TextEncoder().encode(s.env[_]);c.set(f,i),o.setUint8(i+f.length,0),i+=f.length+1}return I.enabled&&I.log(new TextDecoder("utf-8").decode(c.slice(d,i))),0},clock_res_get(r,i){let o;switch(r){case 1:{o=5000n;break}case 0:{o=1000000n;break}default:return 52}return new DataView(s.inst.exports.memory.buffer).setBigUint64(i,o,!0),0},clock_time_get(r,i,o){let c=new DataView(s.inst.exports.memory.buffer);if(r===0)c.setBigUint64(o,BigInt(new Date().getTime())*1000000n,!0);else if(r==1){let d;try{d=BigInt(Math.round(performance.now()*1e6))}catch{d=0n}c.setBigUint64(o,d,!0)}else c.setBigUint64(o,0n,!0);return 0},fd_advise(r,i,o,c){return s.fds[r]!=null?0:8},fd_allocate(r,i,o){return s.fds[r]!=null?s.fds[r].fd_allocate(i,o):8},fd_close(r){if(s.fds[r]!=null){let i=s.fds[r].fd_close();return s.fds[r]=void 0,i}else return 8},fd_datasync(r){return s.fds[r]!=null?s.fds[r].fd_sync():8},fd_fdstat_get(r,i){if(s.fds[r]!=null){let{ret:o,fdstat:c}=s.fds[r].fd_fdstat_get();return c?.write_bytes(new DataView(s.inst.exports.memory.buffer),i),o}else return 8},fd_fdstat_set_flags(r,i){return s.fds[r]!=null?s.fds[r].fd_fdstat_set_flags(i):8},fd_fdstat_set_rights(r,i,o){return s.fds[r]!=null?s.fds[r].fd_fdstat_set_rights(i,o):8},fd_filestat_get(r,i){if(s.fds[r]!=null){let{ret:o,filestat:c}=s.fds[r].fd_filestat_get();return c?.write_bytes(new DataView(s.inst.exports.memory.buffer),i),o}else return 8},fd_filestat_set_size(r,i){return s.fds[r]!=null?s.fds[r].fd_filestat_set_size(i):8},fd_filestat_set_times(r,i,o,c){return s.fds[r]!=null?s.fds[r].fd_filestat_set_times(i,o,c):8},fd_pread(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=ue.read_bytes_array(_,i,o),p=0;for(let u of h){let{ret:m,data:b}=s.fds[r].fd_pread(u.buf_len,c);if(m!=0)return _.setUint32(d,p,!0),m;if(f.set(b,u.buf),p+=b.length,c+=BigInt(b.length),b.length!=u.buf_len)break}return _.setUint32(d,p,!0),0}else return 8},fd_prestat_get(r,i){let o=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:c,prestat:d}=s.fds[r].fd_prestat_get();return d?.write_bytes(o,i),c}else return 8},fd_prestat_dir_name(r,i,o){if(s.fds[r]!=null){let{ret:c,prestat:d}=s.fds[r].fd_prestat_get();if(d==null)return c;let _=d.inner.pr_name;return new Uint8Array(s.inst.exports.memory.buffer).set(_.slice(0,o),i),_.byteLength>o?37:0}else return 8},fd_pwrite(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=pe.read_bytes_array(_,i,o),p=0;for(let u of h){let m=f.slice(u.buf,u.buf+u.buf_len),{ret:b,nwritten:E}=s.fds[r].fd_pwrite(m,c);if(b!=0)return _.setUint32(d,p,!0),b;if(p+=E,c+=BigInt(E),E!=m.byteLength)break}return _.setUint32(d,p,!0),0}else return 8},fd_read(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer),_=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let f=ue.read_bytes_array(d,i,o),h=0;for(let p of f){let{ret:u,data:m}=s.fds[r].fd_read(p.buf_len);if(u!=0)return d.setUint32(c,h,!0),u;if(_.set(m,p.buf),h+=m.length,m.length!=p.buf_len)break}return d.setUint32(c,h,!0),0}else return 8},fd_readdir(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=0;for(;;){let{ret:p,dirent:u}=s.fds[r].fd_readdir_single(c);if(p!=0)return _.setUint32(d,h,!0),p;if(u==null)break;if(o-h<u.head_length()){h=o;break}let m=new ArrayBuffer(u.head_length());if(u.write_head_bytes(new DataView(m),0),f.set(new Uint8Array(m).slice(0,Math.min(m.byteLength,o-h)),i),i+=u.head_length(),h+=u.head_length(),o-h<u.name_length()){h=o;break}u.write_name_bytes(f,i,o-h),i+=u.name_length(),h+=u.name_length(),c=u.d_next}return _.setUint32(d,h,!0),0}else return 8},fd_renumber(r,i){if(s.fds[r]!=null&&s.fds[i]!=null){let o=s.fds[i].fd_close();return o!=0?o:(s.fds[i]=s.fds[r],s.fds[r]=void 0,0)}else return 8},fd_seek(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:_,offset:f}=s.fds[r].fd_seek(i,o);return d.setBigInt64(c,f,!0),_}else return 8},fd_sync(r){return s.fds[r]!=null?s.fds[r].fd_sync():8},fd_tell(r,i){let o=new DataView(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let{ret:c,offset:d}=s.fds[r].fd_tell();return o.setBigUint64(i,d,!0),c}else return 8},fd_write(r,i,o,c){let d=new DataView(s.inst.exports.memory.buffer),_=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let f=pe.read_bytes_array(d,i,o),h=0;for(let p of f){let u=_.slice(p.buf,p.buf+p.buf_len),{ret:m,nwritten:b}=s.fds[r].fd_write(u);if(m!=0)return d.setUint32(c,h,!0),m;if(h+=b,b!=u.byteLength)break}return d.setUint32(c,h,!0),0}else return 8},path_create_directory(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_create_directory(d)}else return 8},path_filestat_get(r,i,o,c,d){let _=new DataView(s.inst.exports.memory.buffer),f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let h=new TextDecoder("utf-8").decode(f.slice(o,o+c)),{ret:p,filestat:u}=s.fds[r].path_filestat_get(i,h);return u?.write_bytes(_,d),p}else return 8},path_filestat_set_times(r,i,o,c,d,_,f){let h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let p=new TextDecoder("utf-8").decode(h.slice(o,o+c));return s.fds[r].path_filestat_set_times(i,p,d,_,f)}else return 8},path_link(r,i,o,c,d,_,f){let h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null&&s.fds[d]!=null){let p=new TextDecoder("utf-8").decode(h.slice(o,o+c)),u=new TextDecoder("utf-8").decode(h.slice(_,_+f)),{ret:m,inode_obj:b}=s.fds[r].path_lookup(p,i);return b==null?m:s.fds[d].path_link(u,b,!1)}else return 8},path_open(r,i,o,c,d,_,f,h,p){let u=new DataView(s.inst.exports.memory.buffer),m=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let b=new TextDecoder("utf-8").decode(m.slice(o,o+c));I.log(b);let{ret:E,fd_obj:S}=s.fds[r].path_open(i,b,d,_,f,h);if(E!=0)return E;s.fds.push(S);let N=s.fds.length-1;return u.setUint32(p,N,!0),0}else return 8},path_readlink(r,i,o,c,d,_){let f=new DataView(s.inst.exports.memory.buffer),h=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let p=new TextDecoder("utf-8").decode(h.slice(i,i+o));I.log(p);let{ret:u,data:m}=s.fds[r].path_readlink(p);if(m!=null){let b=new TextEncoder().encode(m);if(b.length>d)return f.setUint32(_,0,!0),8;h.set(b,c),f.setUint32(_,b.length,!0)}return u}else return 8},path_remove_directory(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_remove_directory(d)}else return 8},path_rename(r,i,o,c,d,_){let f=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null&&s.fds[c]!=null){let h=new TextDecoder("utf-8").decode(f.slice(i,i+o)),p=new TextDecoder("utf-8").decode(f.slice(d,d+_)),{ret:u,inode_obj:m}=s.fds[r].path_unlink(h);if(m==null)return u;if(u=s.fds[c].path_link(p,m,!0),u!=0&&s.fds[r].path_link(h,m,!0)!=0)throw"path_link should always return success when relinking an inode back to the original place";return u}else return 8},path_symlink(r,i,o,c,d){let _=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[o]!=null){let f=new TextDecoder("utf-8").decode(_.slice(r,r+i)),h=new TextDecoder("utf-8").decode(_.slice(c,c+d));return 58}else return 8},path_unlink_file(r,i,o){let c=new Uint8Array(s.inst.exports.memory.buffer);if(s.fds[r]!=null){let d=new TextDecoder("utf-8").decode(c.slice(i,i+o));return s.fds[r].path_unlink_file(d)}else return 8},poll_oneoff(r,i,o){if(o===0)return 28;if(o>1)return I.log("poll_oneoff: only a single subscription is supported"),58;let c=new DataView(s.inst.exports.memory.buffer),d=Re.read_bytes(c,r),_=d.eventtype,f=d.clockid,h=d.timeout;if(_!==Ze)return I.log("poll_oneoff: only clock subscriptions are supported"),58;let p;if(f===1)p=()=>BigInt(Math.round(performance.now()*1e6));else if(f===0)p=()=>BigInt(new Date().getTime())*1000000n;else return 28;let u=(d.flags&et)!==0?h:p()+h;for(;u>p(););return new Ee(d.userdata,0,_).write_bytes(c,i),0},proc_exit(r){throw new me(r)},proc_raise(r){throw"raised signal "+r},sched_yield(){},random_get(r,i){let o=new Uint8Array(s.inst.exports.memory.buffer).subarray(r,r+i);if("crypto"in globalThis&&(typeof SharedArrayBuffer>"u"||!(s.inst.exports.memory.buffer instanceof SharedArrayBuffer)))for(let c=0;c<i;c+=65536)crypto.getRandomValues(o.subarray(c,c+65536));else for(let c=0;c<i;c++)o[c]=Math.random()*256|0},sock_recv(r,i,o){throw"sockets not supported"},sock_send(r,i,o){throw"sockets not supported"},sock_shutdown(r,i){throw"sockets not supported"},sock_accept(r,i){throw"sockets not supported"}}}};var H=class{fd_allocate(e,t){return 58}fd_close(){return 0}fd_fdstat_get(){return{ret:58,fdstat:null}}fd_fdstat_set_flags(e){return 58}fd_fdstat_set_rights(e,t){return 58}fd_filestat_get(){return{ret:58,filestat:null}}fd_filestat_set_size(e){return 58}fd_filestat_set_times(e,t,n){return 58}fd_pread(e,t){return{ret:58,data:new Uint8Array}}fd_prestat_get(){return{ret:58,prestat:null}}fd_pwrite(e,t){return{ret:58,nwritten:0}}fd_read(e){return{ret:58,data:new Uint8Array}}fd_readdir_single(e){return{ret:58,dirent:null}}fd_seek(e,t){return{ret:58,offset:0n}}fd_sync(){return 0}fd_tell(){return{ret:58,offset:0n}}fd_write(e){return{ret:58,nwritten:0}}path_create_directory(e){return 58}path_filestat_get(e,t){return{ret:58,filestat:null}}path_filestat_set_times(e,t,n,a,s){return 58}path_link(e,t,n){return 58}path_unlink(e){return{ret:58,inode_obj:null}}path_lookup(e,t){return{ret:58,inode_obj:null}}path_open(e,t,n,a,s,r){return{ret:54,fd_obj:null}}path_readlink(e){return{ret:58,data:null}}path_remove_directory(e){return 58}path_rename(e,t,n){return 58}path_unlink_file(e){return 58}},D=class l{static issue_ino(){return l.next_ino++}static root_ino(){return 0n}constructor(){this.ino=l.issue_ino()}};D.next_ino=1n;var oe=class extends H{fd_allocate(e,t){if(!(this.file.size>e+t)){let n=new Uint8Array(Number(e+t));n.set(this.file.data,0),this.file.data=n}return 0}fd_fdstat_get(){return{ret:0,fdstat:new X(ie,0)}}fd_filestat_set_size(e){if(this.file.size>e)this.file.data=new Uint8Array(this.file.data.buffer.slice(0,Number(e)));else{let t=new Uint8Array(Number(e));t.set(this.file.data,0),this.file.data=t}return 0}fd_read(e){let t=this.file.data.slice(Number(this.file_pos),Number(this.file_pos+BigInt(e)));return this.file_pos+=BigInt(t.length),{ret:0,data:t}}fd_pread(e,t){return{ret:0,data:this.file.data.slice(Number(t),Number(t+BigInt(e)))}}fd_seek(e,t){let n;switch(t){case Ue:n=e;break;case Be:n=this.file_pos+e;break;case ve:n=BigInt(this.file.data.byteLength)+e;break;default:return{ret:28,offset:0n}}return n<0?{ret:28,offset:0n}:(this.file_pos=n,{ret:0,offset:this.file_pos})}fd_tell(){return{ret:0,offset:this.file_pos}}fd_write(e){if(this.file.readonly)return{ret:8,nwritten:0};if(this.file_pos+BigInt(e.byteLength)>this.file.size){let t=this.file.data;this.file.data=new Uint8Array(Number(this.file_pos+BigInt(e.byteLength))),this.file.data.set(t)}return this.file.data.set(e,Number(this.file_pos)),this.file_pos+=BigInt(e.byteLength),{ret:0,nwritten:e.byteLength}}fd_pwrite(e,t){if(this.file.readonly)return{ret:8,nwritten:0};if(t+BigInt(e.byteLength)>this.file.size){let n=this.file.data;this.file.data=new Uint8Array(Number(t+BigInt(e.byteLength))),this.file.data.set(n)}return this.file.data.set(e,Number(t)),{ret:0,nwritten:e.byteLength}}fd_filestat_get(){return{ret:0,filestat:this.file.stat()}}constructor(e){super(),this.file_pos=0n,this.file=e}},be=class extends H{fd_seek(e,t){return{ret:8,offset:0n}}fd_tell(){return{ret:8,offset:0n}}fd_allocate(e,t){return 8}fd_fdstat_get(){return{ret:0,fdstat:new X(L,0)}}fd_readdir_single(e){if(I.enabled&&(I.log("readdir_single",e),I.log(e,this.dir.contents.keys())),e==0n)return{ret:0,dirent:new ne(1n,this.dir.ino,".",L)};if(e==1n)return{ret:0,dirent:new ne(2n,this.dir.parent_ino(),"..",L)};if(e>=BigInt(this.dir.contents.size)+2n)return{ret:0,dirent:null};let[t,n]=Array.from(this.dir.contents.entries())[Number(e-2n)];return{ret:0,dirent:new ne(e+1n,n.ino,t,n.stat().filetype)}}path_filestat_get(e,t){let{ret:n,path:a}=Y.from(t);if(a==null)return{ret:n,filestat:null};let{ret:s,entry:r}=this.dir.get_entry_for_path(a);return r==null?{ret:s,filestat:null}:{ret:0,filestat:r.stat()}}path_lookup(e,t){let{ret:n,path:a}=Y.from(e);if(a==null)return{ret:n,inode_obj:null};let{ret:s,entry:r}=this.dir.get_entry_for_path(a);return r==null?{ret:s,inode_obj:null}:{ret:0,inode_obj:r}}path_open(e,t,n,a,s,r){let{ret:i,path:o}=Y.from(t);if(o==null)return{ret:i,fd_obj:null};let{ret:c,entry:d}=this.dir.get_entry_for_path(o);if(d==null){if(c!=44)return{ret:c,fd_obj:null};if((n&Se)==Se){let{ret:_,entry:f}=this.dir.create_entry_for_path(t,(n&ae)==ae);if(f==null)return{ret:_,fd_obj:null};d=f}else return{ret:44,fd_obj:null}}else if((n&We)==We)return{ret:20,fd_obj:null};return(n&ae)==ae&&d.stat().filetype!==L?{ret:54,fd_obj:null}:d.path_open(n,a,r)}path_create_directory(e){return this.path_open(0,e,Se|ae,0n,0n,0).ret}path_link(e,t,n){let{ret:a,path:s}=Y.from(e);if(s==null)return a;if(s.is_dir)return 44;let{ret:r,parent_entry:i,filename:o,entry:c}=this.dir.get_parent_dir_and_entry_for_path(s,!0);if(i==null||o==null)return r;if(c!=null){let d=t.stat().filetype==L,_=c.stat().filetype==L;if(d&&_)if(n&&c instanceof z){if(c.contents.size!=0)return 55}else return 20;else{if(d&&!_)return 54;if(!d&&_)return 31;if(!(t.stat().filetype==ie&&c.stat().filetype==ie))return 20}}return!n&&t.stat().filetype==L?63:(i.contents.set(o,t),0)}path_unlink(e){let{ret:t,path:n}=Y.from(e);if(n==null)return{ret:t,inode_obj:null};let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!0);return s==null||r==null?{ret:a,inode_obj:null}:i==null?{ret:44,inode_obj:null}:(s.contents.delete(r),{ret:0,inode_obj:i})}path_unlink_file(e){let{ret:t,path:n}=Y.from(e);if(n==null)return t;let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!1);return s==null||r==null||i==null?a:i.stat().filetype===L?31:(s.contents.delete(r),0)}path_remove_directory(e){let{ret:t,path:n}=Y.from(e);if(n==null)return t;let{ret:a,parent_entry:s,filename:r,entry:i}=this.dir.get_parent_dir_and_entry_for_path(n,!1);return s==null||r==null||i==null?a:!(i instanceof z)||i.stat().filetype!==L?54:i.contents.size!==0?55:s.contents.delete(r)?0:44}fd_filestat_get(){return{ret:0,filestat:this.dir.stat()}}fd_filestat_set_size(e){return 8}fd_read(e){return{ret:8,data:new Uint8Array}}fd_pread(e,t){return{ret:8,data:new Uint8Array}}fd_write(e){return{ret:8,nwritten:0}}fd_pwrite(e,t){return{ret:8,nwritten:0}}constructor(e){super(),this.dir=e}},ge=class extends be{fd_prestat_get(){return{ret:0,prestat:xe.dir(this.prestat_name)}}constructor(e,t){super(new z(t)),this.prestat_name=e}},q=class extends D{path_open(e,t,n){if(this.readonly&&(t&BigInt(64))==BigInt(64))return{ret:63,fd_obj:null};if((e&Ne)==Ne){if(this.readonly)return{ret:63,fd_obj:null};this.data=new Uint8Array([])}let a=new oe(this);return n&Me&&a.fd_seek(0n,ve),{ret:0,fd_obj:a}}get size(){return BigInt(this.data.byteLength)}stat(){return new Q(this.ino,ie,this.size)}constructor(e,t){super(),this.data=new Uint8Array(e),this.readonly=!!t?.readonly}},Y=class nt{static from(e){let t=new nt;if(t.is_dir=e.endsWith("/"),e.startsWith("/"))return{ret:76,path:null};if(e.includes("\0"))return{ret:28,path:null};for(let n of e.split("/"))if(!(n===""||n===".")){if(n===".."){if(t.parts.pop()==null)return{ret:76,path:null};continue}t.parts.push(n)}return{ret:0,path:t}}to_path_string(){let e=this.parts.join("/");return this.is_dir&&(e+="/"),e}constructor(){this.parts=[],this.is_dir=!1}},z=class l extends D{parent_ino(){return this.parent==null?D.root_ino():this.parent.ino}path_open(e,t,n){return{ret:0,fd_obj:new be(this)}}stat(){return new Q(this.ino,L,0n)}get_entry_for_path(e){let t=this;for(let n of e.parts){if(!(t instanceof l))return{ret:54,entry:null};let a=t.contents.get(n);if(a!==void 0)t=a;else return I.log(n),{ret:44,entry:null}}return e.is_dir&&t.stat().filetype!=L?{ret:54,entry:null}:{ret:0,entry:t}}get_parent_dir_and_entry_for_path(e,t){let n=e.parts.pop();if(n===void 0)return{ret:28,parent_entry:null,filename:null,entry:null};let{ret:a,entry:s}=this.get_entry_for_path(e);if(s==null)return{ret:a,parent_entry:null,filename:null,entry:null};if(!(s instanceof l))return{ret:54,parent_entry:null,filename:null,entry:null};let r=s.contents.get(n);return r===void 0?t?{ret:0,parent_entry:s,filename:n,entry:null}:{ret:44,parent_entry:null,filename:null,entry:null}:e.is_dir&&r.stat().filetype!=L?{ret:54,parent_entry:null,filename:null,entry:null}:{ret:0,parent_entry:s,filename:n,entry:r}}create_entry_for_path(e,t){let{ret:n,path:a}=Y.from(e);if(a==null)return{ret:n,entry:null};let{ret:s,parent_entry:r,filename:i,entry:o}=this.get_parent_dir_and_entry_for_path(a,!0);if(r==null||i==null)return{ret:s,entry:null};if(o!=null)return{ret:20,entry:null};I.log("create",a);let c;return t?c=new l(new Map):c=new q(new ArrayBuffer(0)),r.contents.set(i,c),o=c,{ret:0,entry:o}}constructor(e){super(),this.parent=null,e instanceof Array?this.contents=new Map(e):this.contents=e;for(let t of this.contents.values())t instanceof l&&(t.parent=this)}},ce=class l extends H{fd_filestat_get(){return{ret:0,filestat:new Q(this.ino,je,BigInt(0))}}fd_fdstat_get(){let e=new X(je,0);return e.fs_rights_base=BigInt(64),{ret:0,fdstat:e}}fd_write(e){return this.write(e),{ret:0,nwritten:e.byteLength}}static lineBuffered(e){let t=new TextDecoder("utf-8",{fatal:!1}),n="";return new l(a=>{n+=t.decode(a,{stream:!0});let s=n.split(`
`);for(let[r,i]of s.entries())r<s.length-1?e(i):n=i})}constructor(e){super(),this.ino=D.issue_ino(),this.write=e}};var qe=new DataView(new ArrayBuffer);function w(l){return qe.buffer!==l.buffer&&(qe=new DataView(l.buffer)),qe}function it(l){return l>>>0}var B=new TextDecoder("utf-8"),Ot=new TextEncoder("utf-8");function $(l,e,t){if(typeof l!="string")throw new TypeError("expected a string");if(l.length===0)return U=0,1;let n=0,a=0,s=0;for(;l.length>0;){a=e(a,n,1,n+l.length),n+=l.length;let{read:r,written:i}=Ot.encodeInto(l,new Uint8Array(t.buffer,a+s,n-s));s+=i,l=l.slice(r)}return n>s&&(a=e(a,n,1,s)),U=s,a}var U=0,le=class{constructor(){this.list=[],this.head=0}insert(e){this.head>=this.list.length&&this.list.push({next:this.list.length+1,val:void 0});let t=this.head,n=this.list[t];return this.head=n.next,n.next=-1,n.val=e,t}get(e){if(e>=this.list.length)throw new RangeError("handle index not valid");let t=this.list[e];if(t.next===-1)return t.val;throw new RangeError("handle index not valid")}remove(e){let t=this.get(e),n=this.list[e];return n.val=void 0,n.next=this.head,this.head=e,t}};function de(){throw new RangeError("invalid variant discriminant for bool")}var _e=class{constructor(){this._resource0_slab=new le}addToImports(e){"canonical_abi"in e||(e.canonical_abi={}),e.canonical_abi["resource_drop_rb-abi-value"]=t=>{this._resource0_slab.remove(t).drop()},e.canonical_abi["resource_clone_rb-abi-value"]=t=>{let n=this._resource0_slab.get(t);return this._resource0_slab.insert(n.clone())},e.canonical_abi["resource_get_rb-abi-value"]=t=>this._resource0_slab.get(t)._wasm_val,e.canonical_abi["resource_new_rb-abi-value"]=t=>{let n=this._registry0;return this._resource0_slab.insert(new K(t,this))}}async instantiate(e,t){if(t=t||{},this.addToImports(t),e instanceof WebAssembly.Instance)this.instance=e;else if(e instanceof WebAssembly.Module)this.instance=await WebAssembly.instantiate(e,t);else if(e instanceof ArrayBuffer||e instanceof Uint8Array){let{instance:n}=await WebAssembly.instantiate(e,t);this.instance=n}else{let{instance:n}=await WebAssembly.instantiateStreaming(e,t);this.instance=n}this._exports=this.instance.exports,this._registry0=new FinalizationRegistry(this._exports["canonical_abi_drop_rb-abi-value"])}rubyShowVersion(){this._exports["ruby-show-version: func() -> ()"]()}rubyInit(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=e,s=a.length,r=n(0,0,4,s*8);for(let i=0;i<a.length;i++){let o=a[i],c=r+i*8,d=$(o,n,t),_=U;w(t).setInt32(c+4,_,!0),w(t).setInt32(c+0,d,!0)}this._exports["ruby-init: func(args: list<string>) -> ()"](r,s)}rubyInitLoadpath(){this._exports["ruby-init-loadpath: func() -> ()"]()}rbEvalStringProtect(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=$(e,n,t),s=U,r=this._exports["rb-eval-string-protect: func(str: string) -> tuple<handle<rb-abi-value>, s32>"](a,s);return[this._resource0_slab.remove(w(t).getInt32(r+0,!0)),w(t).getInt32(r+4,!0)]}rbFuncallvProtect(e,t,n){let a=this._exports.memory,s=this._exports.cabi_realloc,r=e;if(!(r instanceof K))throw new TypeError("expected instance of RbAbiValue");let i=n,o=i.length,c=s(0,0,4,o*4);for(let _=0;_<i.length;_++){let f=i[_],h=c+_*4,p=f;if(!(p instanceof K))throw new TypeError("expected instance of RbAbiValue");w(a).setInt32(h+0,this._resource0_slab.insert(p.clone()),!0)}let d=this._exports["rb-funcallv-protect: func(recv: handle<rb-abi-value>, mid: u32, args: list<handle<rb-abi-value>>) -> tuple<handle<rb-abi-value>, s32>"](this._resource0_slab.insert(r.clone()),it(t),c,o);return[this._resource0_slab.remove(w(a).getInt32(d+0,!0)),w(a).getInt32(d+4,!0)]}rbIntern(e){let t=this._exports.memory,n=this._exports.cabi_realloc,a=$(e,n,t),s=U;return this._exports["rb-intern: func(name: string) -> u32"](a,s)>>>0}rbErrinfo(){let e=this._exports["rb-errinfo: func() -> handle<rb-abi-value>"]();return this._resource0_slab.remove(e)}rbClearErrinfo(){this._exports["rb-clear-errinfo: func() -> ()"]()}rstringPtr(e){let t=this._exports.memory,n=e;if(!(n instanceof K))throw new TypeError("expected instance of RbAbiValue");let a=this._exports["rstring-ptr: func(value: handle<rb-abi-value>) -> string"](this._resource0_slab.insert(n.clone())),s=w(t).getInt32(a+0,!0),r=w(t).getInt32(a+4,!0),i=B.decode(new Uint8Array(t.buffer,s,r));return this._exports["cabi_post_rstring-ptr"](a),i}rbVmBugreport(){this._exports["rb-vm-bugreport: func() -> ()"]()}rbGcEnable(){let t=this._exports["rb-gc-enable: func() -> bool"]();return t==0?!1:t==1?!0:de()}rbGcDisable(){let t=this._exports["rb-gc-disable: func() -> bool"]();return t==0?!1:t==1?!0:de()}rbSetShouldProhibitRewind(e){let n=this._exports["rb-set-should-prohibit-rewind: func(new-value: bool) -> bool"](e?1:0);return n==0?!1:n==1?!0:de()}},K=class{constructor(e,t){this._wasm_val=e,this._obj=t,this._refcnt=1,t._registry0.register(this,e,this)}clone(){return this._refcnt+=1,this}drop(){if(this._refcnt-=1,this._refcnt!==0)return;this._obj._registry0.unregister(this);let e=this._obj._exports["canonical_abi_drop_rb-abi-value"],t=this._wasm_val;delete this._obj,delete this._refcnt,delete this._wasm_val,e(t)}};function ot(l,e,t){"rb-js-abi-host"in l||(l["rb-js-abi-host"]={}),l["rb-js-abi-host"]["eval-js: func(code: string) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r){let i=t("memory"),o=a,c=s,d=B.decode(new Uint8Array(i.buffer,o,c)),f=e.evalJs(d);switch(f.tag){case"success":{let h=f.val;w(i).setInt8(r+0,0,!0),w(i).setInt32(r+4,n.insert(h),!0);break}case"failure":{let h=f.val;w(i).setInt8(r+0,1,!0),w(i).setInt32(r+4,n.insert(h),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["is-js: func(value: handle<js-abi-value>) -> bool"]=function(a){return e.isJs(n.get(a))?1:0},l["rb-js-abi-host"]["instance-of: func(value: handle<js-abi-value>, klass: handle<js-abi-value>) -> bool"]=function(a,s){return e.instanceOf(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["global-this: func() -> handle<js-abi-value>"]=function(){let a=e.globalThis();return n.insert(a)},l["rb-js-abi-host"]["int-to-js-number: func(value: s32) -> handle<js-abi-value>"]=function(a){let s=e.intToJsNumber(a);return n.insert(s)},l["rb-js-abi-host"]["float-to-js-number: func(value: float64) -> handle<js-abi-value>"]=function(a){let s=e.floatToJsNumber(a);return n.insert(s)},l["rb-js-abi-host"]["string-to-js-string: func(value: string) -> handle<js-abi-value>"]=function(a,s){let r=t("memory"),i=a,o=s,c=B.decode(new Uint8Array(r.buffer,i,o)),d=e.stringToJsString(c);return n.insert(d)},l["rb-js-abi-host"]["bool-to-js-bool: func(value: bool) -> handle<js-abi-value>"]=function(a){let s=a,r=e.boolToJsBool(s==0?!1:s==1?!0:de());return n.insert(r)},l["rb-js-abi-host"]["proc-to-js-function: func(value: u32) -> handle<js-abi-value>"]=function(a){let s=e.procToJsFunction(a>>>0);return n.insert(s)},l["rb-js-abi-host"]["rb-object-to-js-rb-value: func(raw-rb-abi-value: u32) -> handle<js-abi-value>"]=function(a){let s=e.rbObjectToJsRbValue(a>>>0);return n.insert(s)},l["rb-js-abi-host"]["js-value-to-string: func(value: handle<js-abi-value>) -> string"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),o=e.jsValueToString(n.get(a)),c=$(o,i,r),d=U;w(r).setInt32(s+4,d,!0),w(r).setInt32(s+0,c,!0)},l["rb-js-abi-host"]["js-value-to-integer: func(value: handle<js-abi-value>) -> variant { as-float(float64), bignum(string) }"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),c=e.jsValueToInteger(n.get(a));switch(c.tag){case"as-float":{let d=c.val;w(r).setInt8(s+0,0,!0),w(r).setFloat64(s+8,+d,!0);break}case"bignum":{let d=c.val;w(r).setInt8(s+0,1,!0);let _=$(d,i,r),f=U;w(r).setInt32(s+12,f,!0),w(r).setInt32(s+8,_,!0);break}default:throw new RangeError("invalid variant specified for RawInteger")}},l["rb-js-abi-host"]["export-js-value-to-host: func(value: handle<js-abi-value>) -> ()"]=function(a){e.exportJsValueToHost(n.get(a))},l["rb-js-abi-host"]["import-js-value-from-host: func() -> handle<js-abi-value>"]=function(){let a=e.importJsValueFromHost();return n.insert(a)},l["rb-js-abi-host"]["js-value-typeof: func(value: handle<js-abi-value>) -> string"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),o=e.jsValueTypeof(n.get(a)),c=$(o,i,r),d=U;w(r).setInt32(s+4,d,!0),w(r).setInt32(s+0,c,!0)},l["rb-js-abi-host"]["js-value-equal: func(lhs: handle<js-abi-value>, rhs: handle<js-abi-value>) -> bool"]=function(a,s){return e.jsValueEqual(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["js-value-strictly-equal: func(lhs: handle<js-abi-value>, rhs: handle<js-abi-value>) -> bool"]=function(a,s){return e.jsValueStrictlyEqual(n.get(a),n.get(s))?1:0},l["rb-js-abi-host"]["reflect-apply: func(target: handle<js-abi-value>, this-argument: handle<js-abi-value>, arguments: list<handle<js-abi-value>>) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i,o){let c=t("memory"),d=i,_=r,f=[];for(let u=0;u<d;u++){let m=_+u*4;f.push(n.get(w(c).getInt32(m+0,!0)))}let p=e.reflectApply(n.get(a),n.get(s),f);switch(p.tag){case"success":{let u=p.val;w(c).setInt8(o+0,0,!0),w(c).setInt32(o+4,n.insert(u),!0);break}case"failure":{let u=p.val;w(c).setInt8(o+0,1,!0),w(c).setInt32(o+4,n.insert(u),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-construct: func(target: handle<js-abi-value>, arguments: list<handle<js-abi-value>>) -> handle<js-abi-value>"]=function(a,s,r){let i=t("memory"),o=r,c=s,d=[];for(let f=0;f<o;f++){let h=c+f*4;d.push(n.get(w(i).getInt32(h+0,!0)))}let _=e.reflectConstruct(n.get(a),d);return n.insert(_)},l["rb-js-abi-host"]["reflect-delete-property: func(target: handle<js-abi-value>, property-key: string) -> bool"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c));return e.reflectDeleteProperty(n.get(a),d)?1:0},l["rb-js-abi-host"]["reflect-get: func(target: handle<js-abi-value>, property-key: string) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i){let o=t("memory"),c=s,d=r,_=B.decode(new Uint8Array(o.buffer,c,d)),h=e.reflectGet(n.get(a),_);switch(h.tag){case"success":{let p=h.val;w(o).setInt8(i+0,0,!0),w(o).setInt32(i+4,n.insert(p),!0);break}case"failure":{let p=h.val;w(o).setInt8(i+0,1,!0),w(o).setInt32(i+4,n.insert(p),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-get-own-property-descriptor: func(target: handle<js-abi-value>, property-key: string) -> handle<js-abi-value>"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c)),_=e.reflectGetOwnPropertyDescriptor(n.get(a),d);return n.insert(_)},l["rb-js-abi-host"]["reflect-get-prototype-of: func(target: handle<js-abi-value>) -> handle<js-abi-value>"]=function(a){let s=e.reflectGetPrototypeOf(n.get(a));return n.insert(s)},l["rb-js-abi-host"]["reflect-has: func(target: handle<js-abi-value>, property-key: string) -> bool"]=function(a,s,r){let i=t("memory"),o=s,c=r,d=B.decode(new Uint8Array(i.buffer,o,c));return e.reflectHas(n.get(a),d)?1:0},l["rb-js-abi-host"]["reflect-is-extensible: func(target: handle<js-abi-value>) -> bool"]=function(a){return e.reflectIsExtensible(n.get(a))?1:0},l["rb-js-abi-host"]["reflect-own-keys: func(target: handle<js-abi-value>) -> list<handle<js-abi-value>>"]=function(a,s){let r=t("memory"),i=t("cabi_realloc"),c=e.reflectOwnKeys(n.get(a)),d=c.length,_=i(0,0,4,d*4);for(let f=0;f<c.length;f++){let h=c[f],p=_+f*4;w(r).setInt32(p+0,n.insert(h),!0)}w(r).setInt32(s+4,d,!0),w(r).setInt32(s+0,_,!0)},l["rb-js-abi-host"]["reflect-prevent-extensions: func(target: handle<js-abi-value>) -> bool"]=function(a){return e.reflectPreventExtensions(n.get(a))?1:0},l["rb-js-abi-host"]["reflect-set: func(target: handle<js-abi-value>, property-key: string, value: handle<js-abi-value>) -> variant { success(handle<js-abi-value>), failure(handle<js-abi-value>) }"]=function(a,s,r,i,o){let c=t("memory"),d=s,_=r,f=B.decode(new Uint8Array(c.buffer,d,_)),p=e.reflectSet(n.get(a),f,n.get(i));switch(p.tag){case"success":{let u=p.val;w(c).setInt8(o+0,0,!0),w(c).setInt32(o+4,n.insert(u),!0);break}case"failure":{let u=p.val;w(c).setInt8(o+0,1,!0),w(c).setInt32(o+4,n.insert(u),!0);break}default:throw new RangeError("invalid variant specified for JsAbiResult")}},l["rb-js-abi-host"]["reflect-set-prototype-of: func(target: handle<js-abi-value>, prototype: handle<js-abi-value>) -> bool"]=function(a,s){return e.reflectSetPrototypeOf(n.get(a),n.get(s))?1:0},"canonical_abi"in l||(l.canonical_abi={});let n=new le;l.canonical_abi["resource_drop_js-abi-value"]=a=>{let s=n.remove(a);e.dropJsAbiValue&&e.dropJsAbiValue(s)}}var Ae=class extends _e{async setInstance(e){await this.instantiate(e)}},Ce=class{constructor(){}setUnderlying(e){this.underlying=e}rubyShowVersion(){this.underlying.rubyShowVersion()}rubyInit(e){this.underlying.rubyInit(e)}rubyInitLoadpath(){this.underlying.rubyInitLoadpath()}rbEvalStringProtect(e){return this.underlying.rbEvalStringProtect(e)}rbFuncallvProtect(e,t,n){return this.underlying.rbFuncallvProtect(e,t,n)}rbIntern(e){return this.underlying.rbIntern(e)}rbErrinfo(){return this.underlying.rbErrinfo()}rbClearErrinfo(){return this.underlying.rbClearErrinfo()}rstringPtr(e){return this.underlying.rstringPtr(e)}rbVmBugreport(){this.underlying.rbVmBugreport()}rbGcEnable(){return this.underlying.rbGcEnable()}rbGcDisable(){return this.underlying.rbGcDisable()}rbSetShouldProhibitRewind(e){return this.underlying.rbSetShouldProhibitRewind(e)}async setInstance(e){}addToImports(e){}};var Le=class l{static async instantiateModule(e){var t,n;let{module:a,wasip1:s}=e,r=new l,i={wasi_snapshot_preview1:s.wasiImport};r.addToImports(i),(t=e.addToImports)===null||t===void 0||t.call(e,i);let o=await WebAssembly.instantiate(a,i);try{await r.setInstance(o)}catch(c){throw console.error('Failed to instantiate Ruby VM. Please make sure that you have added `gem "js"` to your Gemfile.'),c}return(n=e.setMemory)===null||n===void 0||n.call(e,o.exports.memory),s.initialize(o),r.initialize(e.args),{vm:r,instance:o}}static async instantiateComponent(e){let t;return"getCoreModule"in e?t=async a=>{let{instantiate:s,getCoreModule:r,wasip2:i}=e,{cli:o,clocks:c,filesystem:d,io:_,random:f,sockets:h,http:p}=i,u=e.env?Object.assign(Object.assign({},o.environment),{getEnvironment:()=>{var E;return Array.from(new Map([...o.environment.getEnvironment(),...Object.entries((E=e.env)!==null&&E!==void 0?E:{})]).entries())}}):o.environment,m={"ruby:js/js-runtime":a,"wasi:cli/environment":u,"wasi:cli/exit":o.exit,"wasi:cli/stderr":o.stderr,"wasi:cli/stdin":o.stdin,"wasi:cli/stdout":o.stdout,"wasi:cli/terminal-input":o.terminalInput,"wasi:cli/terminal-output":o.terminalOutput,"wasi:cli/terminal-stderr":o.terminalStderr,"wasi:cli/terminal-stdin":o.terminalStdin,"wasi:cli/terminal-stdout":o.terminalStdout,"wasi:clocks/monotonic-clock":c.monotonicClock,"wasi:clocks/wall-clock":c.wallClock,"wasi:filesystem/preopens":d.preopens,"wasi:filesystem/types":d.types,"wasi:io/error":_.error,"wasi:io/poll":_.poll,"wasi:io/streams":_.streams,"wasi:random/random":f.random,"wasi:sockets/tcp":h.tcp,"wasi:http/types":p.types,"wasi:http/incoming-handler":p.incomingHandler,"wasi:http/outgoing-handler":p.outgoingHandler};return(await s(r,m,e.instantiateCore)).rubyRuntime}:t=e.instantiate,{vm:await this._instantiate({},t)}}constructor(e){this.instance=null,this.interfaceState={hasJSFrameAfterRbFrame:!1};let t=n=>{let a=["setInstance","addToImports","instantiate","rbSetShouldProhibitRewind","rbGcDisable","rbGcEnable"],s=["constructor"].concat(a);for(let r of Object.getOwnPropertyNames(_e.prototype)){if(s.includes(r))continue;let i=n[r];typeof i=="function"&&(n[r]=(...o)=>{if(this.interfaceState.hasJSFrameAfterRbFrame){let d=this.guest.rbSetShouldProhibitRewind(!0),_=this.guest.rbGcDisable(),f=Reflect.apply(i,n,o);return this.guest.rbSetShouldProhibitRewind(d),_||this.guest.rbGcEnable(),f}else return Reflect.apply(i,n,o)})}return n};this.guest=t(e??new Ae),this.transport=new $e,this.exceptionFormatter=new Ke}static async _instantiate(e,t){let n=new Ce,a=new l(n);class s{constructor(c){this.underlying=c}}let r=a.getImports(o=>new s(o),o=>o.underlying),i=await t(Object.assign(Object.assign({},r),{throwProhibitRewindException:o=>{a.throwProhibitRewindException(o)},procToJsFunction:()=>{let o=new J(i.exportRbValueToJs(),a,a.privateObject());return new s((...c)=>o.call("call",...c.map(d=>a.wrap(d))).toJS())},rbObjectToJsRbValue:()=>{let o=new J(i.exportRbValueToJs(),a,a.privateObject());return new s(o)},JsAbiValue:s}));return n.setUnderlying(i),a.initialize(e.args),a}initialize(e=["ruby.wasm","-EUTF-8","-e_=0"]){let t=e.map(n=>n+"\0");this.guest.rubyInit(t);try{this.eval(`
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
`+this.exceptionFormatter.format(n,this,this.privateObject())),new Ge(t)}getImports(e,t){let n=s=>{for(let[r,i]of Object.entries(s))typeof i=="function"&&(s[r]=(...o)=>{let c=this.interfaceState.hasJSFrameAfterRbFrame;this.interfaceState.hasJSFrameAfterRbFrame=!0;let d=Reflect.apply(i,s,o);return this.interfaceState.hasJSFrameAfterRbFrame=c,d});return s};function a(s){return(...r)=>{try{return{tag:"success",val:s(...r)}}catch(i){if(i instanceof Ge)throw i;return{tag:"failure",val:e(i)}}}}return n({evalJs:a(s=>e(Function(s)())),isJs:s=>!0,globalThis:()=>{if(typeof globalThis<"u")return e(globalThis);if(typeof global<"u")return e(global);if(typeof window<"u")return e(window);throw new Error("unable to locate global object")},intToJsNumber:s=>e(s),floatToJsNumber:s=>e(s),stringToJsString:s=>e(s),boolToJsBool:s=>e(s),procToJsFunction:s=>{let r=this.rbValueOfPointer(s);return e((...i)=>r.call("call",...i.map(o=>this.wrap(o))).toJS())},rbObjectToJsRbValue:s=>e(this.rbValueOfPointer(s)),jsValueToString:s=>(s=t(s),String(s)),jsValueToInteger(s){return s=t(s),typeof s=="number"?{tag:"as-float",val:s}:typeof s=="bigint"?{tag:"bignum",val:BigInt(s).toString(10)+"\0"}:typeof s=="string"?{tag:"bignum",val:s+"\0"}:typeof s>"u"?{tag:"as-float",val:0}:{tag:"as-float",val:Number(s)}},exportJsValueToHost:s=>{this.transport.takeJsValue(t(s))},importJsValueFromHost:()=>e(this.transport.consumeJsValue()),instanceOf:(s,r)=>(r=t(r),typeof r=="function"?t(s)instanceof r:!1),jsValueTypeof(s){return typeof t(s)},jsValueEqual(s,r){return t(s)==t(r)},jsValueStrictlyEqual(s,r){return t(s)===t(r)},reflectApply:a((s,r,i)=>{let o=i.map(c=>t(c));return e(Reflect.apply(t(s),t(r),o))}),reflectConstruct:function(s,r){throw new Error("Function not implemented.")},reflectDeleteProperty:function(s,r){throw new Error("Function not implemented.")},reflectGet:a((s,r)=>e(t(s)[r])),reflectGetOwnPropertyDescriptor:function(s,r){throw new Error("Function not implemented.")},reflectGetPrototypeOf:function(s){throw new Error("Function not implemented.")},reflectHas:function(s,r){throw new Error("Function not implemented.")},reflectIsExtensible:function(s){throw new Error("Function not implemented.")},reflectOwnKeys:function(s){throw new Error("Function not implemented.")},reflectPreventExtensions:function(s){throw new Error("Function not implemented.")},reflectSet:a((s,r,i)=>e(Reflect.set(t(s),r,t(i)))),reflectSetPrototypeOf:function(s,r){throw new Error("Function not implemented.")}})}printVersion(){this.guest.rubyShowVersion()}eval(e){return Fe(this,this.privateObject(),e)}evalAsync(e){let t=this.eval("require 'js'; JS");return _t(this,this.privateObject(),n=>{t.call("__eval_async_rb",this.wrap(e),n)})}wrap(e){return this.transport.importJsValue(e,this)}privateObject(){return{transport:this.transport,exceptionFormatter:this.exceptionFormatter}}rbValueOfPointer(e){let t=new K(e,this.guest);return new J(t,this,this.privateObject())}},$e=class{constructor(){this._takenJsValue=null}takeJsValue(e){this._takenJsValue=e}consumeJsValue(){return this._takenJsValue}exportJsValue(e){return e.call("__export_to_js"),this._takenJsValue}importJsValue(e,t){return this._takenJsValue=e,t.eval('require "js"; JS::Object').call("__import_from_js")}},J=class l{constructor(e,t,n){this.inner=e,this.vm=t,this.privateObject=n}call(e,...t){let n=t.map(a=>a.inner);return new l(ct(this.vm,this.privateObject,this.inner,e,n),this.vm,this.privateObject)}callAsync(e,...t){let n=this.vm.eval("require 'js'; JS");return _t(this.vm,this.privateObject,a=>{n.call("__call_async_method",this,this.vm.wrap(e),a,...t)})}[Symbol.toPrimitive](e){return e==="string"||e==="default"?this.toString():null}toString(){let e=ct(this.vm,this.privateObject,this.inner,"to_s",[]);return this.vm.guest.rstringPtr(e)}toJS(){let t=this.vm.eval("JS").call("try_convert",this);return t.call("nil?").toString()==="true"?null:this.privateObject.transport.exportJsValue(t)}},G;(function(l){l[l.None=0]="None",l[l.Return=1]="Return",l[l.Break=2]="Break",l[l.Next=3]="Next",l[l.Retry=4]="Retry",l[l.Redo=5]="Redo",l[l.Raise=6]="Raise",l[l.Throw=7]="Throw",l[l.Fatal=8]="Fatal",l[l.Mask=15]="Mask"})(G||(G={}));var Ke=class{constructor(){this.literalsCache=null,this.isFormmatting=!1}format(e,t,n){class a extends Error{}if(this.isFormmatting)throw new a("Unexpected exception occurred during formatting exception message");this.isFormmatting=!0;try{return this._format(e,t,n)}finally{this.isFormmatting=!1}}_format(e,t,n){let[a,s,r]=(()=>{if(this.literalsCache==null){let d=[Fe(t,n,"0"),Fe(t,n,"1"),Fe(t,n,`"
"`)];return this.literalsCache=d,d}else return this.literalsCache})(),i,o,c;try{i=e.call("class").toString()}catch{i="unknown"}try{c=e.call("message").toString()}catch{c="unknown"}try{o=e.call("backtrace")}catch{return this.formatString(i,c)}if(o.call("nil?").toString()==="true")return this.formatString(i,c);try{let d=o.call("at",a),_=o.call("drop",s).call("join",r);return this.formatString(i,c,[d.toString(),_.toString()])}catch{return this.formatString(i,c)}}formatString(e,t,n){return n?`${n[0]}: ${t} (${e})
${n[1]}`:`${e}: ${t}`}},lt=(l,e,t)=>{switch(l&G.Mask){case G.None:break;case G.Return:throw new F("unexpected return");case G.Next:throw new F("unexpected next");case G.Break:throw new F("unexpected break");case G.Redo:throw new F("unexpected redo");case G.Retry:throw new F("retry outside of rescue clause");case G.Throw:throw new F("unexpected throw");case G.Raise:case G.Fatal:let n=new J(e.guest.rbErrinfo(),e,t);throw n.call("nil?").toString()==="true"?new F("no exception object"):(e.guest.rbClearErrinfo(),new F(t.exceptionFormatter.format(n,e,t)));default:throw new F(`unknown error tag: ${l}`)}};function dt(l,e){try{return e()}catch(t){if(t instanceof F)throw t;try{l.guest.rbVmBugreport()}catch(n){console.error("Tried to report internal Ruby VM state but failed: ",n)}if(t instanceof WebAssembly.RuntimeError&&t.message==="unreachable"){let n=new F(`Something went wrong in Ruby VM: ${t}`);throw n.stack=t.stack,n}else throw t}}var ct=(l,e,t,n,a)=>{let s=l.guest.rbIntern(n+"\0");return dt(l,()=>{let[r,i]=l.guest.rbFuncallvProtect(t,s,a);return lt(i,l,e),r})},Fe=(l,e,t)=>dt(l,()=>{let[n,a]=l.guest.rbEvalStringProtect(t+"\0");return lt(a,l,e),new J(n,l,e)});function _t(l,e,t){return new Promise((n,a)=>{let s=l.wrap({resolve:n,reject:r=>{let i=new F(e.exceptionFormatter.format(r,l,e));a(i)}});t(s)})}var F=class extends Error{constructor(e){super(e)}},Ge=class extends F{constructor(e){super("Ruby Fatal Error: "+e)}};var ft=[32,64,48,64,32,80,48,80,64,0,48,64,32,80,48,80,32,64,80,0,32,80,48,80,64,0,80,0,32,80,48,80,32,64,48,64,32,80,80,16,64,0,48,64,32,80,80,16,32,64,80,0,32,80,80,16,64,0,80,0,32,80,80,16,32,64,48,64,64,16,48,80,64,0,48,64,64,16,48,80,32,64,80,0,64,16,48,80,64,0,80,0,64,16,48,80,32,64,48,64,64,16,80,16,64,0,48,64,64,16,80,16,32,64,80,0,64,16,80,16,64,0,80,0,64,16,80,16,0,64,16,64,0,80,16,80,0,64,80,0,0,80,16,80,0,64,16,64,0,80,80,16,0,64,80,0,0,80,80,16,32,32,48,32,32,48,48,48,32,32,48,32,32,48,80,16,32,32,48,32,64,16,48,48,32,32,48,32,64,16,80,16,64,64,80,64,64,80,80,80,64,64,80,64,64,16,80,80,64,0,80,64,64,80,80,80,64,0,80,64,64,16,80,80,32,96,48,96,32,112,48,112,64,0,48,96,32,112,48,112,32,96,80,0,32,112,48,112,64,0,80,0,32,112,48,112,0,64,80,64,0,80,80,80,32,32,48,32,32,112,48,112,0,32,16,32,0,48,16,48,0,32,16,32,0,48,80,16,64,32,80,32,64,48,80,48,64,32,80,32,64,16,80,48,64,96,80,96,64,112,80,112,64,0,80,96,64,112,80,112,0,96,16,96,0,112,16,112,0,96,80,0,0,112,16,112,0,32,80,32,0,48,80,48],ee=640,te=480;function P(l,e){let t=document.createElement("canvas");return t.width=Math.max(1,l|0),t.height=Math.max(1,e|0),t}var we={\u5B8B\u4F53:'"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", "Noto Serif SC", serif',simsun:'"GameSong", "Songti SC", "SimSun", "Noto Serif CJK SC", serif',\u9ED1\u4F53:'"GameSong", "PingFang SC", "Microsoft YaHei", sans-serif',arial:'Arial, Helvetica, "GameSong", sans-serif',"arial black":'"Arial Black", Arial, "GameSong", sans-serif'};function Tt(l){let e=String(l||"").split("").filter(Boolean);for(let t of e){let n=t.toLowerCase();if(we[t])return we[t];if(we[n])return we[n]}return we.\u5B8B\u4F53}var ke=class{constructor(e){this.canvas=e.canvas,this.ctx=this.canvas.getContext("2d"),this.images=e.images,this.audioFiles=e.audioFiles,this.fs=e.fs,this.storage=e.storage,this.ui=e.ui,this.bmps=new Map,this.nextBmp=1,this.tilemaps=new Map,this.frozen=null,this.trans=null,this.lastFrameTime=0,this.keysHeld=new Set,this.touchHeld=new Set,this.dirOrder=[],this.latched=new Set,this.frameCount=0,this.fpsSamples=[],this.resetRequested=!1,this.measureCtx=P(4,4).getContext("2d"),this.tmp=P(64,64),this.tmpCtx=this.tmp.getContext("2d"),this.tmp2=P(64,64),this.tmp2Ctx=this.tmp2.getContext("2d"),this.vpCanvas=P(ee,te),this.vpCtx=this.vpCanvas.getContext("2d"),this.screenBuf=P(ee,te),this.screenCtx=this.screenBuf.getContext("2d"),this.audio=new Je(this.audioFiles),this.ctx.imageSmoothingEnabled=!1,this.lastList=[]}_reg(e){let t=this.nextBmp++,n=e.getContext("2d",{willReadFrequently:!1});return n.imageSmoothingEnabled=!1,this.bmps.set(t,{c:e,x:n,ver:0,at:null}),t}_b(e){return this.bmps.get(e)}findImage(e){let t=String(e).replace(/\\/g,"/").toLowerCase();if(this.images.has(t))return this.images.get(t);let n=t.replace(/\.(png|jpg|jpeg|bmp)$/,"");return this.images.has(n)?this.images.get(n):null}bmpNew(e,t){return this._reg(P(e,t))}bmpLoad(e){let t=this.findImage(e);if(!t)return-1;let n=P(t.width,t.height);return n.getContext("2d").drawImage(t,0,0),this._reg(n)}bmpClone(e){let t=this._b(e);if(!t)return this.bmpNew(1,1);let n=P(t.c.width,t.c.height);return n.getContext("2d").drawImage(t.c,0,0),this._reg(n)}bmpW(e){let t=this._b(e);return t?t.c.width:0}bmpH(e){let t=this._b(e);return t?t.c.height:0}bmpDispose(e){this.bmps.delete(e)}bmpDisposeList(e){for(let t of String(e).split(","))t&&this.bmps.delete(+t)}_touch(e){e.ver++,e.at=null}bmpBlt(e,t,n,a,s,r,i,o,c){let d=this._b(e),_=this._b(a);!d||!_||i<=0||o<=0||c<=0||(d.x.globalAlpha=Math.min(1,c/255),e===a?(this._ensureTmp(i,o),this.tmpCtx.clearRect(0,0,i,o),this.tmpCtx.drawImage(_.c,s,r,i,o,0,0,i,o),d.x.drawImage(this.tmp,0,0,i,o,t,n,i,o)):d.x.drawImage(_.c,s,r,i,o,t,n,i,o),d.x.globalAlpha=1,this._touch(d))}bmpStretch(e,t,n,a,s,r,i,o,c,d,_){let f=this._b(e),h=this._b(r);!f||!h||c<=0||d<=0||a<=0||s<=0||_<=0||(f.x.globalAlpha=Math.min(1,_/255),f.x.imageSmoothingEnabled=!0,f.x.drawImage(h.c,i,o,c,d,t,n,a,s),f.x.imageSmoothingEnabled=!1,f.x.globalAlpha=1,this._touch(f))}bmpFill(e,t,n,a,s,r,i,o,c){let d=this._b(e);!d||a<=0||s<=0||(d.x.clearRect(t,n,a,s),c>0&&(d.x.fillStyle=`rgba(${r|0},${i|0},${o|0},${c/255})`,d.x.fillRect(t,n,a,s)),this._touch(d))}bmpClear(e){let t=this._b(e);t&&(t.x.clearRect(0,0,t.c.width,t.c.height),this._touch(t))}bmpGetPixel(e,t,n){let a=this._b(e);if(!a||t<0||n<0||t>=a.c.width||n>=a.c.height)return"0,0,0,0";let s=a.x.getImageData(t,n,1,1).data;return`${s[0]},${s[1]},${s[2]},${s[3]}`}bmpSetPixel(e,t,n,a,s,r,i){let o=this._b(e);if(!o)return;let c=o.x.createImageData(1,1);c.data[0]=a,c.data[1]=s,c.data[2]=r,c.data[3]=i,o.x.putImageData(c,t,n),this._touch(o)}bmpHue(e,t){let n=this._b(e);if(!n||!t)return;let a=n.c.width,s=n.c.height,r=n.x.getImageData(0,0,a,s),i=r.data,o=(t%360+360)%360;for(let c=0;c<i.length;c+=4){if(i[c+3]===0)continue;let d=i[c]/255,_=i[c+1]/255,f=i[c+2]/255,h=Math.max(d,_,f),p=Math.min(d,_,f),u=h,m=h-p;if(m===0)continue;let b=m/h,E;h===d?E=(_-f)/m%6:h===_?E=(f-d)/m+2:E=(d-_)/m+4,E=E*60+o,E=(E%360+360)%360;let S=u*b,N=S*(1-Math.abs(E/60%2-1)),T=u-S,O,A,C;E<60?[O,A,C]=[S,N,0]:E<120?[O,A,C]=[N,S,0]:E<180?[O,A,C]=[0,S,N]:E<240?[O,A,C]=[0,N,S]:E<300?[O,A,C]=[N,0,S]:[O,A,C]=[S,0,N],i[c]=(O+T)*255,i[c+1]=(A+T)*255,i[c+2]=(C+T)*255}n.x.putImageData(r,0,0),this._touch(n)}_font(e,t,n,a){return`${a?"italic ":""}${n?"bold ":""}${t}px ${Tt(e)}`}_isSong(e){let t=String(e||"").split(",")[0].trim().toLowerCase();return t===""||t==="\u5B8B\u4F53"||t==="simsun"||t==="\u65B0\u5B8B\u4F53"||t==="nsimsun"}_cellW(e,t){return e.codePointAt(0)<128?Math.round(t/2):t}textSize(e,t,n,a,s){if(e=String(e),this._isSong(t)){let i=0;for(let o of e)i+=this._cellW(o,n);return i}let r=this.measureCtx;return r.font=this._font(t,n,a,s),Math.ceil(r.measureText(e).width)}bmpText(e,t,n,a,s,r,i,o,c,d,_,f,h,p,u){let m=this._b(e);if(!m||(r=String(r),!r.length||u<=0))return;let b=m.x;b.font=this._font(o,c,d,_),b.fillStyle=`rgba(${f|0},${h|0},${p|0},${u/255})`,b.textBaseline="middle";let E=this._isSong(o),S=E?[...r]:null,N=E?S.reduce((W,k)=>W+this._cellW(k,c),0):b.measureText(r).width,T=1;a>0&&N>a&&(T=Math.max(.4,a/N));let O=N*T,A=t;i===1?A=t+(a-O)/2:i===2&&(A=t+a-O);let C=Math.round(n+s/2+1);if(b.save(),b.beginPath(),b.rect(t,n,Math.max(a,O),s),b.clip(),!E)T!==1?(b.translate(A,0),b.scale(T,1),b.fillText(r,0,C)):b.fillText(r,Math.round(A),C);else{b.translate(Math.round(A),0),T!==1&&b.scale(T,1);let W=0;for(let k of S){let j=this._cellW(k,c);if(k!==" "&&k!=="\u3000"){let De=b.measureText(k).width;De>j+.5?(b.save(),b.translate(W,0),b.scale(j/De,1),b.fillText(k,0,C),b.restore()):b.fillText(k,W+(j-De)/2,C)}W+=j}}b.restore(),this._touch(m)}_ensureTmp(e,t){(this.tmp.width<e||this.tmp.height<t)&&(this.tmp.width=Math.max(this.tmp.width,e),this.tmp.height=Math.max(this.tmp.height,t),this.tmpCtx.imageSmoothingEnabled=!1)}_ensureTmp2(e,t){(this.tmp2.width<e||this.tmp2.height<t)&&(this.tmp2.width=Math.max(this.tmp2.width,e),this.tmp2.height=Math.max(this.tmp2.height,t),this.tmp2Ctx.imageSmoothingEnabled=!1)}tmConfig(e,t,n,a,s,r,i,o){let c=this.tilemaps.get(e)||{};c.tileset=t,c.autotiles=String(n).split(",").map(Number),c.xs=a,c.ys=s,c.zs=r,c.data=i?Int16Array.from(String(i).split(","),Number):null,c.prio=o?Int16Array.from(String(o).split(","),Number):null,c.cache=new Map,this.tilemaps.set(e,c)}tmDispose(e){this.tilemaps.delete(e)}_tileCanvas(e,t,n){if(t>=384){let d=this._b(e.tileset);if(!d)return null;let _=t-384;return[d.c,_%8*32,(_/8|0)*32]}let a=(t/48|0)-1,s=this._b(e.autotiles[a]);if(!s||a<0)return null;let r=Math.max(1,s.c.width/96|0),i=s.c.height===32?0:n%r,o=t*8+i,c=e.cache.get(o);if(!c){c=P(32,32);let d=c.getContext("2d");if(s.c.height===32)d.drawImage(s.c,n%Math.max(1,s.c.width/32|0)*32,0,32,32,0,0,32,32);else{let _=t%48;for(let f=0;f<4;f++){let h=ft[(_*4+f)*2]+i*96,p=ft[(_*4+f)*2+1];d.drawImage(s.c,h,p,16,16,f%2*16,(f/2|0)*16,16,16)}}e.cache.set(o,c)}return[c,0,0]}_tilemapItems(e,t){let n=this.tilemaps.get(e[2]);if(!n||!n.data)return;let a=e[3],s=e[4],r=e[5],i=e[7],o=Math.floor(a/32),c=Math.floor(s/32),d=22,_=17,f=[],h=new Map,p=n.xs,u=n.ys,m=n.zs;for(let S=c;S<c+_;S++)if(!(S<0||S>=u)){for(let N=o;N<o+d;N++)if(!(N<0||N>=p))for(let T=0;T<m;T++){let O=n.data[N+S*p+T*p*u];if(O<48)continue;let A=n.prio&&O<n.prio.length?n.prio[O]:0,C=N*32-a,W=S*32-s;if(A===0)f.push(O,C,W);else{let k=32*(S+A+1)-s,j=h.get(k);j||(j=[],h.set(k,j)),j.push(O,C,W)}}}let b=this,E=S=>N=>{for(let T=0;T<S.length;T+=3){let O=b._tileCanvas(n,S[T],r);O&&N.drawImage(O[0],O[1],O[2],32,32,S[T+1],S[T+2],32,32)}};t.push({z:0,seq:i,draw:E(f)});for(let[S,N]of h)t.push({z:S,seq:i,draw:E(N)})}_compose(e,t){t.save(),t.setTransform(1,0,0,1,0,0),t.globalAlpha=1,t.globalCompositeOperation="source-over",t.fillStyle="#000",t.fillRect(0,0,ee,te);let n=new Map,a=[];for(let r of e)if(r[0]===0){let i={rec:r,z:r[6],seq:r[18],items:[],isVp:!0};n.set(r[1],i)}for(let r of n.values())r.rec[9]&&a.push(r);for(let r of e){let i=r[0];if(i===0)continue;let o=r[1],c=a;if(o){let d=n.get(o);if(!d||!d.rec[9])continue;c=d.items}i===1?c.push({z:r[5],seq:r[26],rec:r}):i===2?c.push({z:r[3],seq:r[18],rec:r}):i===3?c.push({z:r[6],seq:r[24],rec:r}):i===4&&this._tilemapItems(r,c)}let s=(r,i)=>r.z-i.z||r.seq-i.seq;a.sort(s);for(let r of a)r.isVp?this._drawViewport(t,r,s):this._drawItem(t,r,0,0,ee,te);t.restore()}_drawViewport(e,t,n){let a=t.rec,s=a[2],r=a[3],i=a[4],o=a[5];if(i<=0||o<=0)return;if(t.items.sort(n),!(a[13]>0||a[14]||a[15]||a[16]||a[17]>0)){e.save(),e.beginPath(),e.rect(s,r,i,o),e.clip(),e.translate(s-a[7],r-a[8]);for(let _ of t.items)this._drawItem(e,_,a[7],a[8],i,o);e.restore();return}let d=this.vpCtx;d.setTransform(1,0,0,1,0,0),d.globalAlpha=1,d.globalCompositeOperation="source-over",d.clearRect(0,0,ee,te),d.drawImage(e.canvas,s,r,i,o,0,0,i,o),d.save(),d.beginPath(),d.rect(0,0,i,o),d.clip(),d.translate(-a[7],-a[8]);for(let _ of t.items)this._drawItem(d,_,a[7],a[8],i,o);d.restore(),ut(d,0,0,i,o,a[14],a[15],a[16],a[17]),a[13]>0&&(d.globalCompositeOperation="source-atop",d.globalAlpha=a[13]/255,d.fillStyle=`rgb(${a[10]},${a[11]},${a[12]})`,d.fillRect(0,0,i,o),d.globalAlpha=1,d.globalCompositeOperation="source-over"),e.drawImage(this.vpCanvas,0,0,i,o,s,r,i,o)}_drawItem(e,t,n,a,s,r){if(t.draw){t.draw(e);return}let i=t.rec;switch(i[0]){case 1:this._drawSprite(e,i);break;case 2:this._drawPlane(e,i,n,a,s,r);break;case 3:this._drawWindow(e,i);break;default:break}}_blend(e,t){e.globalCompositeOperation=t===1?"lighter":t===2?"difference":"source-over"}_drawSprite(e,t){let n=this._b(t[2]);if(!n)return;let a=t[8],s=t[9],r=t[10],i=t[11];if(a<0&&(r+=a,a=0),s<0&&(i+=s,s=0),r=Math.min(r,n.c.width-a),i=Math.min(i,n.c.height-s),r<=0||i<=0)return;let o=n.c,c=a,d=s,_=t[22]>0,f=t[23]!==0||t[24]!==0||t[25]!==0||t[26]>0;if(_||f){this._ensureTmp2(r,i);let m=this.tmp2Ctx;m.setTransform(1,0,0,1,0,0),m.globalAlpha=1,m.globalCompositeOperation="copy",m.drawImage(n.c,a,s,r,i,0,0,r,i),m.globalCompositeOperation="source-over",f&&(ut(m,0,0,r,i,t[23],t[24],t[25],t[26]),m.globalCompositeOperation="destination-in",m.drawImage(n.c,a,s,r,i,0,0,r,i),m.globalCompositeOperation="source-over"),_&&(m.globalCompositeOperation="source-atop",m.globalAlpha=t[22]/255,m.fillStyle=`rgb(${t[19]},${t[20]},${t[21]})`,m.fillRect(0,0,r,i),m.globalAlpha=1,m.globalCompositeOperation="source-over"),o=this.tmp2,c=0,d=0}e.save(),e.translate(t[3],t[4]),t[14]&&e.rotate(-t[14]*Math.PI/180);let h=t[12]*(t[15]?-1:1),p=t[13];(h!==1||p!==1)&&e.scale(h,p),(h!==1&&h!==-1||p!==1)&&(e.imageSmoothingEnabled=!0),e.globalAlpha=Math.min(1,t[16]/255),this._blend(e,t[17]);let u=t[18];if(u>0&&u<i){let m=i-u;e.drawImage(o,c,d,r,m,-t[6],-t[7],r,m),e.globalAlpha=Math.min(1,t[16]/255)*.5,e.drawImage(o,c,d+m,r,u,-t[6],-t[7]+m,r,u)}else u>=i&&(e.globalAlpha=Math.min(1,t[16]/255)*.5),e.drawImage(o,c,d,r,i,-t[6],-t[7],r,i);e.restore()}_drawPlane(e,t,n,a,s,r){let i=this._b(t[2]);if(!i)return;let o=t[6]||1,c=t[7]||1,d=i.c.width*o,_=i.c.height*c;if(d<=0||_<=0)return;e.save(),e.globalAlpha=Math.min(1,t[8]/255),this._blend(e,t[9]);let f=-((t[4]%d+d)%d)+n,h=-((t[5]%_+_)%_)+a;for(let p=h;p<a+r;p+=_)for(let u=f;u<n+s;u+=d)e.drawImage(i.c,0,0,i.c.width,i.c.height,u,p,d,_);t[13]>0&&(e.globalCompositeOperation="source-atop"),e.restore()}_drawWindow(e,t){let n=t[4],a=t[5],s=t[7],r=t[8];if(s<=0||r<=0)return;let i=this._b(t[2]),o=t[11]/255;if(e.save(),e.translate(n,a),i&&o>0){let f=i.c,h=o*(t[12]/255);if(h>0&&s>4&&r>4)if(e.globalAlpha=h,t[21])e.imageSmoothingEnabled=!0,e.drawImage(f,0,0,128,128,2,2,s-4,r-4),e.imageSmoothingEnabled=!1;else{e.save(),e.beginPath(),e.rect(2,2,s-4,r-4),e.clip();for(let p=2;p<r-2;p+=128)for(let u=2;u<s-2;u+=128)e.drawImage(f,0,0,128,128,u,p,128,128);e.restore()}e.globalAlpha=o,e.save(),e.beginPath(),e.rect(16,0,Math.max(0,s-32),r),e.clip();for(let p=16;p<s-16;p+=32)e.drawImage(f,144,0,32,16,p,0,32,16),e.drawImage(f,144,48,32,16,p,r-16,32,16);e.restore(),e.save(),e.beginPath(),e.rect(0,16,s,Math.max(0,r-32)),e.clip();for(let p=16;p<r-16;p+=32)e.drawImage(f,128,16,16,32,0,p,16,32),e.drawImage(f,176,16,16,32,s-16,p,16,32);e.restore(),e.drawImage(f,128,0,16,16,0,0,16,16),e.drawImage(f,176,0,16,16,s-16,0,16,16),e.drawImage(f,128,48,16,16,0,r-16,16,16),e.drawImage(f,176,48,16,16,s-16,r-16,16,16)}let c=t[16],d=t[17];i&&t[18]>=0&&c>0&&d>0&&(e.save(),e.beginPath(),e.rect(16,16,s-32,r-32),e.clip(),e.globalAlpha=t[18]/255*(t[13]/255),It(e,i.c,16+t[14],16+t[15],c,d),e.restore());let _=this._b(t[3]);if(_&&t[13]>0&&(e.save(),e.beginPath(),e.rect(16,16,Math.max(0,s-32),Math.max(0,r-32)),e.clip(),e.globalAlpha=t[13]/255,e.drawImage(_.c,16-t[9],16-t[10]),e.restore()),i&&o>0&&t[23]){let f=i.c,h=t[23];e.globalAlpha=o;let p=(s-16)/2|0,u=(r-16)/2|0;h&1&&e.drawImage(f,144,24,8,16,4,u,8,16),h&2&&e.drawImage(f,168,24,8,16,s-12,u,8,16),h&4&&e.drawImage(f,152,16,16,8,p,4,16,8),h&8&&e.drawImage(f,152,40,16,8,p,r-12,16,8)}if(i&&t[19]>=0){let f=[[160,64],[176,64],[160,80],[176,80]][t[19]&3];e.globalAlpha=t[20]/255*o,e.drawImage(i.c,f[0],f[1],16,16,(s-16)/2|0,r-16,16,16)}e.restore()}frame(e,t){let n;try{n=JSON.parse(e)}catch(r){console.error("bad display list",r,e.slice(0,200)),n=this.lastList}this.lastList=n,this.frameCount++;let a=this.ctx;if(this.frozen&&!this.trans)a.drawImage(this.frozen,0,0);else if(this._compose(n,a),this.trans){let r=this.trans;r.i++;let i=Math.max(0,1-r.i/Math.max(1,r.d));i>0&&(a.globalAlpha=i,a.drawImage(this.frozen,0,0),a.globalAlpha=1)}let s=1e3/Math.max(1,t||40);return new Promise(r=>{let i=o=>{!this.lastFrameTime||o-this.lastFrameTime>=s-3||o<this.lastFrameTime?(this.lastFrameTime&&o-this.lastFrameTime>s*4?this.lastFrameTime=o:this.lastFrameTime=this.lastFrameTime?this.lastFrameTime+s:o,o-this.lastFrameTime>s&&(this.lastFrameTime=o),r(this.resetRequested?1:0)):requestAnimationFrame(i)};requestAnimationFrame(i)})}freeze(){this.frozenCanvas||(this.frozenCanvas=P(ee,te));let e=this.frozenCanvas.getContext("2d");e.globalAlpha=1,e.drawImage(this.canvas,0,0),this.frozen=this.frozenCanvas}transitionBegin(e){if(this.frozen){if(e<=0){this.frozen=null,this.trans=null;return}this.trans={d:e,i:0}}}transitionEnd(){this.frozen=null,this.trans=null}snapToBitmap(){let e=P(ee,te);return e.getContext("2d").drawImage(this.canvas,0,0),this._reg(e)}keys(){let e=new Set([...this.keysHeld,...this.touchHeld,...this.latched]);return this.latched.clear(),[...e].join(",")}dir4(){let e=new Set([...this.keysHeld,...this.touchHeld]);for(let t=this.dirOrder.length-1;t>=0;t--)if(e.has(this.dirOrder[t]))return this.dirOrder[t];return 0}pressCode(e,t,n){let a=n?this.touchHeld:this.keysHeld;t?(a.add(e),this.latched.add(e),(e===2||e===4||e===6||e===8)&&(this.dirOrder=this.dirOrder.filter(s=>s!==e),this.dirOrder.push(e))):a.delete(e)}clearInput(){this.keysHeld.clear(),this.touchHeld.clear(),this.latched.clear()}bgmPlay(e,t,n){this.audio.play("bgm",e,t,n)}bgmStop(){this.audio.stop("bgm")}bgmFade(e){this.audio.fade("bgm",e)}bgsPlay(e,t,n){this.audio.play("bgs",e,t,n)}bgsStop(){this.audio.stop("bgs")}bgsFade(e){this.audio.fade("bgs",e)}mePlay(e,t,n){this.audio.playME(e,t,n)}meStop(){this.audio.stopME()}meFade(e){this.audio.fadeME(e)}sePlay(e,t,n){this.audio.playSE(e,t,n)}seStop(){this.audio.stopSE()}persist(e){let t=this.fs.read(e);t&&this.storage.save(e,t)}unpersist(e){this.storage.remove(e)}msgbox(e){return this.ui.alert(String(e))}inputText(e,t,n){return this.ui.prompt(String(e),String(t),n|0)}log(e){console.log("[ruby]",String(e))}now(){return performance.now()}};function It(l,e,t,n,a,s){let c=Math.max(0,a-4),d=Math.max(0,s-4);l.imageSmoothingEnabled=!1,c>0&&d>0&&l.drawImage(e,130,66,28,28,t+2,n+2,c,d),l.drawImage(e,128,64,2,2,t,n,2,2),l.drawImage(e,158,64,2,2,t+a-2,n,2,2),l.drawImage(e,128,94,2,2,t,n+s-2,2,2),l.drawImage(e,158,94,2,2,t+a-2,n+s-2,2,2),c>0&&(l.drawImage(e,130,64,28,2,t+2,n,c,2),l.drawImage(e,130,94,28,2,t+2,n+s-2,c,2)),d>0&&(l.drawImage(e,128,66,2,28,t,n+2,2,d),l.drawImage(e,158,66,2,28,t+a-2,n+2,2,d))}function ut(l,e,t,n,a,s,r,i,o){if(!s&&!r&&!i&&!(o>0))return;l.save(),l.setTransform(1,0,0,1,0,0),l.globalAlpha=1;let c=m=>{l.globalCompositeOperation=m};o>0&&(c("saturation"),l.globalAlpha=Math.min(1,o/255),l.fillStyle="#808080",l.fillRect(e,t,n,a),l.globalAlpha=1);let d=Math.max(0,s),_=Math.max(0,r),f=Math.max(0,i);(d||_||f)&&(c("lighter"),l.fillStyle=`rgb(${d},${_},${f})`,l.fillRect(e,t,n,a));let h=Math.max(0,-s),p=Math.max(0,-r),u=Math.max(0,-i);(h||p||u)&&(c("difference"),l.fillStyle="#fff",l.fillRect(e,t,n,a),c("lighter"),l.fillStyle=`rgb(${h},${p},${u})`,l.fillRect(e,t,n,a),c("difference"),l.fillStyle="#fff",l.fillRect(e,t,n,a)),l.restore()}var Je=class{constructor(e){this.files=e,this.ctx=null,this.ch={bgm:null,bgs:null},this.me=null,this.seBuffers=new Map,this.seActive=new Set,this.master={bgm:1,se:1},this.bgmPausedForME=!1}unlock(){if(!this.ctx){let e=window.AudioContext||window.webkitAudioContext;e&&(this.ctx=new e)}this.ctx&&this.ctx.state==="suspended"&&this.ctx.resume();for(let e of["bgm","bgs"]){let t=this.ch[e];t&&t.el.paused&&t.wantPlay&&t.el.play().catch(()=>{})}}url(e){let t=String(e).replace(/\\/g,"/").toLowerCase().replace(/\.(mp3|ogg|wav|mid|midi|m4a)$/,"");return this.files.get(t)||null}setMaster(e,t){this.master[e]=t;for(let n of["bgm","bgs"])this._applyVol(this.ch[n],n==="bgm"?this.master.bgm:this.master.se);this.me&&this._applyVol(this.me,this.master.bgm)}_applyVol(e,t){e&&(e.el.volume=Math.max(0,Math.min(1,e.vol*t*(e.fadeMul??1))))}play(e,t,n,a){let s=this.url(t),r=this.ch[e];if(!s){this.stop(e);return}if(r&&r.url===s){r.vol=n/100,r.fadeMul=1,r.fadeTimer&&(clearInterval(r.fadeTimer),r.fadeTimer=null),r.el.playbackRate=a/100,this._applyVol(r,e==="bgm"?this.master.bgm:this.master.se),r.el.paused&&!(e==="bgm"&&this.me)&&r.el.play().catch(()=>{});return}this.stop(e);let i=new Audio(s);i.loop=!0,i.preservesPitch=!1,i.mozPreservesPitch=!1,i.webkitPreservesPitch=!1,i.playbackRate=a/100;let o={el:i,url:s,vol:n/100,fadeMul:1,wantPlay:!0};this.ch[e]=o,this._applyVol(o,e==="bgm"?this.master.bgm:this.master.se),e==="bgm"&&this.me||i.play().catch(()=>{})}stop(e){let t=this.ch[e];t&&(t.fadeTimer&&clearInterval(t.fadeTimer),t.el.pause(),t.el.src="",t.wantPlay=!1),this.ch[e]=null}_fadeEl(e,t,n){if(!e)return;e.fadeTimer&&clearInterval(e.fadeTimer);let a=Math.max(1,Math.round(t/50)),s=0;e.fadeTimer=setInterval(()=>{s++,e.fadeMul=Math.max(0,1-s/a),this._applyVol(e,this.master.bgm),s>=a&&(clearInterval(e.fadeTimer),e.fadeTimer=null,n())},50)}fade(e,t){let n=this.ch[e];this._fadeEl(n,t,()=>{this.ch[e]===n&&this.stop(e)})}playME(e,t,n){let a=this.url(e);if(this.stopME(),!a)return;let s=new Audio(a);s.preservesPitch=!1,s.playbackRate=n/100;let r={el:s,url:a,vol:t/100,fadeMul:1};this.me=r,this._applyVol(r,this.master.bgm);let i=this.ch.bgm;i&&i.el.pause(),s.onended=()=>{this.me===r&&(this.me=null);let o=this.ch.bgm;o&&o.wantPlay&&o.el.play().catch(()=>{})},s.play().catch(()=>{s.onended()})}stopME(){let e=this.me;e&&(e.el.onended=null,e.el.pause(),e.el.src=""),this.me=null;let t=this.ch.bgm;e&&t&&t.wantPlay&&t.el.play().catch(()=>{})}fadeME(e){let t=this.me;this._fadeEl(t,e,()=>{this.me===t&&this.stopME()})}async _seBuffer(e){if(this.seBuffers.has(e))return this.seBuffers.get(e);let t=fetch(e).then(n=>n.arrayBuffer()).then(n=>new Promise((a,s)=>this.ctx.decodeAudioData(n,a,s))).catch(()=>null);return this.seBuffers.set(e,t),t}playSE(e,t,n){let a=this.url(e);!a||!this.ctx||this._seBuffer(a).then(s=>{if(!s)return;let r=this.ctx.createBufferSource();r.buffer=s,r.playbackRate.value=n/100;let i=this.ctx.createGain();i.gain.value=Math.max(0,Math.min(1,t/100*this.master.se)),r.connect(i).connect(this.ctx.destination),this.seActive.add(r),r.onended=()=>this.seActive.delete(r),r.start()})}preloadSE(e){if(this.ctx)for(let t of e){let n=this.url(t);n&&this._seBuffer(n)}}stopSE(){for(let e of this.seActive)try{e.stop()}catch{}this.seActive.clear()}pauseAll(){for(let e of["bgm","bgs"]){let t=this.ch[e];t&&t.el.pause()}this.me&&this.me.el.pause(),this.ctx&&this.ctx.state==="running"&&this.ctx.suspend()}resumeAll(){if(this.ctx&&this.ctx.state==="suspended"&&this.ctx.resume(),this.me)this.me.el.play().catch(()=>{});else{let t=this.ch.bgm;t&&t.wantPlay&&t.el.play().catch(()=>{})}let e=this.ch.bgs;e&&e.wantPlay&&e.el.play().catch(()=>{})}};var pt=`# RGSS1 core classes for ruby.wasm. Rendering is delegated to JS (globalThis.RG).
require 'js'

module RGWeb
  JSRG = JS.global[:RG]
  @elements = []          # live drawables (Sprite/Plane/Window/Tilemap/Viewport)
  @seq = 0
  @dispose_queue = []
  class << self
    attr_reader :elements
    def call(name, *args)
      JSRG.call(name, *args)
    end
    def next_seq
      @seq += 1
    end
    def register(o)
      @elements << o
    end
    def unregister(o)
      @elements.delete(o)
    end
    def queue_dispose(id)
      @dispose_queue << id
    end
    def flush_dispose
      return if @dispose_queue.empty?
      call(:bmpDisposeList, @dispose_queue.join(','))
      @dispose_queue.clear
    end
    def display_list
      out = []
      @elements.each do |e|
        r = e.__record
        out << r if r
      end
      '[' + out.join(',') + ']'
    end
    def await_js(name, *args)
      JSRG.call(name, *args).await
    end
    def num(v)
      v.to_i
    end
  end
end

# ---------------------------------------------------------------------------
class Color
  attr_reader :red, :green, :blue, :alpha
  def initialize(r = 0, g = 0, b = 0, a = 255)
    set(r, g, b, a)
  end
  def set(r, g = 0, b = 0, a = 255)
    if r.is_a?(Color)
      c = r
      @red, @green, @blue, @alpha = c.red, c.green, c.blue, c.alpha
    else
      self.red = r; self.green = g; self.blue = b; self.alpha = a
    end
    self
  end
  def red=(v);   @red   = __c(v); end
  def green=(v); @green = __c(v); end
  def blue=(v);  @blue  = __c(v); end
  def alpha=(v); @alpha = __c(v); end
  def __c(v)
    v = v.to_f
    v < 0 ? 0.0 : (v > 255 ? 255.0 : v)
  end
  def ==(o)
    o.is_a?(Color) && @red == o.red && @green == o.green && @blue == o.blue && @alpha == o.alpha
  end
  def to_s
    format('(%f, %f, %f, %f)', @red, @green, @blue, @alpha)
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@red, @green, @blue, @alpha].pack('E4')
  end
  def self._load(s)
    new(*s.unpack('E4'))
  end
  def __css
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@alpha.to_i}"
  end
end

class Tone
  attr_reader :red, :green, :blue, :gray
  def initialize(r = 0, g = 0, b = 0, gray = 0)
    set(r, g, b, gray)
  end
  def set(r, g = 0, b = 0, gray = 0)
    if r.is_a?(Tone)
      t = r
      @red, @green, @blue, @gray = t.red, t.green, t.blue, t.gray
    else
      self.red = r; self.green = g; self.blue = b; self.gray = gray
    end
    self
  end
  def __c(v)
    v = v.to_f
    v < -255 ? -255.0 : (v > 255 ? 255.0 : v)
  end
  def red=(v);   @red   = __c(v); end
  def green=(v); @green = __c(v); end
  def blue=(v);  @blue  = __c(v); end
  def gray=(v)
    v = v.to_f
    @gray = v < 0 ? 0.0 : (v > 255 ? 255.0 : v)
  end
  def ==(o)
    o.is_a?(Tone) && @red == o.red && @green == o.green && @blue == o.blue && @gray == o.gray
  end
  def to_s
    format('(%f, %f, %f, %f)', @red, @green, @blue, @gray)
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@red, @green, @blue, @gray].pack('E4')
  end
  def self._load(s)
    new(*s.unpack('E4'))
  end
  def __css
    "#{@red.to_i},#{@green.to_i},#{@blue.to_i},#{@gray.to_i}"
  end
end

class Rect
  attr_reader :x, :y, :width, :height
  def initialize(x = 0, y = 0, w = 0, h = 0)
    set(x, y, w, h)
  end
  def set(x, y = 0, w = 0, h = 0)
    if x.is_a?(Rect)
      r = x
      @x, @y, @width, @height = r.x, r.y, r.width, r.height
    else
      @x = x.to_i; @y = y.to_i; @width = w.to_i; @height = h.to_i
    end
    self
  end
  def x=(v); @x = v.to_i; end
  def y=(v); @y = v.to_i; end
  def width=(v); @width = v.to_i; end
  def height=(v); @height = v.to_i; end
  def empty
    @x = @y = @width = @height = 0
    self
  end
  def ==(o)
    o.is_a?(Rect) && @x == o.x && @y == o.y && @width == o.width && @height == o.height
  end
  def to_s
    "(#{@x}, #{@y}, #{@width}, #{@height})"
  end
  alias inspect to_s
  def _dump(_d = 0)
    [@x, @y, @width, @height].pack('l4')
  end
  def self._load(s)
    new(*s.unpack('l4'))
  end
end

class Table
  attr_reader :xsize, :ysize, :zsize, :__ver, :__data
  def initialize(x, y = 0, z = 0)
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize = [x, 0].max
    @ysize = [y, 1].max
    @zsize = [z, 1].max
    @__data = Array.new(@xsize * @ysize * @zsize, 0)
    @__ver = 0
  end
  def [](x, y = 0, z = 0)
    return nil if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize
    @__data[x + (y + z * @ysize) * @xsize]
  end
  def []=(*args)
    v = args.pop
    x = args[0]; y = args[1] || 0; z = args[2] || 0
    return v if x < 0 || x >= @xsize || y < 0 || y >= @ysize || z < 0 || z >= @zsize
    v = v.to_i
    v = ((v + 32768) & 0xFFFF) - 32768
    @__data[x + (y + z * @ysize) * @xsize] = v
    @__ver = (@__ver || 0) + 1
    v
  end
  def resize(x, y = 0, z = 0)
    old = @__data; ox = @xsize; oy = @ysize; oz = @zsize
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize = [x, 0].max; @ysize = [y, 1].max; @zsize = [z, 1].max
    @__data = Array.new(@xsize * @ysize * @zsize, 0)
    [oz, @zsize].min.times do |k|
      [oy, @ysize].min.times do |j|
        [ox, @xsize].min.times do |i|
          @__data[i + (j + k * @ysize) * @xsize] = old[i + (j + k * oy) * ox]
        end
      end
    end
    @__ver = (@__ver || 0) + 1
    self
  end
  def _dump(_d = 0)
    [@dim, @xsize, @ysize, @zsize, @__data.size].pack('l5') + @__data.pack('s*')
  end
  def self._load(s)
    dim, x, y, z, n = s.unpack('l5')
    t = allocate
    t.__init_load(dim, x, y, z, s[20, n * 2].unpack('s*'))
    t
  end
  def __init_load(dim, x, y, z, data)
    @dim = dim; @xsize = x; @ysize = y; @zsize = z; @__data = data; @__ver = 0
  end
  def __version
    @__ver || 0
  end
end

# ---------------------------------------------------------------------------
class Font
  class << self
    attr_accessor :default_name, :default_size, :default_bold, :default_italic
    attr_writer :default_color
    def default_color
      @default_color ||= Color.new(255, 255, 255, 255)
    end
    def exist?(_name)
      true
    end
  end
  @default_name = ['\u5B8B\u4F53']
  @default_size = 22
  @default_bold = false
  @default_italic = false
  attr_accessor :name, :size, :bold, :italic
  attr_reader :color
  def initialize(name = Font.default_name, size = Font.default_size)
    @name = name.is_a?(Array) ? name.dup : name
    @size = size
    @bold = Font.default_bold
    @italic = Font.default_italic
    @color = Font.default_color.dup
  end
  def color=(c)
    @color = c.is_a?(Color) ? c : Color.new
  end
  def initialize_copy(o)
    super
    @color = o.color.dup
    @name = o.name.dup if o.name.respond_to?(:dup)
  end
  def __names
    n = @name
    n = n.join("\\u0001") if n.is_a?(Array)
    n.to_s
  end
end

# ---------------------------------------------------------------------------
class Bitmap
  attr_reader :__id
  def self.__finalizer(id)
    proc { RGWeb.queue_dispose(id) }
  end
  def initialize(*args)
    if args.size == 1
      path = args[0].to_s
      id = RGWeb.call(:bmpLoad, path).to_i
      raise Errno::ENOENT, path if id < 0
      @__id = id
    else
      w = args[0].to_i; h = args[1].to_i
      raise ArgumentError, 'failed to create bitmap' if w <= 0 || h <= 0
      @__id = RGWeb.call(:bmpNew, w, h).to_i
    end
    __setup
  end
  def __setup
    @width = RGWeb.call(:bmpW, @__id).to_i
    @height = RGWeb.call(:bmpH, @__id).to_i
    @font = Font.new
    @disposed = false
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))
  end
  def initialize_copy(o)
    @__id = RGWeb.call(:bmpClone, o.__id).to_i
    @width = o.width; @height = o.height
    @font = o.font.dup
    @disposed = false
    ObjectSpace.define_finalizer(self, Bitmap.__finalizer(@__id))
  end
  def font
    @font
  end
  def font=(f)
    @font = f
  end
  def dispose
    return if @disposed
    @disposed = true
    ObjectSpace.undefine_finalizer(self)
    RGWeb.call(:bmpDispose, @__id)
  end
  def disposed?
    @disposed
  end
  def width
    @width
  end
  def height
    @height
  end
  def rect
    Rect.new(0, 0, @width, @height)
  end
  def blt(x, y, src, rect, opacity = 255)
    return if src.nil? || src.disposed?
    RGWeb.call(:bmpBlt, @__id, x.to_i, y.to_i, src.__id, rect.x, rect.y, rect.width, rect.height, opacity.to_i)
  end
  def stretch_blt(dest, src, srect, opacity = 255)
    return if src.nil? || src.disposed?
    RGWeb.call(:bmpStretch, @__id, dest.x, dest.y, dest.width, dest.height, src.__id, srect.x, srect.y, srect.width, srect.height, opacity.to_i)
  end
  def fill_rect(*a)
    if a[0].is_a?(Rect)
      r = a[0]; c = a[1]
      x, y, w, h = r.x, r.y, r.width, r.height
    else
      x, y, w, h, c = a
    end
    RGWeb.call(:bmpFill, @__id, x.to_i, y.to_i, w.to_i, h.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def clear
    RGWeb.call(:bmpClear, @__id)
  end
  def get_pixel(x, y)
    s = RGWeb.call(:bmpGetPixel, @__id, x.to_i, y.to_i).to_s
    Color.new(*s.split(',').map(&:to_i))
  end
  def set_pixel(x, y, c)
    RGWeb.call(:bmpSetPixel, @__id, x.to_i, y.to_i, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def hue_change(h)
    return if h.to_i % 360 == 0
    RGWeb.call(:bmpHue, @__id, h.to_i)
  end
  def draw_text(*a)
    if a[0].is_a?(Rect)
      r = a[0]
      x, y, w, h = r.x, r.y, r.width, r.height
      str = a[1]; align = a[2] || 0
    else
      x, y, w, h, str = a[0], a[1], a[2], a[3], a[4]
      align = a[5] || 0
    end
    str = str.to_s
    return if str.empty?
    str = RGWeb.utf8(str)
    f = @font
    c = f.color
    RGWeb.call(:bmpText, @__id, x.to_i, y.to_i, w.to_i, h.to_i, str, align.to_i, f.__names, f.size.to_i,
               f.bold ? true : false, f.italic ? true : false, c.red.to_i, c.green.to_i, c.blue.to_i, c.alpha.to_i)
  end
  def text_size(str)
    str = RGWeb.utf8(str.to_s)
    f = @font
    w = RGWeb.call(:textSize, str, f.__names, f.size.to_i, f.bold ? true : false, f.italic ? true : false).to_i
    Rect.new(0, 0, w, f.size.to_i)
  end
end

# ---------------------------------------------------------------------------
class Viewport
  attr_reader :rect, :color, :tone, :__seq
  attr_accessor :visible, :ox, :oy
  attr_reader :z
  @@ids = 0
  def initialize(*a)
    @rect = a[0].is_a?(Rect) ? a[0].dup : Rect.new(a[0] || 0, a[1] || 0, a[2] || 640, a[3] || 480)
    @@ids += 1
    @__vid = @@ids
    @visible = true
    @z = 0; @ox = 0; @oy = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @flash_color = nil; @flash_count = 0; @flash_dur = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def __vid
    @__vid
  end
  def z=(v); @z = v.to_i; end
  def rect=(r); @rect = r.dup; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def flash(color, duration)
    @flash_color = color; @flash_dur = duration; @flash_count = duration
  end
  def update
    @flash_count -= 1 if @flash_count > 0
  end
  def __record
    c = @color
    if @flash_count > 0 && @flash_color
      a = @flash_color.alpha * @flash_count / @flash_dur
      c = Color.new(@flash_color.red, @flash_color.green, @flash_color.blue, [a, c.alpha].max) if a > c.alpha
    end
    "[0,#{@__vid},#{@rect.x},#{@rect.y},#{@rect.width},#{@rect.height},#{@z},#{@ox.to_i},#{@oy.to_i},#{@visible ? 1 : 0},#{c.__css},#{@tone.__css},#{@__seq}]"
  end
end

module RGWeb
  module ViewportChild
    def __vpid
      v = @viewport
      v && !v.disposed? ? v.__vid : 0
    end
  end
end

# ---------------------------------------------------------------------------
class Sprite
  include RGWeb::ViewportChild
  attr_reader :viewport, :bitmap, :src_rect, :color, :tone, :z
  attr_accessor :visible, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :angle, :mirror, :bush_depth, :blend_type
  attr_reader :opacity
  def initialize(viewport = nil)
    @viewport = viewport
    @bitmap = nil
    @src_rect = Rect.new(0, 0, 0, 0)
    @visible = true
    @x = @y = @z = @ox = @oy = 0
    @zoom_x = @zoom_y = 1.0
    @angle = 0
    @mirror = false
    @bush_depth = 0
    @opacity = 255
    @blend_type = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @flash_color = nil; @flash_count = 0; @flash_dur = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def bitmap=(b)
    @bitmap = b
    @src_rect.set(0, 0, b.width, b.height) if b && !b.disposed?
  end
  def src_rect=(r); @src_rect = r; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def z=(v); @z = v.to_i; end
  def opacity=(v)
    v = v.to_i
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)
  end
  def viewport=(v); @viewport = v; end
  def width
    @src_rect.width
  end
  def height
    @src_rect.height
  end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def flash(color, duration)
    @flash_color = color; @flash_dur = duration; @flash_count = duration
  end
  def update
    @flash_count -= 1 if @flash_count > 0
  end
  def __record
    return nil unless @visible
    b = @bitmap
    return nil if b.nil? || b.disposed?
    return nil if @opacity <= 0
    c = @color
    if @flash_count > 0
      return nil if @flash_color.nil?
      a = @flash_color.alpha * @flash_count / @flash_dur
      c = @flash_color.dup.tap { |cc| cc.alpha = a } if a > c.alpha
    end
    sr = @src_rect
    "[1,#{__vpid},#{b.__id},#{@x.to_i},#{@y.to_i},#{@z},#{@ox.to_i},#{@oy.to_i},#{sr.x},#{sr.y},#{sr.width},#{sr.height},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@angle.to_f},#{@mirror ? 1 : 0},#{@opacity},#{@blend_type.to_i},#{@bush_depth.to_i},#{c.__css},#{@tone.__css},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Plane
  include RGWeb::ViewportChild
  attr_reader :viewport, :bitmap, :color, :tone, :z, :opacity
  attr_accessor :visible, :ox, :oy, :zoom_x, :zoom_y, :blend_type
  def initialize(viewport = nil)
    @viewport = viewport
    @bitmap = nil
    @visible = true
    @z = @ox = @oy = 0
    @zoom_x = @zoom_y = 1.0
    @opacity = 255
    @blend_type = 0
    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def bitmap=(b); @bitmap = b; end
  def color=(c); @color = c; end
  def tone=(t); @tone = t; end
  def z=(v); @z = v.to_i; end
  def opacity=(v)
    v = v.to_i
    @opacity = v < 0 ? 0 : (v > 255 ? 255 : v)
  end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def __record
    return nil unless @visible
    b = @bitmap
    return nil if b.nil? || b.disposed? || @opacity <= 0
    "[2,#{__vpid},#{b.__id},#{@z},#{@ox.to_i},#{@oy.to_i},#{@zoom_x.to_f},#{@zoom_y.to_f},#{@opacity},#{@blend_type.to_i},#{@color.__css},#{@tone.__css},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Window
  include RGWeb::ViewportChild
  attr_reader :viewport, :windowskin, :contents, :cursor_rect, :z
  attr_reader :x, :y, :width, :height, :opacity, :back_opacity, :contents_opacity
  attr_accessor :stretch, :active, :visible, :pause, :ox, :oy
  def initialize(viewport = nil)
    @viewport = viewport
    @windowskin = nil
    @contents = nil
    @stretch = true
    @cursor_rect = Rect.new(0, 0, 0, 0)
    @active = true
    @visible = true
    @pause = false
    @x = @y = @width = @height = @z = @ox = @oy = 0
    @opacity = 255; @back_opacity = 255; @contents_opacity = 255
    @cursor_count = 0
    @pause_count = 0
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def windowskin=(b); @windowskin = b; end
  def contents=(b); @contents = b; end
  def cursor_rect=(r); @cursor_rect = r; end
  def x=(v); @x = v.to_i; end
  def y=(v); @y = v.to_i; end
  def width=(v); @width = v.to_i; end
  def height=(v); @height = v.to_i; end
  def z=(v); @z = v.to_i; end
  def opacity=(v); @opacity = [[v.to_i, 0].max, 255].min; end
  def back_opacity=(v); @back_opacity = [[v.to_i, 0].max, 255].min; end
  def contents_opacity=(v); @contents_opacity = [[v.to_i, 0].max, 255].min; end
  def pause=(v)
    @pause_count = 0 if v && !@pause
    @pause = v
  end
  def dispose
    return if @disposed
    @disposed = true
    @contents.dispose if false
    RGWeb.unregister(self)
  end
  def disposed?
    @disposed
  end
  def update
    @cursor_count = (@cursor_count + 1) % 32 if @active
    @pause_count += 1 if @pause
  end
  def __record
    return nil unless @visible
    return nil if @width <= 0 || @height <= 0
    sk = @windowskin && !@windowskin.disposed? ? @windowskin.__id : 0
    ct = @contents && !@contents.disposed? ? @contents.__id : 0
    cr = @cursor_rect
    ca = -1
    if cr.width > 0 && cr.height > 0
      if @active
        i = @cursor_count
        ca = i < 16 ? 255 - i * 8 : 127 + (i - 16) * 8
      else
        ca = 255
      end
    end
    pf = -1; pa = 0
    if @pause
      pf = (@pause_count / 8) % 4
      pa = [@pause_count * 32, 255].min
    end
    arrows = 0
    if ct != 0
      cw = @contents.width; chh = @contents.height
      arrows |= 1 if @ox > 0
      arrows |= 2 if cw - @ox > @width - 32
      arrows |= 4 if @oy > 0
      arrows |= 8 if chh - @oy > @height - 32
    end
    "[3,#{__vpid},#{sk},#{ct},#{@x},#{@y},#{@z},#{@width},#{@height},#{@ox.to_i},#{@oy.to_i},#{@opacity},#{@back_opacity},#{@contents_opacity},#{cr.x},#{cr.y},#{cr.width},#{cr.height},#{ca},#{pf},#{pa},#{@stretch ? 1 : 0},#{@active ? 1 : 0},#{arrows},#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
class Tilemap
  include RGWeb::ViewportChild
  class AutotileArray
    def initialize(tm)
      @tm = tm
      @a = Array.new(7)
    end
    def [](i)
      @a[i]
    end
    def []=(i, b)
      @a[i] = b
      @tm.__dirty!
    end
    def __ids
      @a.map { |b| b && !b.disposed? ? b.__id : 0 }.join(',')
    end
  end
  @@ids = 0
  attr_reader :viewport, :tileset, :autotiles, :map_data, :flash_data, :priorities
  attr_accessor :visible, :ox, :oy
  def initialize(viewport = nil)
    @viewport = viewport
    @@ids += 1
    @__tid = @@ids
    @autotiles = AutotileArray.new(self)
    @tileset = nil; @map_data = nil; @flash_data = nil; @priorities = nil
    @visible = true
    @ox = @oy = 0
    @ani = 0
    @dirty = true
    @sent_ver = nil
    @disposed = false
    @__seq = RGWeb.next_seq
    RGWeb.register(self)
  end
  def __dirty!
    @dirty = true
  end
  def tileset=(b); @tileset = b; @dirty = true; end
  def map_data=(t); @map_data = t; @dirty = true; end
  def priorities=(t); @priorities = t; @dirty = true; end
  def flash_data=(t); @flash_data = t; end
  def dispose
    return if @disposed
    @disposed = true
    RGWeb.unregister(self)
    RGWeb.call(:tmDispose, @__tid)
  end
  def disposed?
    @disposed
  end
  def update
    @ani += 1
  end
  def __record
    return nil unless @visible
    return nil if @map_data.nil?
    ver = [@map_data.__version, @priorities ? @priorities.__version : 0]
    if @dirty || ver != @sent_ver
      md = @map_data
      RGWeb.call(:tmConfig, @__tid, @tileset && !@tileset.disposed? ? @tileset.__id : 0, @autotiles.__ids,
                 md.xsize, md.ysize, md.zsize, md.__data.join(','), @priorities ? @priorities.__data.join(',') : '')
      @dirty = false
      @sent_ver = ver
    end
    "[4,#{__vpid},#{@__tid},#{@ox.to_i},#{@oy.to_i},#{(@ani / 16) % 4},1,#{@__seq}]"
  end
end

# ---------------------------------------------------------------------------
module Graphics
  @frame_rate = 40
  @frame_count = 0
  class << self
    attr_accessor :frame_count
    attr_reader :frame_rate
    def frame_rate=(v)
      @frame_rate = [[v.to_i, 10].max, 120].min
    end
    def update
      RGWeb.flush_dispose
      r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)
      @frame_count += 1
      RGWeb.after_frame(r)
      nil
    end
    def freeze
      RGWeb.call(:freeze)
      nil
    end
    def transition(duration = 8, _filename = '', _vague = 40)
      duration = duration.to_i
      RGWeb.call(:transitionBegin, duration)
      if duration > 0
        duration.times do
          RGWeb.flush_dispose
          r = RGWeb.await_js(:frame, RGWeb.display_list, @frame_rate)
          @frame_count += 1
          RGWeb.after_frame(r)
        end
      end
      RGWeb.call(:transitionEnd)
      nil
    end
    def frame_reset
      nil
    end
    def width
      640
    end
    def height
      480
    end
    def snap_to_bitmap
      b = Bitmap.allocate
      b.instance_variable_set(:@__id, RGWeb.call(:snapToBitmap).to_i)
      b.__setup
      b
    end
  end
end

module RGWeb
  def self.after_frame(r)
    return if r.to_i == 0
    # reset requested from web UI
    raise Reset if defined?(Reset) && Reset.is_a?(Class)
  end
end

# ---------------------------------------------------------------------------
module Input
  DOWN = 2; LEFT = 4; RIGHT = 6; UP = 8
  A = 11; B = 12; C = 13; X = 14; Y = 15; Z = 16; L = 17; R = 18
  SHIFT = 21; CTRL = 22; ALT = 23
  F5 = 25; F6 = 26; F7 = 27; F8 = 28; F9 = 29
  @cnt = Array.new(32, 0)
  @dir4 = 0
  class << self
    def update
      s = RGWeb.call(:keys).to_s
      held = s.empty? ? [] : s.split(',').map(&:to_i)
      32.times do |k|
        @cnt[k] = held.include?(k) ? @cnt[k] + 1 : 0
      end
      @dir4 = held.empty? ? 0 : RGWeb.call(:dir4).to_i
      nil
    end
    def press?(k)
      k = k.to_i
      k >= 0 && k < 32 && @cnt[k] > 0
    end
    def trigger?(k)
      k = k.to_i
      k >= 0 && k < 32 && @cnt[k] == 1
    end
    def repeat?(k)
      k = k.to_i
      return false unless k >= 0 && k < 32
      c = @cnt[k]
      c == 1 || (c > 15 && (c - 16) % 4 == 0)
    end
    def dir4
      return @dir4 if @dir4 != 0 && @cnt[@dir4] > 0
      [2, 4, 6, 8].each { |d| return d if @cnt[d] > 0 }
      0
    end
    def dir8
      d = @cnt
      up = d[8] > 0; down = d[2] > 0; left = d[4] > 0; right = d[6] > 0
      if up && left then 7
      elsif up && right then 9
      elsif down && left then 1
      elsif down && right then 3
      else dir4
      end
    end
  end
end

# ---------------------------------------------------------------------------
module Audio
  class << self
    def __n(name)
      RGWeb.utf8(name.to_s)
    end
    def bgm_play(name, volume = 100, pitch = 100)
      RGWeb.call(:bgmPlay, __n(name), volume.to_i, pitch.to_i)
    end
    def bgm_stop; RGWeb.call(:bgmStop); end
    def bgm_fade(ms); RGWeb.call(:bgmFade, ms.to_i); end
    def bgs_play(name, volume = 80, pitch = 100)
      RGWeb.call(:bgsPlay, __n(name), volume.to_i, pitch.to_i)
    end
    def bgs_stop; RGWeb.call(:bgsStop); end
    def bgs_fade(ms); RGWeb.call(:bgsFade, ms.to_i); end
    def me_play(name, volume = 100, pitch = 100)
      RGWeb.call(:mePlay, __n(name), volume.to_i, pitch.to_i)
    end
    def me_stop; RGWeb.call(:meStop); end
    def me_fade(ms); RGWeb.call(:meFade, ms.to_i); end
    def se_play(name, volume = 80, pitch = 100)
      RGWeb.call(:sePlay, __n(name), volume.to_i, pitch.to_i)
    end
    def se_stop; RGWeb.call(:seStop); end
  end
end
`;var ht=`# Ruby 1.8 / RGSS1 kernel compatibility for ruby.wasm (Ruby 3.4)
require "zlib"
module RGWeb
  class << self
    def utf8(s)
      return s.to_s unless s.is_a?(String)
      return s if s.encoding == Encoding::UTF_8 && s.valid_encoding?
      t = s.dup.force_encoding('UTF-8')
      t.valid_encoding? ? t : t.scrub('?')
    end
    # 1.8 Marshal data has no encoding info: mark every String as UTF-8.
    def fix_enc(o, seen = {})
      case o
      when String
        o.force_encoding('UTF-8') unless o.frozen? || o.encoding == Encoding::UTF_8
        o
      when Array
        return o if seen[o.object_id]
        seen[o.object_id] = true
        o.each_with_index do |e, i|
          if e.is_a?(String) && e.frozen? && e.encoding != Encoding::UTF_8
            o[i] = e.dup.force_encoding('UTF-8')
          else
            fix_enc(e, seen)
          end
        end
        o
      when Hash
        return o if seen[o.object_id]
        seen[o.object_id] = true
        if o.keys.any? { |k| k.is_a?(String) && k.encoding != Encoding::UTF_8 }
          pairs = o.to_a
          o.clear
          pairs.each { |k, v| o[k.is_a?(String) ? k.dup.force_encoding('UTF-8') : k] = fix_enc(v, seen) }
        else
          o.each_value { |v| fix_enc(v, seen) }
        end
        o
      when Numeric, NilClass, TrueClass, FalseClass, Symbol, Table, Color, Tone, Rect, Bitmap, Class, Module
        o
      else
        return o if seen[o.object_id]
        seen[o.object_id] = true
        o.instance_variables.each do |iv|
          v = o.instance_variable_get(iv)
          if v.is_a?(String) && v.frozen? && v.encoding != Encoding::UTF_8
            o.instance_variable_set(iv, v.dup.force_encoding('UTF-8'))
          else
            fix_enc(v, seen)
          end
        end
        o
      end
    end
    # byte-based slicing (Ruby 1.8 String#slice semantics) that never splits a UTF-8 char
    def bslice(s, start, len)
      s = utf8(s)
      out = +''
      pos = 0
      s.each_char do |ch|
        b = ch.bytesize
        if pos >= start && pos + b <= start + len
          out << ch
        end
        pos += b
        break if pos >= start + len
      end
      out
    end
    def msgbox(text)
      await_js(:msgbox, utf8(text.to_s))
      nil
    end
  end
end

module Kernel
  def load_data(fn)
    fn = RGWeb.utf8(fn.to_s)
    data = File.open(fn, 'rb') { |f| f.read }
    obj = RGWeb.fix_enc(Marshal.load(data))
    RGWeb.patch_common_events(obj) if fn =~ /CommonEvents\\.rxdata\\z/i
    obj
  end
  def save_data(obj, fn)
    File.open(RGWeb.utf8(fn.to_s), 'wb') { |f| Marshal.dump(obj, f) }
    nil
  end
  # RGSS: p / print show a message box
  def p(*args)
    return nil if args.empty?
    RGWeb.msgbox(args.map { |a| a.is_a?(String) ? RGWeb.utf8(a) : a.inspect }.join("\\n"))
    args.size == 1 ? args[0] : args
  end
  def print(*args)
    RGWeb.msgbox(args.map { |a| RGWeb.utf8(a.to_s) }.join)
    nil
  end
  alias_method :__rg_rand, :rand
  # Ruby 1.8: rand(x) uses x.to_i.abs, rand(0)/rand(nil) -> float
  def rand(max = 0)
    n = max.is_a?(Range) ? nil : max.to_i.abs
    return __rg_rand(max) if n.nil?
    n == 0 ? __rg_rand : __rg_rand(n)
  end
  module_function :rand, :load_data, :save_data
  public :rand, :load_data, :save_data, :p, :print
end

class Array
  # Ruby 1.8: Array#to_s == join
  def to_s
    join
  end
end

class Hash
  def index(v)
    key(v)
  end unless method_defined?(:index)
end

class Object
  # Ruby 1.8 Object#type
  def type
    self.class
  end unless method_defined?(:type)
end

class Integer
  def to_sym_18
    self
  end
end

class Win32API
  def initialize(dll, func, *_args)
    @dll = dll.to_s
    @func = func.to_s
  end
  def call(*_args)
    0
  end
  alias Call call
end

# ---------------------------------------------------------------------------
# Persist written files (save games) to browser storage
class File
  class << self
    alias_method :__rg_open, :open
    def open(name, mode = 'r', *rest, &blk)
      name = RGWeb.utf8(name.to_s)
      f = __rg_open(name, mode, *rest)
      f.__rg_mark_write(name) if mode.is_a?(String) && mode =~ /[wa+]/
      return f unless blk
      begin
        blk.call(f)
      ensure
        f.close unless f.closed?
      end
    end
    alias_method :__rg_delete, :delete
    def delete(*names)
      r = __rg_delete(*names)
      names.each { |n| RGWeb.call(:unpersist, RGWeb.utf8(n.to_s)) }
      r
    end
    alias unlink delete
  end
  def __rg_mark_write(n)
    @__rg_wpath = n
  end
  alias_method :__rg_close, :close
  def close
    r = __rg_close
    if @__rg_wpath && @__rg_wpath !~ /errors\\.txt\\z/
      RGWeb.call(:persist, @__rg_wpath)
    end
    r
  end
end

$DEBUG = false
$BTEST = false

module RGWeb
  # \u516C\u5171\u4E8B\u4EF6 4\u300C\u98DF\u7269\u996E\u6C34\u300D\uFF08\u5E76\u884C\uFF09\u91CC\u7684\u6570\u503C\u6821\u9A8C\uFF1A\u7ECF\u9A8C CRC\uFF08\u53D8\u91CF 152\uFF09\u6216\u6F5C\u80FD\u6821\u9A8C\uFF08\u53D8\u91CF 153\uFF09
  # \u5BF9\u4E0D\u4E0A\u65F6\u6E05\u96F6\u53D8\u91CF 19..89 \u5E76\u5F3A\u5236\u5B58\u6863\u3002\u672C\u9879\u76EE\u81EA\u7528\uFF0C\u6309\u9700\u6C42\u5173\u95ED\uFF1A\u628A\u8BE5\u6761\u4EF6\u5206\u6B67\u6539\u4E3A\u6052\u5047\u3002
  def self.patch_common_events(ces)
    n = 0
    ces.each do |ce|
      next unless ce && ce.list
      ce.list.each do |c|
        next unless c.code == 111 && c.parameters[0] == 12 && c.parameters[1].is_a?(String)
        if c.parameters[1].include?('$game_variables[152]')
          c.parameters[1] = 'false'
          n += 1
        end
      end
    end
    n
  end
end
`;var mt=`module RPG
  module Cache
    @cache = {}
    def self.load_bitmap(folder_name, filename, hue = 0)
      path = folder_name + filename
      if not @cache.include?(path) or @cache[path].disposed?
        if filename != ""
          @cache[path] = Bitmap.new(path)
        else
          @cache[path] = Bitmap.new(32, 32)
        end
      end
      if hue == 0
        @cache[path]
      else
        key = [path, hue]
        if not @cache.include?(key) or @cache[key].disposed?
          @cache[key] = @cache[path].clone
          @cache[key].hue_change(hue)
        end
        @cache[key]
      end
    end
    def self.animation(filename, hue)
      self.load_bitmap("Graphics/Animations/", filename, hue)
    end
    def self.autotile(filename)
      self.load_bitmap("Graphics/Autotiles/", filename)
    end
    def self.battleback(filename)
      self.load_bitmap("Graphics/Battlebacks/", filename)
    end
    def self.battler(filename, hue)
      self.load_bitmap("Graphics/Battlers/", filename, hue)
    end
    def self.character(filename, hue)
      self.load_bitmap("Graphics/Characters/", filename, hue)
    end
    def self.fog(filename, hue)
      self.load_bitmap("Graphics/Fogs/", filename, hue)
    end
    def self.gameover(filename)
      self.load_bitmap("Graphics/Gameovers/", filename)
    end
    def self.icon(filename)
      self.load_bitmap("Graphics/Icons/", filename)
    end
    def self.panorama(filename, hue)
      self.load_bitmap("Graphics/Panoramas/", filename, hue)
    end
    def self.picture(filename)
      self.load_bitmap("Graphics/Pictures/", filename)
    end
    def self.tileset(filename)
      self.load_bitmap("Graphics/Tilesets/", filename)
    end
    def self.title(filename)
      self.load_bitmap("Graphics/Titles/", filename)
    end
    def self.windowskin(filename)
      self.load_bitmap("Graphics/Windowskins/", filename)
    end
    def self.tile(filename, tile_id, hue)
      key = [filename, tile_id, hue]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = Bitmap.new(32, 32)
        x = (tile_id - 384) % 8 * 32
        y = (tile_id - 384) / 8 * 32
        rect = Rect.new(x, y, 32, 32)
        @cache[key].blt(0, 0, self.tileset(filename), rect)
        @cache[key].hue_change(hue)
      end
      @cache[key]
    end
    def self.clear
      @cache = {}
      GC.start
    end
  end

  class Sprite < ::Sprite
    @@_animations = []
    @@_reference_count = {}
    def initialize(viewport = nil)
      super(viewport)
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
      @_damage_duration = 0
      @_animation_duration = 0
      @_blink = false
    end
    def dispose
      dispose_damage
      dispose_animation
      dispose_loop_animation
      super
    end
    def whiten
      self.blend_type = 0
      self.color.set(255, 255, 255, 128)
      self.opacity = 255
      @_whiten_duration = 16
      @_appear_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
    end
    def appear
      self.blend_type = 0
      self.color.set(0, 0, 0, 0)
      self.opacity = 0
      @_appear_duration = 16
      @_whiten_duration = 0
      @_escape_duration = 0
      @_collapse_duration = 0
    end
    def escape
      self.blend_type = 0
      self.color.set(0, 0, 0, 0)
      self.opacity = 255
      @_escape_duration = 32
      @_whiten_duration = 0
      @_appear_duration = 0
      @_collapse_duration = 0
    end
    def collapse
      self.blend_type = 1
      self.color.set(255, 64, 64, 255)
      self.opacity = 255
      @_collapse_duration = 48
      @_whiten_duration = 0
      @_appear_duration = 0
      @_escape_duration = 0
    end
    def damage(value, critical)
      dispose_damage
      if value.is_a?(Numeric)
        damage_string = value.abs.to_s
      else
        damage_string = value.to_s
      end
      bitmap = Bitmap.new(160, 48)
      bitmap.font.name = "Arial Black"
      bitmap.font.size = 32
      bitmap.font.color.set(0, 0, 0)
      bitmap.draw_text(-1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12-1, 160, 36, damage_string, 1)
      bitmap.draw_text(-1, 12+1, 160, 36, damage_string, 1)
      bitmap.draw_text(+1, 12+1, 160, 36, damage_string, 1)
      if value.is_a?(Numeric) and value < 0
        bitmap.font.color.set(176, 255, 144)
      else
        bitmap.font.color.set(255, 255, 255)
      end
      bitmap.draw_text(0, 12, 160, 36, damage_string, 1)
      if critical
        bitmap.font.size = 20
        bitmap.font.color.set(0, 0, 0)
        bitmap.draw_text(-1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, -1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(-1, +1, 160, 20, "CRITICAL", 1)
        bitmap.draw_text(+1, +1, 160, 20, "CRITICAL", 1)
        bitmap.font.color.set(255, 255, 255)
        bitmap.draw_text(0, 0, 160, 20, "CRITICAL", 1)
      end
      @_damage_sprite = ::Sprite.new(self.viewport)
      @_damage_sprite.bitmap = bitmap
      @_damage_sprite.ox = 80
      @_damage_sprite.oy = 20
      @_damage_sprite.x = self.x
      @_damage_sprite.y = self.y - self.oy / 2
      @_damage_sprite.z = 3000
      @_damage_duration = 40
    end
    def animation(animation, hit)
      dispose_animation
      @_animation = animation
      return if @_animation == nil
      @_animation_hit = hit
      @_animation_duration = @_animation.frame_max
      animation_name = @_animation.animation_name
      animation_hue = @_animation.animation_hue
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      @_animation_sprites = []
      if @_animation.position != 3 or not @@_animations.include?(animation)
        for i in 0..15
          sprite = ::Sprite.new(self.viewport)
          sprite.bitmap = bitmap
          sprite.visible = false
          @_animation_sprites.push(sprite)
        end
        unless @@_animations.include?(animation)
          @@_animations.push(animation)
        end
      end
      update_animation
    end
    def loop_animation(animation)
      return if animation == @_loop_animation
      dispose_loop_animation
      @_loop_animation = animation
      return if @_loop_animation == nil
      @_loop_animation_index = 0
      animation_name = @_loop_animation.animation_name
      animation_hue = @_loop_animation.animation_hue
      bitmap = RPG::Cache.animation(animation_name, animation_hue)
      if @@_reference_count.include?(bitmap)
        @@_reference_count[bitmap] += 1
      else
        @@_reference_count[bitmap] = 1
      end
      @_loop_animation_sprites = []
      for i in 0..15
        sprite = ::Sprite.new(self.viewport)
        sprite.bitmap = bitmap
        sprite.visible = false
        @_loop_animation_sprites.push(sprite)
      end
      update_loop_animation
    end
    def dispose_damage
      if @_damage_sprite != nil
        @_damage_sprite.bitmap.dispose
        @_damage_sprite.dispose
        @_damage_sprite = nil
        @_damage_duration = 0
      end
    end
    def dispose_animation
      if @_animation_sprites != nil
        sprite = @_animation_sprites[0]
        if sprite != nil
          @@_reference_count[sprite.bitmap] -= 1
          if @@_reference_count[sprite.bitmap] == 0
            sprite.bitmap.dispose
          end
        end
        for sprite in @_animation_sprites
          sprite.dispose
        end
        @_animation_sprites = nil
        @_animation = nil
      end
    end
    def dispose_loop_animation
      if @_loop_animation_sprites != nil
        sprite = @_loop_animation_sprites[0]
        if sprite != nil
          @@_reference_count[sprite.bitmap] -= 1
          if @@_reference_count[sprite.bitmap] == 0
            sprite.bitmap.dispose
          end
        end
        for sprite in @_loop_animation_sprites
          sprite.dispose
        end
        @_loop_animation_sprites = nil
        @_loop_animation = nil
      end
    end
    def blink_on
      unless @_blink
        @_blink = true
        @_blink_count = 0
      end
    end
    def blink_off
      if @_blink
        @_blink = false
        self.color.set(0, 0, 0, 0)
      end
    end
    def blink?
      @_blink
    end
    def effect?
      @_whiten_duration > 0 or
      @_appear_duration > 0 or
      @_escape_duration > 0 or
      @_collapse_duration > 0 or
      @_damage_duration > 0 or
      @_animation_duration > 0
    end
    def update
      super
      if @_whiten_duration > 0
        @_whiten_duration -= 1
        self.color.alpha = 128 - (16 - @_whiten_duration) * 10
      end
      if @_appear_duration > 0
        @_appear_duration -= 1
        self.opacity = (16 - @_appear_duration) * 16
      end
      if @_escape_duration > 0
        @_escape_duration -= 1
        self.opacity = 256 - (32 - @_escape_duration) * 10
      end
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        self.opacity = 256 - (48 - @_collapse_duration) * 6
      end
      if @_damage_duration > 0
        @_damage_duration -= 1
        case @_damage_duration
        when 38..39
          @_damage_sprite.y -= 4
        when 36..37
          @_damage_sprite.y -= 2
        when 34..35
          @_damage_sprite.y += 2
        when 28..33
          @_damage_sprite.y += 4
        end
        @_damage_sprite.opacity = 256 - (12 - @_damage_duration) * 32
        if @_damage_duration == 0
          dispose_damage
        end
      end
      if @_animation != nil and (Graphics.frame_count % 2 == 0)
        @_animation_duration -= 1
        update_animation
      end
      if @_loop_animation != nil and (Graphics.frame_count % 2 == 0)
        update_loop_animation
        @_loop_animation_index += 1
        @_loop_animation_index %= @_loop_animation.frame_max
      end
      if @_blink
        @_blink_count = (@_blink_count + 1) % 32
        if @_blink_count < 16
          alpha = (16 - @_blink_count) * 6
        else
          alpha = (@_blink_count - 16) * 6
        end
        self.color.set(255, 255, 255, alpha)
      end
      @@_animations.clear
    end
    def update_animation
      if @_animation_duration > 0
        frame_index = @_animation.frame_max - @_animation_duration
        cell_data = @_animation.frames[frame_index].cell_data
        position = @_animation.position
        animation_set_sprites(@_animation_sprites, cell_data, position)
        for timing in @_animation.timings
          if timing.frame == frame_index
            animation_process_timing(timing, @_animation_hit)
          end
        end
      else
        dispose_animation
      end
    end
    def update_loop_animation
      frame_index = @_loop_animation_index
      cell_data = @_loop_animation.frames[frame_index].cell_data
      position = @_loop_animation.position
      animation_set_sprites(@_loop_animation_sprites, cell_data, position)
      for timing in @_loop_animation.timings
        if timing.frame == frame_index
          animation_process_timing(timing, true)
        end
      end
    end
    def animation_set_sprites(sprites, cell_data, position)
      for i in 0..15
        sprite = sprites[i]
        pattern = cell_data[i, 0]
        if sprite == nil or pattern == nil or pattern == -1
          sprite.visible = false if sprite != nil
          next
        end
        sprite.visible = true
        sprite.src_rect.set(pattern % 5 * 192, pattern / 5 * 192, 192, 192)
        if position == 3
          if self.viewport != nil
            sprite.x = self.viewport.rect.width / 2
            sprite.y = self.viewport.rect.height - 160
          else
            sprite.x = 320
            sprite.y = 240
          end
        else
          sprite.x = self.x - self.ox + self.src_rect.width / 2
          sprite.y = self.y - self.oy + self.src_rect.height / 2
          sprite.y -= self.src_rect.height / 4 if position == 0
          sprite.y += self.src_rect.height / 4 if position == 2
        end
        sprite.x += cell_data[i, 1]
        sprite.y += cell_data[i, 2]
        sprite.z = 2000
        sprite.ox = 96
        sprite.oy = 96
        sprite.zoom_x = cell_data[i, 3] / 100.0
        sprite.zoom_y = cell_data[i, 3] / 100.0
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
        sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
        sprite.blend_type = cell_data[i, 7]
      end
    end
    def animation_process_timing(timing, hit)
      if (timing.condition == 0) or
         (timing.condition == 1 and hit == true) or
         (timing.condition == 2 and hit == false)
        if timing.se.name != ""
          se = timing.se
          Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
        end
        case timing.flash_scope
        when 1
          self.flash(timing.flash_color, timing.flash_duration * 2)
        when 2
          if self.viewport != nil
            self.viewport.flash(timing.flash_color, timing.flash_duration * 2)
          end
        when 3
          self.flash(nil, timing.flash_duration * 2)
        end
      end
    end
    def x=(x)
      sx = x - self.x
      if sx != 0
        if @_animation_sprites != nil
          for i in 0..15
            @_animation_sprites[i].x += sx
          end
        end
        if @_loop_animation_sprites != nil
          for i in 0..15
            @_loop_animation_sprites[i].x += sx
          end
        end
      end
      super
    end
    def y=(y)
      sy = y - self.y
      if sy != 0
        if @_animation_sprites != nil
          for i in 0..15
            @_animation_sprites[i].y += sy
          end
        end
        if @_loop_animation_sprites != nil
          for i in 0..15
            @_loop_animation_sprites[i].y += sy
          end
        end
      end
      super
    end
  end

  class Weather
    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      color1 = Color.new(255, 255, 255, 255)
      color2 = Color.new(255, 255, 255, 128)
      @rain_bitmap = Bitmap.new(7, 56)
      for i in 0..6
        @rain_bitmap.fill_rect(6-i, i*8, 1, 8, color1)
      end
      @storm_bitmap = Bitmap.new(34, 64)
      for i in 0..31
        @storm_bitmap.fill_rect(33-i, i*2, 1, 2, color2)
        @storm_bitmap.fill_rect(32-i, i*2, 1, 2, color1)
        @storm_bitmap.fill_rect(31-i, i*2, 1, 2, color2)
      end
      @snow_bitmap = Bitmap.new(6, 6)
      @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
      @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
      @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
      @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
      @sprites = []
      for i in 1..40
        sprite = Sprite.new(viewport)
        sprite.z = 1000
        sprite.visible = false
        sprite.opacity = 0
        @sprites.push(sprite)
      end
    end
    def dispose
      for sprite in @sprites
        sprite.dispose
      end
      @rain_bitmap.dispose
      @storm_bitmap.dispose
      @snow_bitmap.dispose
    end
    def type=(type)
      return if @type == type
      @type = type
      case @type
      when 1
        bitmap = @rain_bitmap
      when 2
        bitmap = @storm_bitmap
      when 3
        bitmap = @snow_bitmap
      else
        bitmap = nil
      end
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          sprite.visible = (i <= @max)
          sprite.bitmap = bitmap
        end
      end
    end
    def ox=(ox)
      return if @ox == ox;
      @ox = ox
      for sprite in @sprites
        sprite.ox = @ox
      end
    end
    def oy=(oy)
      return if @oy == oy;
      @oy = oy
      for sprite in @sprites
        sprite.oy = @oy
      end
    end
    def max=(max)
      return if @max == max;
      @max = [[max, 0].max, 40].min
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          sprite.visible = (i <= @max)
        end
      end
    end
    def update
      return if @type == 0
      for i in 1..@max
        sprite = @sprites[i]
        if sprite == nil
          break
        end
        if @type == 1
          sprite.x -= 2
          sprite.y += 16
          sprite.opacity -= 8
        end
        if @type == 2
          sprite.x -= 8
          sprite.y += 16
          sprite.opacity -= 12
        end
        if @type == 3
          sprite.x -= 2
          sprite.y += 8
          sprite.opacity -= 8
        end
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64 or x < -50 or x > 750 or y < -300 or y > 500
          sprite.x = rand(800) - 50 + @ox
          sprite.y = rand(800) - 200 + @oy
          sprite.opacity = 255
        end
      end
    end
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy
  end

  class Map
    def initialize(width, height)
      @tileset_id = 1
      @width = width
      @height = height
      @autoplay_bgm = false
      @bgm = RPG::AudioFile.new
      @autoplay_bgs = false
      @bgs = RPG::AudioFile.new("", 80)
      @encounter_list = []
      @encounter_step = 30
      @data = Table.new(width, height, 3)
      @events = {}
    end
    attr_accessor :tileset_id
    attr_accessor :width
    attr_accessor :height
    attr_accessor :autoplay_bgm
    attr_accessor :bgm
    attr_accessor :autoplay_bgs
    attr_accessor :bgs
    attr_accessor :encounter_list
    attr_accessor :encounter_step
    attr_accessor :data
    attr_accessor :events
  end

  class MapInfo
    def initialize
      @name = ""
      @parent_id = 0
      @order = 0
      @expanded = false
      @scroll_x = 0
      @scroll_y = 0
    end
    attr_accessor :name
    attr_accessor :parent_id
    attr_accessor :order
    attr_accessor :expanded
    attr_accessor :scroll_x
    attr_accessor :scroll_y
  end

  class Event
    class Page
      class Condition
        def initialize
          @switch1_valid = false
          @switch2_valid = false
          @variable_valid = false
          @self_switch_valid = false
          @switch1_id = 1
          @switch2_id = 1
          @variable_id = 1
          @variable_value = 0
          @self_switch_ch = "A"
        end
        attr_accessor :switch1_valid
        attr_accessor :switch2_valid
        attr_accessor :variable_valid
        attr_accessor :self_switch_valid
        attr_accessor :switch1_id
        attr_accessor :switch2_id
        attr_accessor :variable_id
        attr_accessor :variable_value
        attr_accessor :self_switch_ch
      end

      class Graphic
        def initialize
          @tile_id = 0
          @character_name = ""
          @character_hue = 0
          @direction = 2
          @pattern = 0
          @opacity = 255
          @blend_type = 0
        end
        attr_accessor :tile_id
        attr_accessor :character_name
        attr_accessor :character_hue
        attr_accessor :direction
        attr_accessor :pattern
        attr_accessor :opacity
        attr_accessor :blend_type
      end

      def initialize
        @condition = RPG::Event::Page::Condition.new
        @graphic = RPG::Event::Page::Graphic.new
        @move_type = 0
        @move_speed = 3
        @move_frequency = 3
        @move_route = RPG::MoveRoute.new
        @walk_anime = true
        @step_anime = false
        @direction_fix = false
        @through = false
        @always_on_top = false
        @trigger = 0
        @list = [RPG::EventCommand.new]
      end
      attr_accessor :condition
      attr_accessor :graphic
      attr_accessor :move_type
      attr_accessor :move_speed
      attr_accessor :move_frequency
      attr_accessor :move_route
      attr_accessor :walk_anime
      attr_accessor :step_anime
      attr_accessor :direction_fix
      attr_accessor :through
      attr_accessor :always_on_top
      attr_accessor :trigger
      attr_accessor :list
    end

    def initialize(x, y)
      @id = 0
      @name = ""
      @x = x
      @y = y
      @pages = [RPG::Event::Page.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :x
    attr_accessor :y
    attr_accessor :pages
  end

  class EventCommand
    def initialize(code = 0, indent = 0, parameters = [])
      @code = code
      @indent = indent
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :indent
    attr_accessor :parameters
  end

  class MoveRoute
    def initialize
      @repeat = true
      @skippable = false
      @list = [RPG::MoveCommand.new]
    end
    attr_accessor :repeat
    attr_accessor :skippable
    attr_accessor :list
  end

  class MoveCommand
    def initialize(code = 0, parameters = [])
      @code = code
      @parameters = parameters
    end
    attr_accessor :code
    attr_accessor :parameters
  end

  class Actor
    def initialize
      @id = 0
      @name = ""
      @class_id = 1
      @initial_level = 1
      @final_level = 99
      @exp_basis = 30
      @exp_inflation = 30
      @character_name = ""
      @character_hue = 0
      @battler_name = ""
      @battler_hue = 0
      @parameters = Table.new(6,100)
      for i in 1..99
        @parameters[0,i] = 500+i*50
        @parameters[1,i] = 500+i*50
        @parameters[2,i] = 50+i*5
        @parameters[3,i] = 50+i*5
        @parameters[4,i] = 50+i*5
        @parameters[5,i] = 50+i*5
      end
      @weapon_id = 0
      @armor1_id = 0
      @armor2_id = 0
      @armor3_id = 0
      @armor4_id = 0
      @weapon_fix = false
      @armor1_fix = false
      @armor2_fix = false
      @armor3_fix = false
      @armor4_fix = false
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :class_id
    attr_accessor :initial_level
    attr_accessor :final_level
    attr_accessor :exp_basis
    attr_accessor :exp_inflation
    attr_accessor :character_name
    attr_accessor :character_hue
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :parameters
    attr_accessor :weapon_id
    attr_accessor :armor1_id
    attr_accessor :armor2_id
    attr_accessor :armor3_id
    attr_accessor :armor4_id
    attr_accessor :weapon_fix
    attr_accessor :armor1_fix
    attr_accessor :armor2_fix
    attr_accessor :armor3_fix
    attr_accessor :armor4_fix
  end

  class Class
    class Learning
      def initialize
        @level = 1
        @skill_id = 1
      end
      attr_accessor :level
      attr_accessor :skill_id
    end

    def initialize
      @id = 0
      @name = ""
      @position = 0
      @weapon_set = []
      @armor_set = []
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @learnings = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :position
    attr_accessor :weapon_set
    attr_accessor :armor_set
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :learnings
  end

  class Skill
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @scope = 0
      @occasion = 1
      @animation1_id = 0
      @animation2_id = 0
      @menu_se = RPG::AudioFile.new("", 80)
      @common_event_id = 0
      @sp_cost = 0
      @power = 0
      @atk_f = 0
      @eva_f = 0
      @str_f = 0
      @dex_f = 0
      @agi_f = 0
      @int_f = 100
      @hit = 100
      @pdef_f = 0
      @mdef_f = 100
      @variance = 15
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :menu_se
    attr_accessor :common_event_id
    attr_accessor :sp_cost
    attr_accessor :power
    attr_accessor :atk_f
    attr_accessor :eva_f
    attr_accessor :str_f
    attr_accessor :dex_f
    attr_accessor :agi_f
    attr_accessor :int_f
    attr_accessor :hit
    attr_accessor :pdef_f
    attr_accessor :mdef_f
    attr_accessor :variance
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Item
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @scope = 0
      @occasion = 0
      @animation1_id = 0
      @animation2_id = 0
      @menu_se = RPG::AudioFile.new("", 80)
      @common_event_id = 0
      @price = 0
      @consumable = true
      @parameter_type = 0
      @parameter_points = 0
      @recover_hp_rate = 0
      @recover_hp = 0
      @recover_sp_rate = 0
      @recover_sp = 0
      @hit = 100
      @pdef_f = 0
      @mdef_f = 0
      @variance = 0
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :scope
    attr_accessor :occasion
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :menu_se
    attr_accessor :common_event_id
    attr_accessor :price
    attr_accessor :consumable
    attr_accessor :parameter_type
    attr_accessor :parameter_points
    attr_accessor :recover_hp_rate
    attr_accessor :recover_hp
    attr_accessor :recover_sp_rate
    attr_accessor :recover_sp
    attr_accessor :hit
    attr_accessor :pdef_f
    attr_accessor :mdef_f
    attr_accessor :variance
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Weapon
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @animation1_id = 0
      @animation2_id = 0
      @price = 0
      @atk = 0
      @pdef = 0
      @mdef = 0
      @str_plus = 0
      @dex_plus = 0
      @agi_plus = 0
      @int_plus = 0
      @element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :price
    attr_accessor :atk
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :str_plus
    attr_accessor :dex_plus
    attr_accessor :agi_plus
    attr_accessor :int_plus
    attr_accessor :element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Armor
    def initialize
      @id = 0
      @name = ""
      @icon_name = ""
      @description = ""
      @kind = 0
      @auto_state_id = 0
      @price = 0
      @pdef = 0
      @mdef = 0
      @eva = 0
      @str_plus = 0
      @dex_plus = 0
      @agi_plus = 0
      @int_plus = 0
      @guard_element_set = []
      @guard_state_set = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :icon_name
    attr_accessor :description
    attr_accessor :kind
    attr_accessor :auto_state_id
    attr_accessor :price
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :eva
    attr_accessor :str_plus
    attr_accessor :dex_plus
    attr_accessor :agi_plus
    attr_accessor :int_plus
    attr_accessor :guard_element_set
    attr_accessor :guard_state_set
  end

  class Enemy
    class Action
      def initialize
        @kind = 0
        @basic = 0
        @skill_id = 1
        @condition_turn_a = 0
        @condition_turn_b = 1
        @condition_hp = 100
        @condition_level = 1
        @condition_switch_id = 0
        @rating = 5
      end
      attr_accessor :kind
      attr_accessor :basic
      attr_accessor :skill_id
      attr_accessor :condition_turn_a
      attr_accessor :condition_turn_b
      attr_accessor :condition_hp
      attr_accessor :condition_level
      attr_accessor :condition_switch_id
      attr_accessor :rating
    end

    def initialize
      @id = 0
      @name = ""
      @battler_name = ""
      @battler_hue = 0
      @maxhp = 500
      @maxsp = 500
      @str = 50
      @dex = 50
      @agi = 50
      @int = 50
      @atk = 100
      @pdef = 100
      @mdef = 100
      @eva = 0
      @animation1_id = 0
      @animation2_id = 0
      @element_ranks = Table.new(1)
      @state_ranks = Table.new(1)
      @actions = [RPG::Enemy::Action.new]
      @exp = 0
      @gold = 0
      @item_id = 0
      @weapon_id = 0
      @armor_id = 0
      @treasure_prob = 100
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :maxhp
    attr_accessor :maxsp
    attr_accessor :str
    attr_accessor :dex
    attr_accessor :agi
    attr_accessor :int
    attr_accessor :atk
    attr_accessor :pdef
    attr_accessor :mdef
    attr_accessor :eva
    attr_accessor :animation1_id
    attr_accessor :animation2_id
    attr_accessor :element_ranks
    attr_accessor :state_ranks
    attr_accessor :actions
    attr_accessor :exp
    attr_accessor :gold
    attr_accessor :item_id
    attr_accessor :weapon_id
    attr_accessor :armor_id
    attr_accessor :treasure_prob
  end

  class Troop
    class Member
      def initialize
        @enemy_id = 1
        @x = 0
        @y = 0
        @hidden = false
        @immortal = false
      end
      attr_accessor :enemy_id
      attr_accessor :x
      attr_accessor :y
      attr_accessor :hidden
      attr_accessor :immortal
    end

    class Page
      class Condition
        def initialize
          @turn_valid = false
          @enemy_valid = false
          @actor_valid = false
          @switch_valid = false
          @turn_a = 0
          @turn_b = 0
          @enemy_index = 0
          @enemy_hp = 50
          @actor_id = 1
          @actor_hp = 50
          @switch_id = 1
        end
        attr_accessor :turn_valid
        attr_accessor :enemy_valid
        attr_accessor :actor_valid
        attr_accessor :switch_valid
        attr_accessor :turn_a
        attr_accessor :turn_b
        attr_accessor :enemy_index
        attr_accessor :enemy_hp
        attr_accessor :actor_id
        attr_accessor :actor_hp
        attr_accessor :switch_id
      end

      def initialize
        @condition = RPG::Troop::Page::Condition.new
        @span = 0
        @list = [RPG::EventCommand.new]
      end
      attr_accessor :condition
      attr_accessor :span
      attr_accessor :list
    end

    def initialize
      @id = 0
      @name = ""
      @members = []
      @pages = [RPG::BattleEventPage.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :members
    attr_accessor :pages
  end

  class State
    def initialize
      @id = 0
      @name = ""
      @animation_id = 0
      @restriction = 0
      @nonresistance = false
      @zero_hp = false
      @cant_get_exp = false
      @cant_evade = false
      @slip_damage = false
      @rating = 5
      @hit_rate = 100
      @maxhp_rate = 100
      @maxsp_rate = 100
      @str_rate = 100
      @dex_rate = 100
      @agi_rate = 100
      @int_rate = 100
      @atk_rate = 100
      @pdef_rate = 100
      @mdef_rate = 100
      @eva = 0
      @battle_only = true
      @hold_turn = 0
      @auto_release_prob = 0
      @shock_release_prob = 0
      @guard_element_set = []
      @plus_state_set = []
      @minus_state_set = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation_id
    attr_accessor :restriction
    attr_accessor :nonresistance
    attr_accessor :zero_hp
    attr_accessor :cant_get_exp
    attr_accessor :cant_evade
    attr_accessor :slip_damage
    attr_accessor :rating
    attr_accessor :hit_rate
    attr_accessor :maxhp_rate
    attr_accessor :maxsp_rate
    attr_accessor :str_rate
    attr_accessor :dex_rate
    attr_accessor :agi_rate
    attr_accessor :int_rate
    attr_accessor :atk_rate
    attr_accessor :pdef_rate
    attr_accessor :mdef_rate
    attr_accessor :eva
    attr_accessor :battle_only
    attr_accessor :hold_turn
    attr_accessor :auto_release_prob
    attr_accessor :shock_release_prob
    attr_accessor :guard_element_set
    attr_accessor :plus_state_set
    attr_accessor :minus_state_set
  end

  class Animation
    class Frame
      def initialize
        @cell_max = 0
        @cell_data = Table.new(0, 0)
      end
      attr_accessor :cell_max
      attr_accessor :cell_data
    end

    class Timing
      def initialize
        @frame = 0
        @se = RPG::AudioFile.new("", 80)
        @flash_scope = 0
        @flash_color = Color.new(255,255,255,255)
        @flash_duration = 5
        @condition = 0
      end
      attr_accessor :frame
      attr_accessor :se
      attr_accessor :flash_scope
      attr_accessor :flash_color
      attr_accessor :flash_duration
      attr_accessor :condition
    end

    def initialize
      @id = 0
      @name = ""
      @animation_name = ""
      @animation_hue = 0
      @position = 1
      @frame_max = 1
      @frames = [RPG::Animation::Frame.new]
      @timings = []
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :animation_name
    attr_accessor :animation_hue
    attr_accessor :position
    attr_accessor :frame_max
    attr_accessor :frames
    attr_accessor :timings
  end

  class Tileset
    def initialize
      @id = 0
      @name = ""
      @tileset_name = ""
      @autotile_names = [""]*7
      @panorama_name = ""
      @panorama_hue = 0
      @fog_name = ""
      @fog_hue = 0
      @fog_opacity = 64
      @fog_blend_type = 0
      @fog_zoom = 200
      @fog_sx = 0
      @fog_sy = 0
      @battleback_name = ""
      @passages = Table.new(384)
      @priorities = Table.new(384)
      @priorities[0] = 5
      @terrain_tags = Table.new(384)
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :tileset_name
    attr_accessor :autotile_names
    attr_accessor :panorama_name
    attr_accessor :panorama_hue
    attr_accessor :fog_name
    attr_accessor :fog_hue
    attr_accessor :fog_opacity
    attr_accessor :fog_blend_type
    attr_accessor :fog_zoom
    attr_accessor :fog_sx
    attr_accessor :fog_sy
    attr_accessor :battleback_name
    attr_accessor :passages
    attr_accessor :priorities
    attr_accessor :terrain_tags
  end

  class CommonEvent
    def initialize
      @id = 0
      @name = ""
      @trigger = 0
      @switch_id = 1
      @list = [RPG::EventCommand.new]
    end
    attr_accessor :id
    attr_accessor :name
    attr_accessor :trigger
    attr_accessor :switch_id
    attr_accessor :list
  end

  class System
    class Words
      def initialize
        @gold = ""
        @hp = ""
        @sp = ""
        @str = ""
        @dex = ""
        @agi = ""
        @int = ""
        @atk = ""
        @pdef = ""
        @mdef = ""
        @weapon = ""
        @armor1 = ""
        @armor2 = ""
        @armor3 = ""
        @armor4 = ""
        @attack = ""
        @skill = ""
        @guard = ""
        @item = ""
        @equip = ""
      end
      attr_accessor :gold
      attr_accessor :hp
      attr_accessor :sp
      attr_accessor :str
      attr_accessor :dex
      attr_accessor :agi
      attr_accessor :int
      attr_accessor :atk
      attr_accessor :pdef
      attr_accessor :mdef
      attr_accessor :weapon
      attr_accessor :armor1
      attr_accessor :armor2
      attr_accessor :armor3
      attr_accessor :armor4
      attr_accessor :attack
      attr_accessor :skill
      attr_accessor :guard
      attr_accessor :item
      attr_accessor :equip
    end

    class TestBattler
      def initialize
        @actor_id = 1
        @level = 1
        @weapon_id = 0
        @armor1_id = 0
        @armor2_id = 0
        @armor3_id = 0
        @armor4_id = 0
      end
      attr_accessor :actor_id
      attr_accessor :level
      attr_accessor :weapon_id
      attr_accessor :armor1_id
      attr_accessor :armor2_id
      attr_accessor :armor3_id
      attr_accessor :armor4_id
    end

    def initialize
      @magic_number = 0
      @party_members = [1]
      @elements = [nil, ""]
      @switches = [nil, ""]
      @variables = [nil, ""]
      @windowskin_name = ""
      @title_name = ""
      @gameover_name = ""
      @battle_transition = ""
      @title_bgm = RPG::AudioFile.new
      @battle_bgm = RPG::AudioFile.new
      @battle_end_me = RPG::AudioFile.new
      @gameover_me = RPG::AudioFile.new
      @cursor_se = RPG::AudioFile.new("", 80)
      @decision_se = RPG::AudioFile.new("", 80)
      @cancel_se = RPG::AudioFile.new("", 80)
      @buzzer_se = RPG::AudioFile.new("", 80)
      @equip_se = RPG::AudioFile.new("", 80)
      @shop_se = RPG::AudioFile.new("", 80)
      @save_se = RPG::AudioFile.new("", 80)
      @load_se = RPG::AudioFile.new("", 80)
      @battle_start_se = RPG::AudioFile.new("", 80)
      @escape_se = RPG::AudioFile.new("", 80)
      @actor_collapse_se = RPG::AudioFile.new("", 80)
      @enemy_collapse_se = RPG::AudioFile.new("", 80)
      @words = RPG::System::Words.new
      @test_battlers = []
      @test_troop_id = 1
      @start_map_id = 1
      @start_x = 0
      @start_y = 0
      @battleback_name = ""
      @battler_name = ""
      @battler_hue = 0
      @edit_map_id = 1
    end
    attr_accessor :magic_number
    attr_accessor :party_members
    attr_accessor :elements
    attr_accessor :switches
    attr_accessor :variables
    attr_accessor :windowskin_name
    attr_accessor :title_name
    attr_accessor :gameover_name
    attr_accessor :battle_transition
    attr_accessor :title_bgm
    attr_accessor :battle_bgm
    attr_accessor :battle_end_me
    attr_accessor :gameover_me
    attr_accessor :cursor_se
    attr_accessor :decision_se
    attr_accessor :cancel_se
    attr_accessor :buzzer_se
    attr_accessor :equip_se
    attr_accessor :shop_se
    attr_accessor :save_se
    attr_accessor :load_se
    attr_accessor :battle_start_se
    attr_accessor :escape_se
    attr_accessor :actor_collapse_se
    attr_accessor :enemy_collapse_se
    attr_accessor :words
    attr_accessor :test_battlers
    attr_accessor :test_troop_id
    attr_accessor :start_map_id
    attr_accessor :start_x
    attr_accessor :start_y
    attr_accessor :battleback_name
    attr_accessor :battler_name
    attr_accessor :battler_hue
    attr_accessor :edit_map_id
  end

  class AudioFile
    def initialize(name = "", volume = 100, pitch = 100)
      @name = name
      @volume = volume
      @pitch = pitch
    end
    attr_accessor :name
    attr_accessor :volume
    attr_accessor :pitch
  end
end
`;var bt=`require 'js'
Dir.chdir('/game')
$RG_JS = JS.global[:RG]
begin
  scripts = JS.global[:RGScripts]
  n = scripts[:length].to_i
  n.times do |i|
    s = scripts[i]
    name = s[0].to_s
    code = s[1].to_s
    TOPLEVEL_BINDING.eval(code, name, 1)
  end
  $RG_JS.call(:onExit)
rescue SystemExit
  $RG_JS.call(:onExit)
rescue Exception => e
  bt = (e.backtrace || [])[0, 16].join("\\n")
  $RG_JS.call(:onError, "#{e.class}: #{e.message}\\n#{bt}")
end
nil
`;var se="bjyxts121:",y=l=>document.getElementById(l),Xe=matchMedia("(pointer: coarse)").matches||"ontouchstart"in window;function fe(l,e){y("load-text").textContent=l,e!=null&&(y("load-bar-inner").style.width=`${Math.round(e*100)}%`)}async function Gt(l,e){let t=await fetch(l);if(!t.ok)throw new Error(`\u4E0B\u8F7D\u5931\u8D25: ${l} (${t.status})`);let n=+t.headers.get("content-length")||0;if(!t.body||!n){let c=await t.arrayBuffer();return e(1),c}let a=t.body.getReader(),s=[],r=0;for(;;){let{done:c,value:d}=await a.read();if(c)break;s.push(d),r+=d.length,e(Math.min(1,r/n))}let i=new Uint8Array(r),o=0;for(let c of s)i.set(c,o),o+=c.length;return i.buffer}var Pe=class extends Map{get(e){let t=super.get(e);if(t!==void 0)return t;let n=String(e).toLowerCase();for(let[a,s]of this)if(a.toLowerCase()===n)return s}has(e){return this.get(e)!==void 0}};function kt(l,e){let t=l;for(let n of e){let a=t.contents.get(n);a||(a=new z(new Pe),a.parent=t,t.contents.set(n,a)),t=a}return t}function gt(l,e,t){let n=e.split("/").filter(Boolean),a=n.pop();kt(l,n).contents.set(a,new q(t))}function yt(l,e){let t=String(e).replace(/\\/g,"/").split("/").filter(a=>a&&a!=="."),n=l;for(let a of t)if(!(n instanceof z)||(n=n.contents.get(a),!n))return null;return n instanceof q?n:null}function Pt(l){let e="";for(let t=0;t<l.length;t+=32768)e+=String.fromCharCode.apply(null,l.subarray(t,t+32768));return btoa(e)}function Dt(l){let e=atob(l),t=new Uint8Array(e.length);for(let n=0;n<e.length;n++)t[n]=e.charCodeAt(n);return t}var Qe={save(l,e){try{localStorage.setItem(se+l,Pt(e))}catch(t){console.error(t),re.toast("\u5B58\u6863\u5199\u5165\u6D4F\u89C8\u5668\u5B58\u50A8\u5931\u8D25\uFF08\u7A7A\u95F4\u4E0D\u8DB3\u6216\u5904\u4E8E\u9690\u79C1\u6A21\u5F0F\uFF09")}},remove(l){localStorage.removeItem(se+l)},all(){let l=[];for(let e=0;e<localStorage.length;e++){let t=localStorage.key(e);t&&t.startsWith(se)&&l.push([t.slice(se.length),Dt(localStorage.getItem(t))])}return l}},re={alert(l){return new Promise(e=>{let t=y("dialog");y("dlg-text").textContent=l,y("dlg-input").style.display="none",y("dlg-cancel").style.display="none",t.classList.add("show"),v&&v.clearInput();let n=y("dlg-ok"),a=()=>{t.classList.remove("show"),n.onclick=null,document.removeEventListener("keydown",s,!0),e(0)},s=r=>{(r.key==="Enter"||r.key==="Escape"||r.key===" ")&&(r.preventDefault(),r.stopPropagation(),a())};n.onclick=a,setTimeout(()=>document.addEventListener("keydown",s,!0),150)})},prompt(l,e,t){return new Promise(n=>{let a=y("dialog"),s=y("dlg-input");y("dlg-text").textContent=l,s.style.display="",s.value=e||"",s.maxLength=t>0?t:524288,y("dlg-cancel").style.display="",a.classList.add("show"),v&&v.clearInput(),setTimeout(()=>{s.focus(),s.select()},50);let r=i=>{a.classList.remove("show"),y("dlg-ok").onclick=null,y("dlg-cancel").onclick=null,s.onkeydown=null,s.blur(),v&&v.clearInput(),n(i)};y("dlg-ok").onclick=()=>{let i=s.value.trim();t>0&&(i=[...i].slice(0,t).join("")),r(i||e||"")},y("dlg-cancel").onclick=()=>r(e||""),s.onkeydown=i=>{i.stopPropagation(),i.key==="Enter"&&!i.isComposing&&y("dlg-ok").onclick()}})},toast(l){let e=y("toast");e.textContent=l,e.classList.add("show"),clearTimeout(re._tt),re._tt=setTimeout(()=>e.classList.remove("show"),2600)}},v=null,wt={ArrowDown:[2],ArrowLeft:[4],ArrowRight:[6],ArrowUp:[8],Numpad2:[2],Numpad4:[4],Numpad6:[6],Numpad8:[8],Enter:[13],NumpadEnter:[13],Space:[13],KeyC:[13],Escape:[12],KeyX:[12],Numpad0:[12],Backspace:[12],ShiftLeft:[11,21],ShiftRight:[11,21],KeyZ:[11],KeyA:[14],KeyS:[15],KeyD:[16],KeyQ:[17],PageUp:[17],KeyW:[18],PageDown:[18],ControlLeft:[22],ControlRight:[22],AltLeft:[23],AltRight:[23],F5:[25],F6:[26],F7:[27],F8:[28],F9:[29]};function zt(){window.addEventListener("keydown",l=>{if(y("dialog").classList.contains("show")||y("settings").classList.contains("show"))return;let e=wt[l.code];if(e){l.preventDefault();for(let t of e)v.pressCode(t,!0,!1)}}),window.addEventListener("keyup",l=>{let e=wt[l.code];if(e){l.preventDefault();for(let t of e)v.pressCode(t,!1,!1)}}),window.addEventListener("blur",()=>v&&v.clearInput())}function Ut(){let l=y("dpad"),e=null,t=0,n=r=>{if(r!==t){t&&v.pressCode(t,!1,!0),t=r,r&&(v.pressCode(r,!0,!0),navigator.vibrate&&navigator.vibrate(8));for(let i of l.querySelectorAll(".dir"))i.classList.toggle("on",+i.dataset.code===r)}},a=r=>{let i=l.getBoundingClientRect(),o=r.clientX-(i.left+i.width/2),c=r.clientY-(i.top+i.height/2);return Math.hypot(o,c)<i.width*.12?0:Math.abs(o)>Math.abs(c)?o>0?6:4:c>0?2:8};l.addEventListener("pointerdown",r=>{r.preventDefault(),e=r.pointerId,l.setPointerCapture(r.pointerId),v.audio.unlock(),n(a(r))}),l.addEventListener("pointermove",r=>{r.pointerId===e&&n(a(r))});let s=r=>{r.pointerId===e&&(e=null,n(0))};l.addEventListener("pointerup",s),l.addEventListener("pointercancel",s),l.addEventListener("lostpointercapture",s);for(let r of document.querySelectorAll(".btn[data-code]")){let i=r.dataset.code.split(",").map(Number),o=new Set,c=_=>{_.preventDefault(),r.setPointerCapture(_.pointerId),o.add(_.pointerId),v.audio.unlock(),r.classList.add("on");for(let f of i)v.pressCode(f,!0,!0);navigator.vibrate&&navigator.vibrate(10)},d=_=>{if(o.delete(_.pointerId)&&!o.size){r.classList.remove("on");for(let f of i)v.pressCode(f,!1,!0)}};r.addEventListener("pointerdown",c),r.addEventListener("pointerup",d),r.addEventListener("pointercancel",d),r.addEventListener("lostpointercapture",d)}document.addEventListener("contextmenu",r=>r.preventDefault())}function ye(){let l=window.innerWidth,e=window.innerHeight,t=e>l;document.body.classList.toggle("portrait",t&&Xe);let n=document.body.classList.contains("pad-on"),a=0;n&&(a=Math.min(200,Math.max(120,l*.17)));let s=Math.min(e/480,(l-a*2)/640),r=!1;n&&s<e/480*.72&&(s=Math.min(e/480,l/640),r=!0),document.body.classList.toggle("pad-overlay",r);let i=y("screen");i.style.width=`${Math.floor(640*s)}px`,i.style.height=`${Math.floor(480*s)}px`;let o=r?a:Math.max(a,(l-Math.floor(640*s))/2);document.documentElement.style.setProperty("--side",`${o}px`),document.documentElement.style.setProperty("--pad",`${Math.min(o*.86,e*.46)}px`)}async function Rt(){let l=document.documentElement;try{!document.fullscreenElement&&l.requestFullscreen?await l.requestFullscreen({navigationUI:"hide"}):l.webkitRequestFullscreen&&l.webkitRequestFullscreen()}catch{}try{screen.orientation&&screen.orientation.lock&&await screen.orientation.lock("landscape")}catch{}}function Bt(){let l=y("settings");y("gear").addEventListener("click",()=>{l.classList.add("show"),v.clearInput()}),y("set-close").addEventListener("click",()=>l.classList.remove("show")),y("set-full").addEventListener("click",()=>{document.fullscreenElement?document.exitFullscreen():Rt()}),y("set-pad").addEventListener("click",()=>{document.body.classList.toggle("pad-on"),localStorage.setItem(se+"#pad",document.body.classList.contains("pad-on")?"1":"0"),ye()});let e=(t,n)=>{let a=y(t),s=`${se}#vol_${n}`;a.value=localStorage.getItem(s)??"100";let r=()=>{v.audio.setMaster(n,a.value/100),localStorage.setItem(s,a.value)};a.addEventListener("input",r),r()};e("set-bgm","bgm"),e("set-se","se"),y("set-export").addEventListener("click",()=>{let t=yt(window.__gameRoot,"Gmud.sav");if(!t){re.toast("\u8FD8\u6CA1\u6709\u5B58\u6863");return}let n=new Blob([t.data],{type:"application/octet-stream"}),a=document.createElement("a");a.href=URL.createObjectURL(n);let s=new Date;a.download=`Gmud_${s.getFullYear()}${String(s.getMonth()+1).padStart(2,"0")}${String(s.getDate()).padStart(2,"0")}.sav`,a.click(),setTimeout(()=>URL.revokeObjectURL(a.href),2e3)}),y("set-import").addEventListener("click",()=>y("import-file").click()),y("import-file").addEventListener("change",async t=>{let n=t.target.files[0];if(!n)return;let a=new Uint8Array(await n.arrayBuffer());if(a.length<8){re.toast("\u6587\u4EF6\u65E0\u6548");return}Qe.save("Gmud.sav",a),await re.alert("\u5B58\u6863\u5DF2\u5BFC\u5165\uFF08\u4E0E PC \u7248 Gmud.sav \u901A\u7528\uFF09\u3002\u9875\u9762\u5C06\u91CD\u65B0\u8F7D\u5165\u3002"),location.reload()}),y("set-reset").addEventListener("click",async()=>{location.reload()}),localStorage.getItem(se+"#pad")==="0"&&document.body.classList.remove("pad-on")}async function jt(){Xe&&document.body.classList.add("touch","pad-on"),ye(),window.addEventListener("resize",ye),window.addEventListener("orientationchange",()=>setTimeout(ye,200)),fe("\u8BFB\u53D6\u8D44\u6E90\u6E05\u5355\u2026",0);let l=await(await fetch("game/manifest.json")).json(),e=(async()=>{let u=await Gt(l.wasm,m=>fe(`\u4E0B\u8F7D\u5F15\u64CE ${Math.round(m*100)}%`,m*.7));return fe("\u7F16\u8BD1\u5F15\u64CE\u2026",.72),WebAssembly.compile(u)})(),t=new Map,n=Promise.all(l.images.map(u=>new Promise(m=>{let b=new Image;b.onload=()=>{t.set(u.replace(/\.(png|jpg|jpeg|bmp)$/i,"").toLowerCase(),b),m()},b.onerror=()=>{console.warn("image failed",u),m()},b.src=`game/${encodeURI(u)}`}))),a=new Map;for(let u of l.audio)a.set(u.replace(/\.(mp3|ogg|wav|m4a)$/i,"").toLowerCase(),`game/${encodeURI(u)}`);let s=new z(new Pe);window.__gameRoot=s;let r=Promise.all(l.data.map(async u=>{let m=await fetch(`game/${encodeURI(u)}`);gt(s,u,new Uint8Array(await m.arrayBuffer()))})),i=fetch("game/scripts.json").then(u=>u.json()),o=document.fonts&&document.fonts.load?Promise.race([document.fonts.load("22px GameSong","\u82F1\u96C4\u575B\u8BF4"),new Promise(u=>setTimeout(u,15e3))]).catch(()=>{}):Promise.resolve(),[c,d]=await Promise.all([e,i,n,r,o]).then(u=>[u[0],u[1]]);for(let[u,m]of Qe.all())u.startsWith("#")||gt(s,u,m);fe("\u542F\u52A8 Ruby \u865A\u62DF\u673A\u2026",.85);let _=[new oe(new q([])),ce.lineBuffered(u=>console.log("[stdout]",u)),ce.lineBuffered(u=>console.warn("[stderr]",u)),new ge("/game",s.contents)],f=_[3];window.__gameRoot=f.dir;let h=new Ye(["ruby"],[],_,{debug:!1}),{vm:p}=await Le.instantiateModule({module:c,wasip1:h});window.__vm=p,v=new ke({canvas:y("screen"),images:t,audioFiles:a,fs:{read:u=>{let m=yt(window.__gameRoot,u);return m?m.data:null}},storage:Qe,ui:re}),window.RG=v,window.RGScripts=d,v.onExit=()=>{v.audio.pauseAll(),y("ended").classList.add("show")},v.onError=u=>{console.error(String(u)),v.audio.pauseAll(),y("err-text").textContent=String(u),y("error").classList.add("show")},zt(),Ut(),Bt(),ye(),fe("\u52A0\u8F7D\u811A\u672C\u2026",.92),p.eval(pt),p.eval(ht),p.eval(mt),fe("\u51C6\u5907\u5C31\u7EEA",1),await new Promise(u=>{y("loading").classList.add("ready");let m=async()=>{y("start-btn").removeEventListener("click",m),v.audio.unlock(),v.audio.preloadSE(l.audio.filter(b=>b.startsWith("Audio/SE/")).map(b=>b.replace(/\.[^.]+$/,""))),Xe&&Rt(),y("loading").classList.remove("show"),u()};y("start-btn").addEventListener("click",m)}),document.addEventListener("visibilitychange",()=>{document.hidden?v.audio.pauseAll():v.audio.resumeAll()});try{await p.evalAsync(bt)}catch(u){v.onError(u&&u.message?u.message:String(u))}}jt().catch(l=>{console.error(l),y("load-text").textContent=`\u52A0\u8F7D\u5931\u8D25\uFF1A${l.message||l}`});})();
