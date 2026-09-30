import { Controller } from "@hotwired/stimulus";

// Abre/fecha um menu. Fecha ao clicar fora ou apertar Esc.
export default class extends Controller {
  static targets = ["menu"];

  toggle(event) {
    event.preventDefault();
    this.menuTarget.classList.contains("hidden") ? this.open() : this.close();
  }

  open() {
    this.menuTarget.classList.remove("hidden");
  }

  close() {
    this.menuTarget.classList.add("hidden");
  }

  hide(event) {
    if (!this.element.contains(event.target)) this.close();
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close();
  }
}
