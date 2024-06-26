import { Controller } from "@hotwired/stimulus"
import Translations from "../components/Translations.svelte";

export default class extends Controller {
  connect() {
    const target = this.element;
    new Translations({
      target: target,
      props: {
        locales: JSON.parse(target.dataset.locales),
        keys: JSON.parse(target.dataset.keys),
        matrix: JSON.parse(target.dataset.matrix),
        proposalsPath: target.dataset.proposalsPath,
        branchName: target.dataset.branchName,
        canEdit: target.dataset.canEdit === "true",
      }
    })
  }
}
