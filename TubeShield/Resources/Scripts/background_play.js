//
//  background_play.js
//  TubeShield - Background Playback & Lock Screen Media Sync
//

(function() {
    'use strict';

    if (window.__tubeshield_background_injected) return;
    window.__tubeshield_background_injected = true;

    console.log("[TubeShield] Background playback script initialized.");

    // 1. Trick YouTube into thinking the page is ALWAYS visible & focused
    try {
        Object.defineProperty(document, 'hidden', {
            get: function() { return false; },
            configurable: true
        });

        Object.defineProperty(document, 'visibilityState', {
            get: function() { return 'visible'; },
            configurable: true
        });

        Object.defineProperty(document, 'webkitVisibilityState', {
            get: function() { return 'visible'; },
            configurable: true
        });

        Object.defineProperty(document, 'webkitHidden', {
            get: function() { return false; },
            configurable: true
        });
    } catch (e) {
        console.warn("[TubeShield] Visibility defineProperty error:", e);
    }

    // 2. Intercept visibilitychange, blur and pagehide events
    const blockEvent = function(e) {
        e.stopImmediatePropagation();
    };

    window.addEventListener('visibilitychange', blockEvent, true);
    document.addEventListener('visibilitychange', blockEvent, true);
    window.addEventListener('pagehide', blockEvent, true);
    document.addEventListener('pagehide', blockEvent, true);

    // 3. Prevent YouTube from pausing when app is backgrounded
    let userIntentPaused = false;

    function attachVideoListeners(video) {
        if (!video || video.__tubeshield_hooked) return;
        video.__tubeshield_hooked = true;

        video.setAttribute('playsinline', '');
        video.setAttribute('webkit-playsinline', '');

        video.addEventListener('play', () => {
            userIntentPaused = false;
            sendNowPlayingInfo(video);
        });

        video.addEventListener('pause', () => {
            sendNowPlayingInfo(video);
        });

        video.addEventListener('timeupdate', () => {
            // Periodic sync (every 5 seconds)
            if (Math.floor(video.currentTime) % 5 === 0) {
                sendNowPlayingInfo(video);
            }
        });

        video.addEventListener('ended', () => {
            sendNowPlayingInfo(video);
        });
    }

    // 4. Extract Video Info & Send to Swift Native MPNowPlayingInfoCenter
    function extractVideoInfo() {
        let title = "";
        let artist = "";
        let artworkUrl = "";

        // Title selectors
        const titleEl = document.querySelector(
            '.slim-video-metadata-title, ' +
            'h1.title, ' +
            'ytm-slim-video-metadata-renderer .title, ' +
            '.video-details-title'
        );
        if (titleEl) {
            title = titleEl.textContent.trim();
        } else {
            title = document.title.replace(' - YouTube', '').trim();
        }

        // Channel / Artist selectors
        const artistEl = document.querySelector(
            'ytm-slim-owner-renderer .channel-name, ' +
            '.ytm-channel-thumbnail-with-profile-name, ' +
            '.owner-name, ' +
            '.slim-owner-channel-name'
        );
        if (artistEl) {
            artist = artistEl.textContent.trim();
        } else {
            artist = "YouTube";
        }

        // Artwork URL from video ID
        const urlParams = new URLSearchParams(window.location.search);
        const vId = urlParams.get('v');
        if (vId) {
            artworkUrl = `https://i.ytimg.com/vi/${vId}/hqdefault.jpg`;
        }

        return { title, artist, artworkUrl };
    }

    function sendNowPlayingInfo(video) {
        if (!video || !window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.tubeShieldMedia) {
            return;
        }

        const info = extractVideoInfo();
        const payload = {
            title: info.title || "YouTube Video",
            artist: info.artist || "YouTube",
            artworkUrl: info.artworkUrl,
            duration: isFinite(video.duration) ? video.duration : 0,
            currentTime: isFinite(video.currentTime) ? video.currentTime : 0,
            isPlaying: !video.paused
        };

        try {
            window.webkit.messageHandlers.tubeShieldMedia.postMessage(payload);
        } catch (e) {}
    }

    // 5. Remote command responder (invoked from Swift)
    window.__tubeshield_play = function() {
        const video = document.querySelector('video');
        if (video) {
            userIntentPaused = false;
            video.play();
        }
    };

    window.__tubeshield_pause = function() {
        const video = document.querySelector('video');
        if (video) {
            userIntentPaused = true;
            video.pause();
        }
    };

    window.__tubeshield_seek = function(seconds) {
        const video = document.querySelector('video');
        if (video && isFinite(seconds)) {
            video.currentTime = seconds;
        }
    };

    window.__tubeshield_skip = function(delta) {
        const video = document.querySelector('video');
        if (video && isFinite(video.currentTime)) {
            video.currentTime = Math.max(0, video.currentTime + delta);
        }
    };

    // Keep checking for video element
    setInterval(() => {
        const video = document.querySelector('video');
        if (video) {
            attachVideoListeners(video);
        }
    }, 1000);

})();
