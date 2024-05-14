<script>
  // This is implemented as Svelte component because the idea was to
  // have a search filter for the locales. But it was not implemented yet.
  import LocaleItem from './LocaleItem.svelte';
  export let availableLocales = [];
  export let selectedLocales = [];
</script>
<div class="dropdown">
  <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-auto-close="outside" data-bs-toggle="dropdown" aria-expanded="false">
    Locales
  </button>
  <div class="dropdown-menu">
    <div><h6 class="dropdown-header">Selected</h6></div>
    {#each selectedLocales as locale}
      <LocaleItem value={locale} checked={true}/>
    {/each}
    <div><hr class="dropdown-divider"></div>
    <div><h6 class="dropdown-header">Available</h6></div>
    {#each availableLocales.filter(x => !selectedLocales.includes(x)) as locale}
      <LocaleItem value={locale} checked={false}/>
    {/each}
  </div>
</div>
<style>
  .dropdown-menu {
    max-height: calc(100vh / 2);
    overflow-y: auto;
  }

</style>
