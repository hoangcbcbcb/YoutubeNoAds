//
//  audio_only.js
//  TubeShield - Audio-Only Mode & YouTube Music UI Integration
//

(function() {
    'use strict';

    if (window.__tubeshield_audio_only_injected) return;
    window.__tubeshield_audio_only_injected = true;

    console.log("[TubeShield] Audio-Only & Music script initialized.");

    let audioOnlyActive = false;

    // 1. YouTube Music Premium Popup Dismissal
    function dismissMusicPopups() {
        if (!window.location.hostname.includes('music.youtube.com')) return;

        // Dismiss "Get Music Premium" dialogs
        const dismissButtons = document.querySelectorAll(
            'ytmusic-mealbar-promo-renderer #dismiss-button, ' +
            'ytmusic-upsell-dialog-renderer #dismiss-button, ' +
            'paper-dialog .actions yt-button-renderer[dialog-dismiss], ' +
            'yt-button-renderer.ytmusic-mealbar-promo-renderer'
        );
        dismissButtons.forEach(btn => {
            try { btn.click(); } catch(e) {}
        });

        // Suppress popup containers
        const popups = document.querySelectorAll(
            'ytmusic-mealbar-promo-renderer, ' +
            'ytmusic-upsell-dialog-renderer'
        );
        popups.forEach(el => {
            el.style.display = 'none';
        });
    }

    // 2. Audio-Only Mode Styling & Visual Cover
    const audioStyleId = 'tubeshield-audio-only-style';
    const visualizerId = 'tubeshield-music-visualizer';

    function enableAudioOnly() {
        if (audioOnlyActive) return;
        audioOnlyActive = true;

        // Add CSS to hide raw video and display music banner
        if (!document.getElementById(audioStyleId)) {
            const style = document.createElement('style');
            style.id = audioStyleId;
            style.textContent = `
                /* In audio-only mode, hide video rendering to save GPU/Battery */
                #movie_player video,
                .html5-main-video {
                    opacity: 0 !important;
                }
                
                #tubeshield-music-visualizer {
                    position: absolute;
                    inset: 0;
                    background: radial-gradient(circle at center, #1e1b4b 0%, #0f172a 100%);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    z-index: 10;
                    pointer-events: none;
                }
                
                .ts-eq-container {
                    display: flex;
                    align-items: flex-end;
                    height: 40px;
                    gap: 4px;
                    margin-top: 15px;
                }
                
                .ts-eq-bar {
                    width: 5px;
                    background: #38bdf8;
                    border-radius: 3px;
                    animation: ts-bounce 1s ease-in-out infinite alternate;
                }
                
                .ts-eq-bar:nth-child(1) { height: 18px; animation-delay: 0.1s; }
                .ts-eq-bar:nth-child(2) { height: 35px; animation-delay: 0.3s; }
                .ts-eq-bar:nth-child(3) { height: 24px; animation-delay: 0.5s; }
                .ts-eq-bar:nth-child(4) { height: 38px; animation-delay: 0.2s; }
                .ts-eq-bar:nth-child(5) { height: 20px; animation-delay: 0.4s; }

                @keyframes ts-bounce {
                    0% { transform: scaleY(0.3); opacity: 0.5; }
                    100% { transform: scaleY(1.0); opacity: 1; }
                }

                .ts-music-badge {
                    background: rgba(56, 189, 248, 0.2);
                    border: 1px solid rgba(56, 189, 248, 0.4);
                    color: #38bdf8;
                    font-size: 11px;
                    font-weight: 700;
                    letter-spacing: 0.8px;
                    padding: 4px 10px;
                    border-radius: 12px;
                    margin-bottom: 8px;
                }
            `;
            (document.head || document.documentElement).appendChild(style);
        }

        injectVisualizer();
        forceLowestVideoQuality();
    }

    function disableAudioOnly() {
        audioOnlyActive = false;
        const style = document.getElementById(audioStyleId);
        if (style) style.remove();

        const viz = document.getElementById(visualizerId);
        if (viz) viz.remove();
    }

    function injectVisualizer() {
        const playerContainer = document.querySelector('#movie_player, .html5-video-player, #player-container-id');
        if (!playerContainer || document.getElementById(visualizerId)) return;

        const viz = document.createElement('div');
        viz.id = visualizerId;
        viz.innerHTML = `
            <div class="ts-music-badge">🎵 AUDIO ONLY (TIẾT KIỆM PIN & 4G)</div>
            <div class="ts-eq-container">
                <div class="ts-eq-bar"></div>
                <div class="ts-eq-bar"></div>
                <div class="ts-eq-bar"></div>
                <div class="ts-eq-bar"></div>
                <div class="ts-eq-bar"></div>
            </div>
        `;
        playerContainer.appendChild(viz);
    }

    // Force 144p to save up to 90% bandwidth and battery in Audio-Only mode
    function forceLowestVideoQuality() {
        try {
            const player = document.getElementById('movie_player');
            if (player && typeof player.setPlaybackQualityRange === 'function') {
                player.setPlaybackQualityRange('tiny', 'tiny');
            }
            if (player && typeof player.setPlaybackQuality === 'function') {
                player.setPlaybackQuality('tiny');
            }
        } catch (e) {}
    }

    // Window command functions (invoked from Swift)
    window.__tubeshield_setAudioOnly = function(enabled) {
        if (enabled) {
            enableAudioOnly();
        } else {
            disableAudioOnly();
        }
    };

    // Periodic loop
    setInterval(() => {
        dismissMusicPopups();
        if (audioOnlyActive) {
            injectVisualizer();
            forceLowestVideoQuality();
        }
    }, 1200);

})();
