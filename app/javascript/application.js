// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Fix for Turbo Streams leaving submit buttons disabled
document.addEventListener("turbo:submit-end", (event) => {
  event.target.querySelectorAll("button[type='submit'], input[type='submit']").forEach(btn => {
    btn.removeAttribute("disabled");
  });
});
import "password_visibility"
