import { Controller } from "@hotwired/stimulus"

// Month grid + modal for adding poll time slots (creator flow).
export default class extends Controller {
  static targets = ["grid", "monthLabel", "dialog", "modalTitle", "dateField", "timeWindow", "presetWrap"]
  static values = {
    slots: Object,
    slotMinutes: Object,
    anchor: { type: String, default: "" }
  }

  connect() {
    const base =
      this.anchorValue && this.anchorValue.length > 0 ?
        this.parseIso(this.anchorValue) :
        this.startOfDay(new Date())
    this.today = this.startOfDay(base)
    this.viewDate = new Date(this.today.getFullYear(), this.today.getMonth(), 1)
    this.renderCalendar()
  }

  startOfDay(d) {
    return new Date(d.getFullYear(), d.getMonth(), d.getDate())
  }

  disconnect() {
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  slotsMap() {
    return this.hasSlotsValue ? this.slotsValue : {}
  }

  minutesMap() {
    return this.hasSlotMinutesValue ? this.slotMinutesValue : {}
  }

  rangesOnDate(iso) {
    const raw = this.minutesMap()[iso]
    if (!raw || !Array.isArray(raw)) return []
    return raw.map((pair) => [Number(pair[0]), Number(pair[1])])
  }

  isoFromYmd(y, m0, day) {
    const m = String(m0 + 1).padStart(2, "0")
    const d = String(day).padStart(2, "0")
    return `${y}-${m}-${d}`
  }

  parseIso(iso) {
    const [y, m, d] = iso.split("-").map(Number)
    return new Date(y, m - 1, d)
  }

  prevMonth() {
    this.viewDate = new Date(this.viewDate.getFullYear(), this.viewDate.getMonth() - 1, 1)
    this.renderCalendar()
  }

  nextMonth() {
    this.viewDate = new Date(this.viewDate.getFullYear(), this.viewDate.getMonth() + 1, 1)
    this.renderCalendar()
  }

  selectDay(event) {
    const iso = event.currentTarget.dataset.iso
    if (!iso) return

    this.dateFieldTargets.forEach((el) => {
      el.value = iso
    })
    this.modalTitleTarget.textContent = this.formatHeading(iso)
    this.timeWindowTarget.value = ""
    this.updatePresetAvailability(iso)
    this.dialogTarget.showModal()
    this.timeWindowTarget.focus()
  }

  updatePresetAvailability(iso) {
    if (!this.hasPresetWrapTarget) return

    const ranges = this.rangesOnDate(iso)
    this.presetWrapTargets.forEach((wrap) => {
      const s = Number.parseInt(wrap.dataset.startMin, 10)
      const e = Number.parseInt(wrap.dataset.endMin, 10)
      const taken = ranges.some(([a, b]) => a === s && b === e)
      const btn = wrap.querySelector('input[type="submit"]')
      if (btn) btn.disabled = taken
      wrap.classList.toggle("preset-wrap--disabled", taken)
      wrap.setAttribute("aria-disabled", taken ? "true" : "false")
    })
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) this.dialogTarget.close()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  closeModal() {
    this.dialogTarget.close()
  }

  formatHeading(iso) {
    const d = this.parseIso(iso)
    return d.toLocaleDateString(undefined, { weekday: "long", month: "long", day: "numeric", year: "numeric" })
  }

  formatAriaDay(iso, hasSlots) {
    const h = this.formatHeading(iso)
    return hasSlots ? `${h}, has proposed times` : `${h}, add a time`
  }

  escapeHtml(str) {
    const el = document.createElement("div")
    el.textContent = str
    return el.innerHTML
  }

  renderCalendar() {
    const y = this.viewDate.getFullYear()
    const m = this.viewDate.getMonth()
    this.monthLabelTarget.textContent = new Date(y, m, 1).toLocaleDateString(undefined, {
      month: "long",
      year: "numeric"
    })

    const first = new Date(y, m, 1)
    const startPad = (first.getDay() + 6) % 7
    const daysInMonth = new Date(y, m + 1, 0).getDate()
    const prevMonthDays = new Date(y, m, 0).getDate()
    const slots = this.slotsMap()
    const todayIso = this.isoFromYmd(this.today.getFullYear(), this.today.getMonth(), this.today.getDate())

    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let html = ""
    for (const w of weekdays) {
      html += `<div class="calendar__weekday">${w}</div>`
    }

    for (let i = 0; i < startPad; i++) {
      const dayNum = prevMonthDays - startPad + i + 1
      html += `<div class="calendar__day calendar__day--muted" aria-hidden="true">${dayNum}</div>`
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const iso = this.isoFromYmd(y, m, day)
      const slotLabels = slots[iso] || []
      const hasSlots = slotLabels.length > 0
      const isToday = iso === todayIso

      let cls = "calendar__day calendar__day--current-month"
      if (isToday) cls += " calendar__day--today"
      if (hasSlots) cls += " calendar__day--has-slots"

      const preview =
        hasSlots ?
          `<span class="calendar__slot-preview">${this.escapeHtml(slotLabels[0])}${slotLabels.length > 1 ? ` +${slotLabels.length - 1}` : ""}</span>` :
          ""

      const dot = hasSlots ? '<span class="calendar__slot-dot" aria-hidden="true"></span>' : ""

      html +=
        `<button type="button" class="${cls}" data-action="click->slot-calendar#selectDay" data-iso="${iso}" aria-label="${this.escapeHtml(this.formatAriaDay(iso, hasSlots))}">` +
        `<span class="calendar__day-num">${day}</span>${dot}${preview}</button>`
    }

    const totalCells = startPad + daysInMonth
    const trailing = (7 - (totalCells % 7)) % 7
    for (let i = 1; i <= trailing; i++) {
      html += `<div class="calendar__day calendar__day--muted" aria-hidden="true">${i}</div>`
    }

    this.gridTarget.innerHTML = html
  }
}
