<script>
  export let project
</script>
<h1> Configure Project </h1>

<a href={project.url} target="_blank"> {project.remote_repository_id} </a>
{#if project.existing_recognized_repo }
  <p> This repo already has a recognized project </p>
{/if}

{#if project.repo_public && project.config_from_repo && !project.existing_recognized_repo}
  <p> This repo is public, has a config in the repo and there is no other existing recognized repo </p>
{/if}

<div class="col-4 mt-4">
  <form action="/" method="post">
    <label for="name" class="form-label"> Name </label>
    <input type="text" name="name" value={project.name} class="form-control"/>
    <label for="translations_path" class="form-label"> Translations path </label>
    <input type="text" name="translations_path" value={project.translations_path} class="form-control" disabled={project.use_config_from_repo}/>
    {#if project.config_from_repo.translations_path}
      <div class="form-text">
        from config: {project.config_from_repo.translations_path}
      </div>
    {/if}
    <label for="default_locale" class="form-label"> Default locale </label>
    <input type="text" name="default_locale" value={project.default_locale} class="form-control" disabled={project.use_config_from_repo}/>
    {#if project.config_from_repo.default_locale}
      <div class="form-text">
        from config: {project.config_from_repo.default_locale}
      </div>
    {/if}
    <div class="form-text">

    </div>

    <div class="form-check">
      <label for="use_config_from_repo" class="form-check-label"> Use config from repo </label>
      <input bind:checked={project.use_config_from_repo} type="checkbox" name="use_config_from_repo" class="form-check-input" id="use_config_from_repo"/>
    </div>
    <input type="submit" value="Configure" class="btn btn-info mt-3" />
  </form>
</div>
