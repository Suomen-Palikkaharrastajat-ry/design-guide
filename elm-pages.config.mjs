import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default {
  vite: {
    plugins: [tailwindcss()],
  },
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<link rel="icon" type="image/x-icon" href="/favicon/favicon.ico" />
<link rel="icon" type="image/png" sizes="64x64" href="/favicon/favicon-64.png" />
<link rel="icon" type="image/png" sizes="48x48" href="/favicon/favicon-48.png" />
<link rel="icon" type="image/png" sizes="32x32" href="/favicon/favicon-32.png" />
<link rel="icon" type="image/png" sizes="16x16" href="/favicon/favicon-16.png" />
<link rel="apple-touch-icon" sizes="180x180" href="/favicon/apple-touch-icon.png" />
<link rel="apple-touch-icon" sizes="167x167" href="/favicon/apple-touch-icon-167.png" />
<link rel="apple-touch-icon" sizes="152x152" href="/favicon/apple-touch-icon-152.png" />
<link rel="apple-touch-icon" sizes="120x120" href="/favicon/apple-touch-icon-120.png" />
    `;
  },
  preloadTagForFile(file) {
    if (file.endsWith(".js")) return true;
    if (file.endsWith(".ttf")) return true;
    return false;
  },
};
