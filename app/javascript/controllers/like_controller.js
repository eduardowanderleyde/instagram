import { Controller } from "@hotwired/stimulus";

// Curte o post com duplo clique na imagem, reaproveitando o botão de like.
export default class extends Controller {
  static targets = ["button"];

  like() {
    if (this.hasButtonTarget) this.buttonTarget.click();
  }
}
