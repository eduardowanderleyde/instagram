import { Controller } from "@hotwired/stimulus";

// Modal baseado em <dialog> nativo. Esc fecha pelo próprio navegador;
// clicar no backdrop (fora do conteúdo) também fecha.
export default class extends Controller {
  static targets = ["dialog"];

  open(event) {
    event?.preventDefault();
    this.dialogTarget.showModal();
  }

  close(event) {
    event?.preventDefault();
    this.dialogTarget.close();
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) this.dialogTarget.close();
  }
}
