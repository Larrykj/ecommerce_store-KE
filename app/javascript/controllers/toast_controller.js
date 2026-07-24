import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String,
    type: { type: String, default: "success" }
  }

  connect() {
    this.show()
  }

  show() {
    if (this.isInitialized) return
    this.isInitialized = true

    // Ensure toast container exists
    let container = document.getElementById("toastContainer")
    if (!container) {
      container = document.createElement("div")
      container.id = "toastContainer"
      container.className = "toast-container"
      document.body.appendChild(container)
    }

    const icons = { success: "bi-check-lg", warning: "bi-exclamation-lg", error: "bi-x-lg" }
    const iconClass = icons[this.typeValue] || icons.success

    // Build toast DOM safely (no innerHTML with user content)
    this.element.className = `toast-notification ${this.typeValue}`
    this.element.textContent = "" // Clear any existing content

    const iconDiv = document.createElement("div")
    iconDiv.className = "toast-icon"
    const iconEl = document.createElement("i")
    iconEl.className = `bi ${iconClass}`
    iconDiv.appendChild(iconEl)

    const messageSpan = document.createElement("span")
    messageSpan.className = "toast-message"
    messageSpan.textContent = this.messageValue // Safe: uses textContent, not innerHTML

    const closeBtn = document.createElement("button")
    closeBtn.className = "toast-close"
    closeBtn.setAttribute("data-action", "click->toast#close")
    const closeIcon = document.createElement("i")
    closeIcon.className = "bi bi-x"
    closeBtn.appendChild(closeIcon)

    const progressDiv = document.createElement("div")
    progressDiv.className = "toast-progress"

    this.element.append(iconDiv, messageSpan, closeBtn, progressDiv)
    container.appendChild(this.element)

    // Animate in
    setTimeout(() => this.element.classList.add("show"), 50)

    // Auto remove after 4 seconds
    this.timeout = setTimeout(() => this.close(), 4000)
  }

  close() {
    if (this.timeout) clearTimeout(this.timeout)
    this.element.classList.remove("show")
    setTimeout(() => this.element.remove(), 400)
  }
}
