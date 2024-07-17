<script>
  import LocaleTranslation from './LocaleTranslation.svelte';

  export let proposalsPath;
  export let branchName;
  export let locales = [];
  export let keys = [];
  export let matrix = {};
  export let canEdit = false;

  const searchBy = (key) => {
    return () => {
      const url = new URL(window.location.href);
      url.searchParams.set('filter_key', key);
      url.searchParams.delete('page');
      Turbo.visit(url);
    };
  };
</script>

<table class="table table-hover">
  <thead>
    <tr>
      <th class="key-header">Key</th>
      <th class="locale-header"></th>
      <th class="translation-header"> Translation </th>
    </tr>
  </thead>
  <tbody>
    { #each keys as key }
      <tr>
        <td class="-part" rowspan={locales.length + 1}>
          <div class="font-monospace d-flex flex-wrap">
            { #each key.split('.') as part, index }
              <span on:click={searchBy(part)} class="key-part text-wrap text-break">{#if index == key.split('.').length - 1}{part}{:else}{part}.{/if}</span>
            {/each}
          </div>
        </td>
      </tr>
      {#each locales as locale}
        <tr>
          <td class="text-end">{locale}</td>
          <td>
            {#if matrix[locale][key] }
              {#if canEdit }
                <LocaleTranslation branchName={branchName} proposalsPath={proposalsPath} key={key} locale={locale} value={matrix[locale][key].value} proposal={matrix[locale][key].proposal} base={matrix[locale][key].base} />
              {:else }
                {matrix[locale][key].value}
              {/if}
        {:else }
          {`${key}, ${locale}`}
          {/if}
          </td>
        </tr>
      {/each}
    {/each}
  </tbody>
</table>

<style>
  .key-header {
    width: 400px;
  }
  .key-part {
    max-width: 400px;
    cursor: pointer;
  }
  .key-part:hover {
    border: 1px solid #ccc;
    border-radius: 5px;
  }
  .locale-header {
    width: 50px;
  }
  .translation-header {
    width: auto;
  }
</style>
