import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "ratingValue", "stars"]

  connect() {
    this.starsTargets.forEach(star => {
      star.addEventListener("mouseover", this.highlightStars.bind(this));
      star.addEventListener("mouseout", this.resetStars.bind(this));
    });
    this.resetStars();
  }

  submitRating(event) {
    const rating = event.currentTarget.dataset.index;
    this.ratingValueTarget.value = rating;
    this.formTarget.requestSubmit();
  }

  highlightStars(event) {
    const rating = event.currentTarget.dataset.index;
    this.updateStars(rating);
  }

  resetStars() {
    const initialRating = this.ratingValueTarget.value || 0;
    this.updateStars(initialRating);
  }

  updateStars(rating) {
    this.starsTargets.forEach((star, index) => {
      if (index < rating) {
        star.classList.add("text-yellow-400");
        star.classList.remove("text-gray-400");
      } else {
        star.classList.add("text-gray-400");
        star.classList.remove("text-yellow-400");
      }
    });
  }
}
