<script>
  export let proposalsPath, branchName;
  export let key, locale, value, proposal, base;

  let editing, saving = false;
  let tempValue = proposal || value;

  const editTranslation = () => {
    editing = true
  }

  const save = () => {
    saving = true;
    fetch(proposalsPath, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        key,
        locale,
        branch_name: branchName,
        value: tempValue
      })
    }).then(response => {
      saving = false;
      proposal = tempValue;
      editing = false;
    });
  }

  const discard = () => {
    tempValue = value;
    editing = false;
  }
</script>

<div >
  {#if editing}
    {#if saving}
      <textarea bind:value={tempValue} disabled />
      <button disabled>Saving...</button>
    {:else}
      <textarea bind:value={tempValue} />
      <button on:click={save}>Save</button>
      <button on:click={discard}>Discard</button>
    {/if}
  {:else}
    <div class='translation' on:click={editTranslation}>
      {#if base && base !== value}
        <div class="bg-warning-subtle text-warning border border-warning p-1"> {base} </div>
        {#if proposal && proposal !== value}
          <div class="bg-info-subtle text-info border border-info p-1">
            {#if value}
              {value}
              &nbsp;
            {/if}
          </div>
          <div class="bg-success-subtle text-success border border-success p-1"> {proposal} </div>
        {:else}
          <div class="bg-info-subtle text-info border border-info p-1"> {value} </div>
        {/if}
      {:else if proposal && proposal !== value}
        <div class="bg-info-subtle text-info border border-info p-1">
          {#if value}
            {value}
          {/if}
          &nbsp;
        </div>
        <div class="bg-success-subtle text-success border border-success p-1"> {proposal} </div>
      {:else if value}
        {value}
      {:else}
        &nbsp;
      {/if}
    </div>
  {/if}
</div>

<style>
  .translation {
    cursor: pointer;
  }
  .translation:hover {
    background-color: #f8f9fa;
  }
</style>
