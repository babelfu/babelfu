// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"

import LocalesController from "./locales_controller"
application.register("locales", LocalesController)

import TranslationsController from "./translations_controller"
application.register("translations", TranslationsController)



// Eager load all controllers defined in the import map under controllers/**/*_controller
// import { eagerLoadControllersFrom } from "@hotwired/stimulus"
// eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
