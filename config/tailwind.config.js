module.exports = {
  content: [
    './app/views/**/*',
    './app/helpers/**/*',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
