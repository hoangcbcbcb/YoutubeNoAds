//
//  adblock.js
//  TubeShield - Ultra Fast YouTube Ad Blocker & Skipper for iOS
//

(function() {
    'use strict';

    if (window.__tubeshield_adblock_injected) return;
    window.__tubeshield_adblock_injected = true;

    console.log("[TubeShield] AdBlock script initialized.");

    // 1. Inject CSS to hide all YouTube banner, companion, and feed ads
    const cssRules = `
        /* Hide all ad containers and sponsored elements */
        .ad-showing .ytp-ad-player-overlay,
        .ytp-ad-module,
        .ytp-ad-overlay-container,
        .ytp-ad-message-container,
        .ytp-ad-survey,
        .video-ads,
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
        .mealbar-promo-renderer {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            width: 0 !important;
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

    let lastSkippedTime = 0;

    function handleVideoAds() {
        const player = document.querySelector('#movie_player, .html5-video-player, ytm-player');
        const video = document.querySelector('video');

        // Check if an ad is currently playing
        const isAdShowing = player && (
            player.classList.contains('ad-showing') ||
            player.classList.contains('ad-interrupting') ||
            document.querySelector('.ytp-ad-player-overlay, .ytp-ad-module, .ytp-ad-text') !== null
        );

        if (video && isAdShowing) {
            // Instant fast forward and mute to skip ad seamlessly
            try {
                video.muted = true;
                video.playbackRate = 16.0;
                if (!isNaN(video.duration) && isFinite(video.duration) && video.duration > 0) {
                    video.currentTime = video.duration;
                }
            } catch (e) {}

            // Click any available skip button
            for (const selector of skipButtonSelectors) {
                const buttons = document.querySelectorAll(selector);
                buttons.forEach(btn => {
                    try {
                        btn.click();
                        lastSkippedTime = Date.now();
                    } catch (e) {}
                });
            }
        } else if (video && !isAdShowing && (Date.now() - lastSkippedTime < 1000)) {
            // Restore playback rate after ad skipped
            try {
                if (video.playbackRate > 2.0) {
                    video.playbackRate = 1.0;
                }
            } catch (e) {}
        }

        // Remove overlay / popup ads
        const overlays = document.querySelectorAll('.ytp-ad-overlay-container, .ytp-ad-message-container');
        overlays.forEach(el => {
            el.remove();
        });
    }

    // 3. Run ad checker loop
    setInterval(handleVideoAds, 100);

    // 4. Observer for dynamic DOM insertions
    const observer = new MutationObserver(() => {
        injectStyles();
        handleVideoAds();
    });

    observer.observe(document.documentElement, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['class', 'src']
    });

    console.log("[TubeShield] AdBlock active.");
})();
