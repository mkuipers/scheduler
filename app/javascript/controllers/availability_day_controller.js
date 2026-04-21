import { Controller } from "@hotwired/stimulus"

// Participant availability: set all time slots for one day to "no".
export default class extends Controller {
  static targets = ["slot"]

  declineAll() {
    this.slotTargets.forEach((fieldset) => {
      const noRadio = fieldset.querySelector('input[type="radio"][value="no"]')
      if (noRadio) noRadio.checked = true
    })
  }
}
