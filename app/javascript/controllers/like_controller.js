import { Controller } from "@hotwired/stimulus";

// Curte o post com duplo clique na imagem, reaproveitando o botão de like.
export default class extends Controller {
  static targets = ["button"];

  like(event) {
    // Ignora duplo clique em controles sobre a imagem (setas do carrossel).
    if (event?.target.closest("button")) return;
    if (this.hasButtonTarget) this.buttonTarget.click();
  }
}
