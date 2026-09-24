//
//  sponsorblock.js
//  TubeShield - SponsorBlock Auto-Skip integration for iOS
//

(function() {
    'use strict';

    if (window.__tubeshield_sponsorblock_injected) return;
    window.__tubeshield_sponsorblock_injected = true;

    console.log("[TubeShield] SponsorBlock initialized.");

    let currentVideoId = null;
    let segments = [];
    let isFetching = false;
    let lastToastTime = 0;

    const CATEGORIES = JSON.stringify([
        "sponsor",
        "selfpromo",
        "interaction",
        "intro",
        "outro",
        "music_offtopic"
    ]);

    function getVideoId() {
        const urlParams = new URLSearchParams(window.location.search);
        let v = urlParams.get('v');
        if (v) return v;

        const pathSegments = window.location.pathname.split('/');
        const shortsIndex = pathSegments.indexOf('shorts');
        if (shortsIndex !== -1 && pathSegments[shortsIndex + 1]) {
            return pathSegments[shortsIndex + 1];
        }
        return null;
    }

    async function fetchSegments(videoId) {
        if (!videoId || isFetching) return;
        isFetching = true;
        segments = [];

        try {
            const endpoint = `https://sponsor.ajay.app/api/skipSegments?videoID=${videoId}&categories=${encodeURIComponent(CATEGORIES)}`;
            const response = await fetch(endpoint);
            if (response.ok) {
                const data = await response.json();
                segments = data.map(item => ({
                    start: item.segment[0],
                    end: item.segment[1],
                    category: item.category,
                    uuid: item.UUID
                }));
                console.log(`[TubeShield] Loaded ${segments.length} SponsorBlock segments for ${videoId}`);
            } else {
                segments = [];
            }
        } catch (e) {
            segments = [];
        } finally {
            isFetching = false;
        }
    }

    function showToast(text) {
        const now = Date.now();
        if (now - lastToastTime < 2500) return;
        lastToastTime = now;

        let toast = document.getElementById('tubeshield-sponsor-toast');
        if (!toast) {
            toast = document.createElement('div');
            toast.id = 'tubeshield-sponsor-toast';
            toast.style.cssText = `
                position: fixed;
                top: 55px;
                left: 50%;
                transform: translateX(-50%);
                background: rgba(15, 23, 42, 0.92);
                color: #38bdf8;
                border: 1px solid rgba(56, 189, 248, 0.3);
                padding: 7px 15px;
                border-radius: 20px;
                font-size: 13px;
                font-weight: 600;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                z-index: 9999999;
                pointer-events: none;
                backdrop-filter: blur(8px);
                -webkit-backdrop-filter: blur(8px);
                box-shadow: 0 4px 15px rgba(0,0,0,0.4);
                transition: opacity 0.3s ease, transform 0.3s ease;
                opacity: 0;
            `;
            document.body.appendChild(toast);
        }

        toast.textContent = text;
        toast.style.opacity = '1';
        toast.style.transform = 'translateX(-50%) translateY(0)';

        setTimeout(() => {
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(-50%) translateY(-10px)';
            }
        }, 2200);
    }

    function checkAndSkip(video) {
        if (!video || segments.length === 0) return;
        const currentTime = video.currentTime;

        for (const seg of segments) {
            if (currentTime >= seg.start && currentTime < (seg.end - 0.2)) {
                console.log(`[TubeShield] Skipping sponsor (${seg.category}): ${seg.start} -> ${seg.end}`);
                video.currentTime = seg.end;
                
                let categoryName = "Tài trợ";
                if (seg.category === "selfpromo") categoryName = "Tự quảng cáo";
                if (seg.category === "intro") categoryName = "Đoạn mở đầu";
                if (seg.category === "outro") categoryName = "Đoạn kết thúc";
                if (seg.category === "interaction") categoryName = "Kêu gọi tương tác";

                showToast(`⚡ Đã bỏ qua đoạn: ${categoryName}`);
                break;
            }
        }
    }

    // Monitor video and time
    setInterval(() => {
        const vId = getVideoId();
        if (vId && vId !== currentVideoId) {
            currentVideoId = vId;
            fetchSegments(currentVideoId);
        }

        const video = document.querySelector('video');
        if (video && !video.paused) {
            checkAndSkip(video);
        }
    }, 400);

})();
