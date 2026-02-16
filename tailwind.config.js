/** @type {import('tailwindcss').Config} */

export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        brand: {
          orange: "#FF6B35",
          green: "#4CAF50",
          gray: "#F5F5F5",
        },
      },
    },
  },
  plugins: [],
};
