import { Controller } from "@hotwired/stimulus"
import Locales from "../components/Locales.svelte";

export default class extends Controller {
  connect() {
    const target = this.element;
    new Locales({
      target: target,
      props: {
        availableLocales: JSON.parse(target.dataset.availableLocales),
        selectedLocales: JSON.parse(target.dataset.selectedLocales),
      }
    })


  }
}
