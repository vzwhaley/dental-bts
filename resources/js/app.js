import { createApp } from 'vue';
import ComingSoon from './components/ComingSoon.vue';

const mount = document.getElementById('coming-soon');
if (mount) {
    createApp(ComingSoon, { ...mount.dataset }).mount(mount);
}
