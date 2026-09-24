//
//  background_play.js
//  TubeShield - Bulletproof Background Playback & Lock Screen Media Sync
//

(function() {
    'use strict';

    if (window.__tubeshield_background_injected) return;
    window.__tubeshield_background_injected = true;

    console.log("[TubeShield] Background playback script initializing...");

    let userIntentPaused = false;

    // 1. Intercept addEventListener to prevent YouTube from registering visibility/blur/pagehide pause listeners
    const originalAddEventListener = EventTarget.prototype.addEventListener;
    EventTarget.prototype.addEventListener = function(type, listener, options) {
        if (
            type === 'visibilitychange' ||
            type === 'webkitvisibilitychange' ||
            type === 'pagehide'
        ) {
            // Block YouTube from listening to backgrounding events
            return;
        }
        return originalAddEventListener.call(this, type, listener, options);
    };

    // 2. Spoof Visibility APIs (Always reported as visible & active)
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
        if (document.hasFocus) {
            document.hasFocus = () => true;
        }
    } catch (e) {
        console.warn("[TubeShield] Visibility defineProperty error:", e);
    }

    // 3. Track explicit user intent (Pause button tapped vs system backgrounding)
    document.addEventListener('click', (e) => {
        const target = e.target;
        if (!target) return;

        // Check if user tapped a pause button
        if (
            target.closest('.ytp-play-button') ||
            target.closest('button[aria-label*="Pause"]') ||
            target.closest('button[aria-label*="Tạm dừng"]') ||
            target.closest('.play-pause-button')
        ) {
            const video = document.querySelector('video');
            if (video && !video.paused) {
                userIntentPaused = true;
            } else {
                userIntentPaused = false;
            }
        } else if (
            target.closest('button[aria-label*="Play"]') ||
            target.closest('button[aria-label*="Phát"]')
        ) {
            userIntentPaused = false;
        }
    }, true);

    // 4. Intercept HTMLMediaElement.prototype.pause
    const originalPause = HTMLMediaElement.prototype.pause;
    HTMLMediaElement.prototype.pause = function() {
        // If pause was called automatically while user did NOT want to pause, prevent it
        if (!userIntentPaused) {
            console.log("[TubeShield] Intercepted and blocked involuntary pause.");
            return;
        }
        return originalPause.apply(this, arguments);
    };

    // 5. Video event listeners and auto-recovery
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
            if (!userIntentPaused) {
                // If paused by system or page switch, resume automatically!
                setTimeout(() => {
                    if (!userIntentPaused && video.paused) {
                        video.play().catch(() => {});
                    }
                }, 50);
            }
            sendNowPlayingInfo(video);
        });

        video.addEventListener('timeupdate', () => {
            if (Math.floor(video.currentTime) % 4 === 0) {
                sendNowPlayingInfo(video);
            }
        });

        video.addEventListener('ended', () => {
            sendNowPlayingInfo(video);
        });
    }

    // 6. Extract Metadata and Send to Lock Screen
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
            title: info.title || "YouTube Audio",
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

    // 7. Lock Screen Commands Handlers
    window.__tubeshield_play = function() {
        userIntentPaused = false;
        const video = document.querySelector('video');
        if (video) {
            video.play().catch(() => {});
        }
    };

    window.__tubeshield_pause = function() {
        userIntentPaused = true;
        const video = document.querySelector('video');
        if (video) {
            originalPause.apply(video);
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

    // Attach to existing or newly created video elements
    setInterval(() => {
        const video = document.querySelector('video');
        if (video) {
            attachVideoListeners(video);
            // If playing in background, ensure it stays unpaused
            if (!userIntentPaused && video.paused && !video.ended) {
                video.play().catch(() => {});
            }
        }
    }, 800);

    console.log("[TubeShield] Background playback script active.");
})();
