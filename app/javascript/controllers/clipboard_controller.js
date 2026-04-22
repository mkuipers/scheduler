import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["button"]

  async copy() {
    const label = this.hasButtonTarget ? this.buttonTarget.textContent : ""
    try {
      await navigator.clipboard.writeText(this.textValue)
      if (this.hasButtonTarget) {
        this.buttonTarget.textContent = "Copied!"
        this.buttonTarget.disabled = true
        window.setTimeout(() => {
          this.buttonTarget.textContent = label
          this.buttonTarget.disabled = false
        }, 2000)
      }
    } catch {
      if (this.hasButtonTarget) {
        this.buttonTarget.textContent = "Failed"
        window.setTimeout(() => {
          this.buttonTarget.textContent = label
        }, 2000)
      }
    }
  }
}
