<script setup>
const props = defineProps({
    title: { type: String, default: 'Dental Billing and Training Solutions' },
    tagline: { type: String, default: 'Coming Soon' },
});

const year = new Date().getFullYear();
</script>

<template>
    <main
        class="relative flex min-h-screen flex-col items-center justify-center overflow-hidden bg-gradient-to-b from-slate-50 to-sky-100 px-6 py-16 text-center text-slate-800"
    >
        <!-- Soft decorative glow -->
        <div
            class="pointer-events-none absolute -top-40 left-1/2 h-96 w-96 -translate-x-1/2 rounded-full bg-teal-200/40 blur-3xl"
            aria-hidden="true"
        ></div>

        <div class="relative z-10 flex max-w-2xl flex-col items-center">
            <!-- Tooth mark -->
            <div
                class="mb-8 flex h-16 w-16 items-center justify-center rounded-2xl bg-white shadow-lg shadow-sky-900/5 ring-1 ring-slate-900/5"
            >
                <svg
                    class="h-9 w-9 text-teal-600"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.6"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    aria-hidden="true"
                >
                    <path
                        d="M12 5.5c-1.6-1.4-3.4-2-5-1.4C5 4.9 4 6.9 4 9.2c0 2 .5 3.4 1 5.3.4 1.6.6 3 .9 4.3.2 1 .8 1.7 1.5 1.7.8 0 1.2-.7 1.4-1.8.3-1.5.5-3 1.7-3 1.2 0 1.4 1.5 1.7 3 .2 1.1.6 1.8 1.4 1.8.7 0 1.3-.7 1.5-1.7.3-1.3.5-2.7.9-4.3.5-1.9 1-3.3 1-5.3 0-2.3-1-4.3-3-5.1-1.6-.6-3.4 0-5 1.4Z"
                    />
                </svg>
            </div>

            <h1 class="text-balance text-4xl font-semibold leading-tight tracking-tight text-slate-900 sm:text-5xl">
                {{ title }}
            </h1>

            <p class="mt-5 text-sm font-semibold uppercase tracking-[0.3em] text-teal-600">
                {{ tagline }}
            </p>

            <p class="mt-8 max-w-lg text-balance text-lg leading-relaxed text-slate-600">
                We're building a better experience for dental practice billing and team training.
                Our new website is on its way.
            </p>

            <div class="mt-10 h-px w-24 bg-slate-300/70" aria-hidden="true"></div>
        </div>

        <footer class="relative z-10 mt-16 text-sm text-slate-500">
            <p>&copy; {{ year }} {{ title }}</p>
            <p class="mt-1">
                a
                <a
                    href="https://moonwhale.media"
                    target="_blank"
                    rel="noopener"
                    class="font-medium text-teal-600 underline-offset-2 hover:underline"
                    >moonwhale.media</a
                >
                production
            </p>
        </footer>
    </main>
</template>
