(()=>{"use strict";
const $=s=>document.querySelector(s),$$=s=>[...document.querySelectorAll(s)];
const get=(k,d)=>{try{return JSON.parse(localStorage.getItem("aw_"+k))??d}catch{return d}},set=(k,v)=>localStorage.setItem("aw_"+k,JSON.stringify(v));
const dbOpen=()=>new Promise((resolve,reject)=>{const q=indexedDB.open("AWWABPersonalMedia",1);q.onupgradeneeded=()=>{const db=q.result;if(!db.objectStoreNames.contains("assets"))db.createObjectStore("assets")};q.onsuccess=()=>resolve(q.result);q.onerror=()=>reject(q.error)});
const dbPut=async(k,v)=>{const db=await dbOpen();return new Promise((res,rej)=>{const tx=db.transaction("assets","readwrite");tx.objectStore("assets").put(v,k);tx.oncomplete=()=>res();tx.onerror=()=>rej(tx.error)})};
const dbGet=async k=>{const db=await dbOpen();return new Promise((res,rej)=>{const q=db.transaction("assets").objectStore("assets").get(k);q.onsuccess=()=>res(q.result);q.onerror=()=>rej(q.error)})};
const dbDel=async k=>{const db=await dbOpen();return new Promise((res,rej)=>{const tx=db.transaction("assets","readwrite");tx.objectStore("assets").delete(k);tx.oncomplete=()=>res();tx.onerror=()=>rej(tx.error)})};
function toast(s){if(typeof window.toast==="function")window.toast(s);else{const t=$("#toast");if(t){t.textContent=s;t.classList.add("show");setTimeout(()=>t.classList.remove("show"),2300)}}}
function addMoreSettings(){
 const anchor=$("#morePage .reminder-settings");if(!anchor||$("#personalizeGroup"))return;
 const wrap=document.createElement("section");wrap.id="personalizeGroup";wrap.innerHTML=`
 <div class="section-heading"><div><p class="eyebrow">تحكم كامل في تجربتك</p><h2>التخصيص والأدوات</h2></div></div>
 <div class="settings-group">
  <div class="setting-row"><span class="setting-icon">Aa</span><span><b>خط التطبيق</b><small>يتغير في كل التطبيق ما عدا المصحف</small></span></div>
  <div class="custom-font-row"><button class="soft-btn" id="appFontIOS">خط iPhone</button><button class="soft-btn" id="appFontAndroid">خط Android</button></div>
  <label class="upload-row">إضافة ملف خط من جهازك <input id="fontUpload" type="file" accept=".ttf,.otf,.woff,.woff2,font/ttf,font/otf,font/woff,font/woff2"></label>
  <div class="setting-row"><span class="setting-icon">۞</span><span><b>خط المصحف</b><small>إعداد مستقل عن خط التطبيق</small></span></div>
  <div class="custom-font-row"><button class="soft-btn" id="quranFontIOS">خط iPhone</button><button class="soft-btn" id="quranFontAndroid">خط Android</button></div>
  <p class="source-note">يمكنك تغيير خط التطبيق بملف خط تملكه أو لديك إذن باستخدامه. المصحف يحتفظ بخطه المستقل.</p>
 </div>
 <div class="section-heading"><div><p class="eyebrow">صوتك المفضل</p><h2>مكتبة الأذان</h2></div></div>
 <div class="settings-group audio-library">
  <p class="source-note">أضف تسجيلات الأذان التي تملكها من جهازك، وسمّ كل تسجيل باسم المؤذن. الملفات تحفظ على هذا الجهاز فقط.</p>
  <label class="upload-row">إضافة أذان من الجهاز <input id="adhanUpload" type="file" accept="audio/*" multiple></label>
  <div id="adhanTracks" class="adhan-tracks"><small>لم تضف تسجيلات بعد.</small></div>
  <audio id="adhanPlayer" controls preload="none"></audio>
 </div>
 <div class="section-heading"><div><p class="eyebrow">طريقتك في المراجعة</p><h2>مساعد الحفظ والتسميع</h2></div></div>
 <div class="settings-group feature-note">
  <p>اخفِ الآيات لتختبر حفظك، ثم اكشف كل آية عند الحاجة. هذه النسخة تقدم اختبار إخفاء وكشف دون ادعاء تصحيح التلاوة بالذكاء الاصطناعي؛ المساعد الصوتي الذكي المتقدم سيحتاج نموذجًا متخصصًا واختبارات دقة.</p>
  <button class="soft-btn full-btn" id="openMemorization">فتح المصحف ووضع اختبار الحفظ</button>
 </div>`;
 anchor.parentNode.insertBefore(wrap,anchor);
 $("#appFontIOS").onclick=()=>applyAppFont("ios");$("#appFontAndroid").onclick=()=>applyAppFont("android");
 $("#quranFontIOS").onclick=()=>applyQuranFont("ios");$("#quranFontAndroid").onclick=()=>applyQuranFont("android");
 $("#fontUpload").onchange=async e=>{const f=e.target.files?.[0];if(!f)return;if(f.size>8*1024*1024){toast("حجم الخط أكبر من 8 ميجابايت");return}try{await dbPut("app-font",{name:f.name,type:f.type||"font/ttf",blob:f});await applyUploadedFont();toast("تم تثبيت الخط على هذا الجهاز")}catch{toast("تعذر حفظ ملف الخط")}};
 $("#adhanUpload").onchange=async e=>{const files=[...(e.target.files||[])];for(const f of files){if(!f.type.startsWith("audio/"))continue;const id="adhan-"+Date.now()+"-"+Math.random().toString(36).slice(2);try{await dbPut(id,{name:f.name,blob:f,type:f.type});let list=get("adhan-list",[]);list.push({id,name:f.name});set("adhan-list",list)}catch{toast("تعذر حفظ أحد الملفات الصوتية")}}renderAdhanTracks();e.target.value=""};
 $("#openMemorization").onclick=()=>{document.querySelector('[data-page="quran"]')?.click();toast("افتح سورة ثم اختر وضع اختبار الحفظ")};
 renderAdhanTracks();
}
let appFontUrl=null,quranFontUrl=null;
async function applyUploadedFont(){const rec=await dbGet("app-font");if(!rec?.blob)return;try{if(appFontUrl)URL.revokeObjectURL(appFontUrl);appFontUrl=URL.createObjectURL(rec.blob);const face=new FontFace("AwwabUserFont",`url("${appFontUrl}")`);await face.load();document.fonts.add(face);document.documentElement.style.setProperty("--app-font",'"AwwabUserFont"');set("app-font-mode","upload")}catch{toast("ملف الخط غير مدعوم أو تالف")}}
function applyAppFont(mode){document.documentElement.style.setProperty("--app-font",mode==="ios"?' -apple-system,BlinkMacSystemFont,"SF Pro Text","Helvetica Neue",Arial,sans-serif':'Roboto,"Noto Sans Arabic",Arial,sans-serif');set("app-font-mode",mode);toast(mode==="ios"?"تم اختيار خط iPhone للتطبيق":"تم اختيار خط Android للتطبيق")}
function applyQuranFont(mode){document.documentElement.style.setProperty("--quran-font",mode==="ios"?' -apple-system,BlinkMacSystemFont,"SF Pro Text",serif':' "Noto Naskh Arabic","Noto Sans Arabic",serif');set("quran-font-mode",mode);toast(mode==="ios"?"تم تغيير خط المصحف إلى خط iPhone":"تم تغيير خط المصحف إلى خط Android")}
async function restoreFonts(){const af=get("app-font-mode","ios");if(af==="upload")await applyUploadedFont();else applyAppFont(af);applyQuranFont(get("quran-font-mode","android"))}
function renderAdhanTracks(){const box=$("#adhanTracks");if(!box)return;const tracks=get("adhan-list",[]);box.innerHTML=tracks.length?tracks.map((t,i)=>`<div class="adhan-track"><span>${i+1}. ${escapeHtml(t.name)}</span><button class="soft-btn" data-play-adhan="${t.id}">استماع</button><button class="soft-btn" data-delete-adhan="${t.id}">حذف</button></div>`).join(""):"<small>لم تضف تسجيلات بعد.</small>";$$("[data-play-adhan]").forEach(b=>b.onclick=async()=>{try{const a=await dbGet(b.dataset.playAdhan);if(!a?.blob)return toast("لم نعثر على الملف");const player=$("#adhanPlayer");if(player.dataset.objectUrl)URL.revokeObjectURL(player.dataset.objectUrl);const url=URL.createObjectURL(a.blob);player.dataset.objectUrl=url;player.src=url;await player.play()}catch{toast("تعذر تشغيل التسجيل")}});$$("[data-delete-adhan]").forEach(b=>b.onclick=async()=>{await dbDel(b.dataset.deleteAdhan);set("adhan-list",tracks.filter(t=>t.id!==b.dataset.deleteAdhan));renderAdhanTracks();toast("تم حذف التسجيل")})}
function escapeHtml(s){return String(s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}
function setupRecall(){
 const reader=$("#reader"),ayahs=$("#ayahs");if(!reader||!ayahs||$("#recallToolbar"))return;
 const toolbar=document.createElement("div");toolbar.id="recallToolbar";toolbar.className="recall-toolbar";toolbar.innerHTML='<button class="soft-btn" id="toggleRecall">اختبر حفظك: إخفاء الآيات</button><button class="soft-btn" id="revealRecall">إظهار الكل</button><small>اضغط على الآية المخفية لكشفها منفردة</small>';
 ayahs.parentNode.insertBefore(toolbar,ayahs);
 let hidden=false;
 const setHidden=v=>{hidden=v;$$(".ayah").forEach(a=>a.classList.toggle("recall-hidden",hidden));$("#toggleRecall").textContent=hidden?"إظهار الآيات":"اختبر حفظك: إخفاء الآيات"};
 $("#toggleRecall").onclick=()=>setHidden(!hidden);$("#revealRecall").onclick=()=>setHidden(false);
 const observer=new MutationObserver(()=>{if(hidden)setHidden(true);$$(".ayah").forEach(a=>{if(a.dataset.recallBound)return;a.dataset.recallBound="1";a.tabIndex=0;a.title="اضغط لكشف الآية";a.addEventListener("click",()=>{if(a.classList.contains("recall-hidden"))a.classList.remove("recall-hidden")})})});
 observer.observe(ayahs,{childList:true,subtree:true});
}
function setup(){addMoreSettings();restoreFonts();setupRecall();const themeOptions=$("#morePage .theme-options");if(themeOptions&&!themeOptions.querySelector('[data-theme="glass"]')){const b=document.createElement("button");b.className="theme-option";b.dataset.theme="glass";b.innerHTML="<i></i><span>زجاجي فاتح</span>";themeOptions.appendChild(b);b.onclick=()=>{if(typeof window.applyTheme==="function")window.applyTheme("glass");else{document.body.dataset.theme="glass";set("theme","glass");$$(".theme-option").forEach(x=>x.classList.toggle("selected",x===b))}}}
}
if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",setup);else setup();
})();