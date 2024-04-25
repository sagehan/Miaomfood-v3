import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/dist/ScrollTrigger";
import { map } from 'nanostores';
import Lenis from './lib/lenis.js';
import './lib/htmx.js';

(async () => {
  if ('serviceWorker' in navigator) {
    try {
      const registration = await navigator.serviceWorker.register('/assets/service-worker.js');
      if (registration.installing) {
        console.log('Service worker installing');
      } else if (registration.waiting) {
        console.log('Service worker installed');
      } else if (registration.active) {
        console.log('Service worker active');
      }
    } catch (error) {
      console.error(`Service worker registration failed with ${error}`);
    }
  }
})();

/** @typedef {import('@studio-freight/lenis/types').default} Lenis */
/** @typedef {import('nanostores').MapStore} MapStore */

/** @type {MapStore<Lenis>} */
const $lenis = map(Object.create(null));

const lenisInstance = new Lenis({
  infinite: true
});
$lenis.set(lenisInstance);

// $lenis.subscribe(lenis => {
//   lenis.on('scroll', ScrollTrigger.update)
// })
