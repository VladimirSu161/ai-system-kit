/* ══════════════════════════════════════════════════════════════
   HyperFrames · Dark Amber — единый источник JS-хелперов.
   Подключение из композиции (index.html в корне проекта):
     script src = shared/helpers.js   ← ПОСЛЕ gsap (см. templates/new-video.html)
   В скрипте композиции:
     const tl = gsap.timeline({ paused: true });
     const { fadeIn, fadeOut, slideUp, pop, counter, fillBar,
             drawPath, typewriter, scramble, mulberry32,
             kill, crossfade, push, zoomPunch, wipe, wipeUp,
             buildCaptions, setState, setTag, shake } = createHFHelpers(tl);
   Канон имён и сигнатур — _reference-video64.html (видео 64).
   Детерминизм: никаких Math.random()/Date.now() — только mulberry32.
   ══════════════════════════════════════════════════════════════ */

window.createHFHelpers = function (tl) {

  /* ── Entrance ── */
  const fadeIn  = (id, at, dur)   => tl.fromTo(id, {opacity:0}, {opacity:1, duration:dur||0.35, ease:"power2.out"}, at);
  const fadeOut = (id, at, dur)   => tl.to(id, {opacity:0, duration:dur||0.22, ease:"power1.in"}, at);
  const slideUp = (id, at, delay) => tl.fromTo(id, {opacity:0,y:32}, {opacity:1,y:0, duration:0.45, ease:"power3.out"}, at+(delay||0));
  const pop     = (id, at, delay) => tl.fromTo(id, {opacity:0,scale:0.7}, {opacity:1,scale:1, duration:0.5, ease:"back.out(1.6)"}, at+(delay||0));

  /* ── Непрерывное движение ── */
  const counter = (id, from, to, dur, at, suffix) => {
    const el = document.querySelector(id);
    const o = {n: from};
    tl.to(o, {
      n: to, duration: dur, ease:"power2.out",
      onUpdate: () => el.textContent = Math.round(o.n).toLocaleString("ru-RU").replace(/,/g," ") + (suffix||"")
    }, at);
  };

  const fillBar = (id, at, dur, toScale) =>
    tl.to(id, {scaleX: toScale==null?1:toScale, duration:dur, ease:"power2.out"}, at);

  const drawPath = (id, at, dur) => {
    const p = document.querySelector(id);
    const len = p.getTotalLength();
    p.style.strokeDasharray = len;
    p.style.strokeDashoffset = len;
    tl.to(p, {strokeDashoffset:0, duration:dur, ease:"power2.inOut"}, at);
  };

  const typewriter = (id, text, at, dur) => {
    const el = document.querySelector(id);
    const o = {i:0};
    tl.to(o, {
      i: text.length, duration:dur, ease:"none",
      onUpdate: () => el.textContent = text.slice(0, Math.round(o.i))
    }, at);
  };

  /* ── Статусный язык цвета (паттерн N «живой холст») ──
     Состояние системы = цвет: ok/warn/fail/idle. CSS-классы box-… и st-…
     задают стартовое состояние, эти хелперы анимируют переходы. */
  const STATES = {
    ok:   { line:"#3DD68C",                tint:"rgba(61,214,140,0.06)", glow:"0 0 32px rgba(61,214,140,0.18)" },
    warn: { line:"#F5B544",                tint:"rgba(245,181,68,0.07)", glow:"0 0 32px rgba(245,181,68,0.18)" },
    fail: { line:"#FF5C5C",                tint:"rgba(255,92,92,0.10)",  glow:"0 0 36px rgba(255,92,92,0.28)"  },
    idle: { line:"rgba(255,255,255,0.08)", tint:"rgba(255,255,255,0.03)", glow:"0 0 0 rgba(0,0,0,0)"           },
  };
  /* контейнер (карточка сервера): рамка + заливка + glow */
  const setState = (id, state, at, dur) => {
    const s = STATES[state];
    tl.to(id, { borderColor:s.line, backgroundColor:s.tint, boxShadow:s.glow,
                duration:dur||0.35, ease:"power2.out" }, at);
  };
  /* статус-надпись (RUNNING → FAILED): цвет + опционально текст */
  const setTag = (id, state, at, text) => {
    if (text != null) tl.call(() => { document.querySelector(id).textContent = text; }, [], at);
    tl.to(id, { color: STATES[state].line, duration:0.2, ease:"none" }, at);
  };
  /* дрожание при ошибке (объект «стучится» и не влезает) */
  const shake = (id, at, mag) => {
    const m = mag || 12;
    tl.fromTo(id, {x:0}, {x:-m, duration:0.05, ease:"none", immediateRender:false}, at);
    tl.to(id, {x:m, duration:0.09, repeat:4, yoyo:true, ease:"none"}, at+0.05);
    tl.to(id, {x:0, duration:0.06, ease:"power1.out"}, at+0.5);
  };

  /* ── Детерминированный ГПСЧ (вместо Math.random) ── */
  function mulberry32(s){return function(){s|=0;s=(s+0x6D2B79F5)|0;let t=Math.imul(s^(s>>>15),1|s);t=(t+Math.imul(t^(t>>>7),61|t))^t;return((t^(t>>>14))>>>0)/4294967296;};}

  /* ── scramble: текст «расшифровывается» из случайных символов ──
     Вешать на ОДНО акцентное слово, не на всю строку. 1 раз за ролик. */
  const scramble = (id, finalText, at, dur) => {
    const el = document.querySelector(id);
    const CHARSET = "АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ0123456789#@%&";
    const LEN = finalText.length, FRAMES = 60;
    const rng = mulberry32(7), matrix = [];
    for (let f=0; f<FRAMES; f++){ const row=[]; for(let i=0;i<LEN;i++) row.push(CHARSET[Math.floor(rng()*CHARSET.length)]); matrix.push(row); }
    const o = {p:0};
    tl.to(o, {p:1, duration:dur, ease:"none", onUpdate:function(){
      const p=o.p, fi=Math.min(FRAMES-1, Math.floor(p*FRAMES));
      let r="";
      for(let i=0;i<LEN;i++){ const th=(i/LEN)*0.7; r += (p>=th+0.3) ? finalText[i] : (finalText[i]===" "?" ":matrix[fi][i]); }
      el.textContent = r;
    }}, at);
    tl.call(()=>{ el.textContent = finalText; }, [], at+dur);
  };

  /* ════ ПАЛИТРА ПЕРЕХОДОВ (окна сцен перекрывать на D!) ════
     crossfade — продолжение мысли · push — следующий шаг ·
     zoomPunch — акцент/число · wipe — контраст · wipeUp — к выводу.
     kill: hard-reset transform + hidden — без него уехавшая сцена
     ловится инспектором как overflow. Все fromTo — immediateRender:false. */
  const kill = (outId, at) =>
    tl.set(outId, {visibility:"hidden", opacity:0, xPercent:0, scale:1, y:0, clipPath:"none"}, at);

  const crossfade = (outId, inId, outAt, D) => {
    D = D || 0.5;
    tl.to(outId, {opacity:0, scale:1.08, duration:D, ease:"power2.in"}, outAt);
    tl.fromTo(inId, {opacity:0, scale:0.94}, {opacity:1, scale:1, duration:D, ease:"power2.out", immediateRender:false}, outAt);
    kill(outId, outAt + D);
  };
  const push = (outId, inId, outAt, D) => {
    D = D || 0.55;
    tl.to(outId, {xPercent:-100, opacity:0.3, duration:D, ease:"power2.inOut"}, outAt);
    tl.fromTo(inId, {xPercent:100, opacity:0.6}, {xPercent:0, opacity:1, duration:D, ease:"power2.inOut", immediateRender:false}, outAt);
    kill(outId, outAt + D);
  };
  const zoomPunch = (outId, inId, outAt, D) => {
    D = D || 0.5;
    tl.to(outId, {scale:1.25, opacity:0, duration:D, ease:"power2.in"}, outAt);
    tl.fromTo(inId, {scale:0.55, opacity:0}, {scale:1, opacity:1, duration:D, ease:"back.out(1.4)", immediateRender:false}, outAt);
    kill(outId, outAt + D);
  };
  const wipe = (outId, inId, outAt, D) => {
    D = D || 0.6;
    tl.to(outId, {opacity:0, duration:D, ease:"power1.in"}, outAt + D*0.4);
    tl.fromTo(inId, {clipPath:"inset(0 0 0 100%)"}, {clipPath:"inset(0 0 0 0%)", duration:D, ease:"power3.inOut", immediateRender:false}, outAt);
    kill(outId, outAt + D);
  };
  const wipeUp = (outId, inId, outAt, D) => {
    D = D || 0.6;
    tl.to(outId, {opacity:0, y:-40, duration:D, ease:"power1.in"}, outAt + D*0.35);
    tl.fromTo(inId, {clipPath:"inset(100% 0 0 0)"}, {clipPath:"inset(0% 0 0 0)", duration:D, ease:"power3.inOut", immediateRender:false}, outAt);
    kill(outId, outAt + D);
  };

  /* ── poseSwap: смена позы персонажа (тема sticker-light) ──
     Чистый opacity-кроссфейд БЕЗ масштаба (crossfade() зумит — для
     персонажа не годится). Позы — <img class="pose"> в .char-zone. */
  const poseSwap = (outId, inId, at, D) => {
    D = D || 0.25;
    tl.to(outId, {opacity:0, duration:D, ease:"power1.inOut"}, at);
    tl.fromTo(inId, {opacity:0}, {opacity:1, duration:D, ease:"power1.inOut", immediateRender:false}, at);
  };

  /* ── breathe: медленное «дыхание» — непрерывный лёгкий float.
     Для персонажа sticker-light (на весь ролик) и долгих карточек (>5с):
     статичный элемент между entrance-анимациями выглядит стоп-кадром.
     dur — сколько секунд дышать (обычно длительность ролика/блока).
     repeat конечный — repeat:-1 запрещён движком (Key Rules §7). */
  const breathe = (id, at, dur, amp, cycle) => {
    amp = amp || 6; cycle = cycle || 2.4;
    const half = cycle / 2;
    tl.to(id, { y: "-=" + amp, duration: half, ease: "sine.inOut",
                yoyo: true, repeat: Math.max(1, Math.ceil(dur / half) - 1) }, at);
  };

  /* ── wobble: микро-покачивание стикера (±deg) пока он на экране.
     Даёт die-cut стикерам «наклеенность» вместо неподвижного PNG. */
  const wobble = (id, at, dur, deg, cycle) => {
    deg = deg || 2.2; cycle = cycle || 1.6;
    const half = cycle / 2;
    tl.fromTo(id, { rotation: -deg },
              { rotation: deg, duration: half, ease: "sine.inOut",
                yoyo: true, repeat: Math.max(1, Math.ceil(dur / half) - 1),
                immediateRender: false }, at);
  };

  /* ════ КАРАОКЕ-СУБТИТРЫ ════
     CAP — массив слов [{text,start,end}, …] с ВЫВЕРЕННЫМ текстом
     (ошибки Whisper исправлены руками, тайминги сохранены).
     Файл со словами генерирует scripts/captions-from-transcript.mjs.
     Требуется <div id="cap-band" class="clip" data-start data-duration
     data-track-index> в композиции; стили — в shared/dark-amber.css. */
  const buildCaptions = (CAP, opts) => {
    opts = opts || {};
    const band = document.getElementById(opts.bandId || "cap-band");
    const MAXW = opts.maxWords || 3,
          MAXCHARS = opts.maxChars || 20,
          PAUSE = opts.pause || 0.3,
          BUF = opts.buffer || 0.35;
    const ACTIVE = opts.activeColor || "#F5B544";
    const IDLE = opts.idleColor || "#8A8A8A";
    const GLOW = opts.glow || "0 0 22px rgba(245,181,68,0.55)";
    /* выделения слов (тема sticker-light): в CAP у слова опционально
       hl:"mark" (жёлтый маркер) или hl:"red" (красное) — see reference */
    const MARKBG = opts.markBg || "#FFE14D";
    const MARKFG = opts.markColor || "#141414";
    const REDFG  = opts.redColor || "#E5484D";
    const groups = [];
    let cur = [], curChars = 0;
    for (let i=0; i<CAP.length; i++){
      const w = CAP[i];
      if (cur.length && (cur.length >= MAXW || curChars + w.text.length > MAXCHARS)){
        groups.push({words:cur.slice(), start:cur[0].start, end:cur[cur.length-1].end});
        cur = []; curChars = 0;
      }
      cur.push(w); curChars += w.text.length + 1;
      const nx = CAP[i+1];
      const punct = /[,.!?:]$/.test(w.text);
      const pause = nx ? (nx.start - w.end) : 999;
      if (!nx || punct || pause >= PAUSE){
        groups.push({words:cur.slice(), start:cur[0].start, end:cur[cur.length-1].end});
        cur = []; curChars = 0;
      }
    }
    groups.forEach((g, gi) => {
      const el = document.createElement("div");
      el.className = "cap-group"; el.id = "cg"+gi;
      g.words.forEach((w, wi) => {
        const s = document.createElement("span");
        s.className = "cap-word"; s.id = "cw"+gi+"_"+wi;
        s.textContent = w.text;
        el.appendChild(s);
      });
      band.appendChild(el);
      const next = groups[gi+1];
      const visStart = g.start;
      const visEnd = next ? Math.min(next.start, g.end + BUF) : g.end + BUF;
      tl.set(el, {opacity:1}, visStart);
      tl.set(el, {opacity:0}, visEnd);
      g.words.forEach((w, wi) => {
        const sel = "#cw"+gi+"_"+wi;
        tl.set(sel, {color:IDLE, textShadow:"none", backgroundColor:"rgba(255,255,255,0)"}, visStart);
        let hit = {color:ACTIVE, textShadow:GLOW, duration:0.08, ease:"none"};
        if (w.hl === "mark")     hit = {color:MARKFG, backgroundColor:MARKBG, duration:0.08, ease:"none"};
        else if (w.hl === "red") hit = {color:REDFG, duration:0.08, ease:"none"};
        tl.to(sel, hit, Math.max(visStart, w.start));
      });
    });
  };

  return { fadeIn, fadeOut, slideUp, pop, counter, fillBar, drawPath,
           typewriter, scramble, mulberry32, kill,
           crossfade, push, zoomPunch, wipe, wipeUp, buildCaptions,
           setState, setTag, shake, poseSwap, breathe, wobble };
};
