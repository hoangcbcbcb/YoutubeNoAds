//
//  pip_controller.js
//  TubeShield - Picture-in-Picture (PiP) Controller for iOS
//

(function() {
    'use strict';

    if (window.__tubeshield_pip_injected) return;
    window.__tubeshield_pip_injected = true;

    console.log("[TubeShield] PiP Controller initialized.");

    function setupVideoPiP(video) {
        if (!video) return;
        video.setAttribute('playsinline', '');
        video.setAttribute('webkit-playsinline', '');
        
        // Ensure webkitPresentationMode is accessible
        if (typeof video.webkitSetPresentationMode === 'function') {
            // Native WebKit PiP supported
        }
    }

    window.__tubeshield_triggerPiP = function() {
        const video = document.querySelector('video');
        if (!video) {
            console.warn("[TubeShield] No video element found for PiP.");
            return false;
        }

        if (typeof video.webkitSetPresentationMode === 'function') {
            const currentMode = video.webkitPresentationMode;
            if (currentMode === 'picture-in-picture') {
                video.webkitSetPresentationMode('inline');
            } else {
                video.webkitSetPresentationMode('picture-in-picture');
            }
            return true;
        } else if (document.pictureInPictureEnabled && typeof video.requestPictureInPicture === 'function') {
            video.requestPictureInPicture().catch(e => {
                console.warn("[TubeShield] PiP request failed:", e);
            });
            return true;
        }
        return false;
    };

    // Auto-setup for any new video element
    setInterval(() => {
        const video = document.querySelector('video');
        if (video && !video.__tubeshield_pip_ready) {
            video.__tubeshield_pip_ready = true;
            setupVideoPiP(video);
        }
    }, 1000);

})();
