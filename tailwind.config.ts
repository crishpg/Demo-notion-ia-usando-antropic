import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        notion: {
          50: '#f7f6f3',
          100: '#e9e7e0',
          200: '#d3d0c7',
          300: '#b5b0a4',
          400: '#9a9485',
          500: '#7c786d',
          600: '#65625a',
          700: '#52504a',
          800: '#46443f',
          900: '#3d3b38',
          950: '#242321',
        },
        primary: {
          DEFAULT: '#2563eb',
          hover: '#1d4ed8',
        },
        accent: {
          red: '#eb5757',
          blue: '#2d7ff9',
          green: '#18ab56',
          yellow: '#ffa344',
          purple: '#9b51e0',
          pink: '#e94c8b',
        }
      },
    },
  },
  plugins: [],
};
export default config;
