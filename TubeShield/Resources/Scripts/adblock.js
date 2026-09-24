//
//  adblock.js
//  TubeShield - Safe & Fast YouTube Ad Blocker (No False Skips)
//

(function() {
    'use strict';

    if (window.__tubeshield_adblock_injected) return;
    window.__tubeshield_adblock_injected = true;

    console.log("[TubeShield] AdBlock script initialized.");

    // 1. Inject CSS to hide all banner, promo, and companion ads
    const cssRules = `
        /* Hide all ad containers and sponsored elements */
        .ad-showing .ytp-ad-player-overlay,
        .ytp-ad-overlay-container,
        .ytp-ad-message-container,
        .ytp-ad-survey,
        ytm-promoted-sparkles-web-renderer,
        ytd-promoted-sparkles-web-renderer,
        ytm-promoted-video-renderer,
        ytd-promoted-video-renderer,
        ytm-companion-ad-renderer,
        ytd-companion-slot-renderer,
        ytm-statement-banner-renderer,
        ytd-in-feed-ad-layout-renderer,
        ytd-banner-promo-renderer-background,
        ytd-ad-slot-renderer,
        ytm-ad-slot-renderer,
        .ytd-search-pyv-renderer,
        #masthead-ad,
        .ad-container,
        .sparkles-light-cta,
        ytm-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"],
        ytm-item-section-renderer[data-type="ad"],
        ytm-pivot-bar-item-renderer[aria-label*="Sponsor"],
        ytmusic-mealbar-promo-renderer,
        .mealbar-promo-renderer {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            pointer-events: none !important;
            opacity: 0 !important;
        }
    `;

    function injectStyles() {
        if (document.getElementById('tubeshield-adblock-style')) return;
        const style = document.createElement('style');
        style.id = 'tubeshield-adblock-style';
        style.type = 'text/css';
        style.textContent = cssRules;
        (document.head || document.documentElement).appendChild(style);
    }
    injectStyles();

    // 2. Video Ad Fast-Forward & Skip Logic
    const skipButtonSelectors = [
        '.ytp-ad-skip-button',
        '.ytp-ad-skip-button-modern',
        '.ytp-skip-ad-button',
        '.videoAdUiSkipButton',
        'button.ytp-ad-skip-button-text',
        'button[id*="skip"]',
        'button.ytp-ad-skip-button-modern.ytp-button',
        '.ytp-ad-overlay-close-button',
        'button[aria-label="Close ad"]',
        'button[aria-label*="Skip"]',
        'button[aria-label*="Bỏ qua"]',
        '.ytp-ad-skip-ad-button'
    ];

    function handleVideoAds() {
        const player = document.querySelector('#movie_player, .html5-video-player, ytm-player');
        const video = document.querySelector('video');
        if (!video) return;

        // CRITICAL FIX: Only treat as ad if the player explicitly has ad-showing or ad-interrupting classes.
        // DO NOT check .ytp-ad-module because it is an empty container present in EVERY video!
        const isAdShowing = player && (
            player.classList.contains('ad-showing') ||
            player.classList.contains('ad-interrupting')
        );

        if (isAdShowing) {
            // SAFETY CHECK: Ads are rarely longer than 120 seconds. If video duration is > 120s, it is a real song!
            const duration = video.duration;
            const isSafeToSkip = !isNaN(duration) && isFinite(duration) && duration > 0 && duration <= 120;

            if (isSafeToSkip) {
                try {
                    video.playbackRate = 16.0;
                    video.currentTime = duration;
                } catch (e) {}
            }

            // Click any available skip button immediately
            for (const selector of skipButtonSelectors) {
                const buttons = document.querySelectorAll(selector);
                buttons.forEach(btn => {
                    try { btn.click(); } catch (e) {}
                });
            }
        } else {
            // Normal video playback: Ensure audio is not muted and playback rate is normal
            if (video.playbackRate > 2.0) {
                video.playbackRate = 1.0;
            }
            if (video.muted && !video.__tubeshield_user_muted) {
                video.muted = false;
            }
        }

        // Remove overlay / popup ad boxes
        const overlays = document.querySelectorAll('.ytp-ad-overlay-container, .ytp-ad-message-container');
        overlays.forEach(el => el.remove());
    }

    // Run checker
    setInterval(handleVideoAds, 300);

    const observer = new MutationObserver(() => {
        injectStyles();
        handleVideoAds();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true
    });

    console.log("[TubeShield] Safe AdBlock active.");
})();
