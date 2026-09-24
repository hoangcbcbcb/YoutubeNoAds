//
//  background_play.js
//  TubeShield - Seamless Background Playback & Lock Screen Sync
//

(function() {
    'use strict';

    if (window.__tubeshield_background_injected) return;
    window.__tubeshield_background_injected = true;

    console.log("[TubeShield] Background playback script initialized.");

    // 1. Spoof Visibility APIs (Always visible to prevent tab suspension)
    try {
        Object.defineProperty(document, 'hidden', {
            get: () => false,
            configurable: true
        });
        Object.defineProperty(document, 'visibilityState', {
            get: () => 'visible',
            configurable: true
        });
        Object.defineProperty(document, 'webkitVisibilityState', {
            get: () => 'visible',
            configurable: true
        });
        Object.defineProperty(document, 'webkitHidden', {
            get: () => false,
            configurable: true
        });
    } catch (e) {
        console.warn("[TubeShield] Visibility defineProperty error:", e);
    }

    // 2. Intercept visibilitychange events so YouTube player does not get paused
    const stopPropagation = (e) => {
        e.stopImmediatePropagation();
    };
    window.addEventListener('visibilitychange', stopPropagation, true);
    document.addEventListener('visibilitychange', stopPropagation, true);
    window.addEventListener('webkitvisibilitychange', stopPropagation, true);
    document.addEventListener('webkitvisibilitychange', stopPropagation, true);

    // 3. Attach listeners to video element
    function attachVideoListeners(video) {
        if (!video || video.__tubeshield_hooked) return;
        video.__tubeshield_hooked = true;

        video.setAttribute('playsinline', '');
        video.setAttribute('webkit-playsinline', '');

        // Ensure video is not muted by default
        if (video.muted && !video.__tubeshield_user_muted) {
            video.muted = false;
        }

        video.addEventListener('play', () => {
            sendNowPlayingInfo(video);
        });

        video.addEventListener('pause', () => {
            sendNowPlayingInfo(video);
        });

        video.addEventListener('timeupdate', () => {
            if (Math.floor(video.currentTime) % 5 === 0) {
                sendNowPlayingInfo(video);
            }
        });

        video.addEventListener('ended', () => {
            sendNowPlayingInfo(video);
        });
    }

    // 4. Extract Video/Song Info for iOS Lock Screen & Control Center
    function extractVideoInfo() {
        let title = "";
        let artist = "";
        let artworkUrl = "";

        const titleEl = document.querySelector(
            '.slim-video-metadata-title, ' +
            'h1.title, ' +
            'ytm-slim-video-metadata-renderer .title, ' +
            'ytmusic-player-bar .title, ' +
            '.video-details-title'
        );
        if (titleEl) {
            title = titleEl.textContent.trim();
        } else {
            title = document.title.replace(' - YouTube', '').replace(' - YouTube Music', '').trim();
        }

        const artistEl = document.querySelector(
            'ytm-slim-owner-renderer .channel-name, ' +
            '.ytm-channel-thumbnail-with-profile-name, ' +
            'ytmusic-player-bar .byline, ' +
            '.owner-name, ' +
            '.slim-owner-channel-name'
        );
        if (artistEl) {
            artist = artistEl.textContent.trim();
        } else {
            artist = "YouTube";
        }

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
            title: info.title || "YouTube",
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

    // 5. Remote Lock Screen Handlers
    window.__tubeshield_play = function() {
        const video = document.querySelector('video');
        if (video) {
            video.play().catch(() => {});
        }
    };

    window.__tubeshield_pause = function() {
        const video = document.querySelector('video');
        if (video) {
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

    // Attach to video
    setInterval(() => {
        const video = document.querySelector('video');
        if (video) {
            attachVideoListeners(video);
        }
    }, 1000);

})();
