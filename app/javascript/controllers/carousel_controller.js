import { Controller } from "@hotwired/stimulus";

// Carrossel simples de imagens do post.
export default class extends Controller {
  static targets = ["slide", "dot", "prev", "next"];

  connect() {
    this.index = 0;
    this.show();
  }

  previous() {
    if (this.index > 0) this.index--;
    this.show();
  }

  next() {
    if (this.index < this.slideTargets.length - 1) this.index++;
    this.show();
  }

  show() {
    const last = this.slideTargets.length - 1;
    this.slideTargets.forEach((slide, i) => slide.classList.toggle("hidden", i !== this.index));
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("bg-blue-500", i === this.index);
      dot.classList.toggle("bg-gray-300", i !== this.index);
    });
    if (this.hasPrevTarget) this.prevTarget.classList.toggle("invisible", this.index === 0);
    if (this.hasNextTarget) this.nextTarget.classList.toggle("invisible", this.index === last);
  }
}
