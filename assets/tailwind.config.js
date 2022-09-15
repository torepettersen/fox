// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    container: {
      center: true,
      padding: '2rem',
    },
    extend: {
      fontFamily: {
        sans: ['Montserrat', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'primary': '#0967D2',
      },
      fontSize: {
        'xs': '.75rem',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp'),
  ]
}
