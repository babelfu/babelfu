<script>
  import LocaleTranslation from './LocaleTranslation.svelte';

  export let proposalsPath;
  export let branchName;
  export let locales = [];
  export let keys = [];
  export let matrix = {};
</script>

<table class="table table-hover">
  <thead>
    <tr>
      <th>Key</th>
      {#each locales as locale}
        <th>{locale}</th>
      {/each}
    </tr>
  </thead>
  <tbody>
    { #each keys as key }
      <tr>
        <td>{key}</td>
        {#each locales as locale}
          <td>
            {#if matrix[locale][key] }
              <LocaleTranslation branchName={branchName} proposalsPath={proposalsPath} key={key} locale={locale} value={matrix[locale][key].value} proposal={matrix[locale][key].proposal} base={matrix[locale][key].base} />
        {:else }
          {`${key}, ${locale}`}
          {/if}
          </td>
        {/each}
      </tr>
    {/each}
  </tbody>
</table>

