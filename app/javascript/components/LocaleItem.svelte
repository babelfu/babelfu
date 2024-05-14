<script>
  export let value;
  export let checked = false;
</script>
<label class="dropdown-item" for="filter_locales_{value}">
  <input type="checkbox" id="filter_locales_{value}" name="filter_locales[]" value={value} checked={checked} />
  {value}
</label>
