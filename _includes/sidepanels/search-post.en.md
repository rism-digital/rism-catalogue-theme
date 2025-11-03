
{% assign search_category_label = site.data.locales | where: "id", "search-category-label" | first %}
{% assign search_category_any = site.data.locales | where: "id", "search-category-any" | first %}

<div class="field">
    <label class="label">{{ search_category_label.name[site.active_lang] }}</label>
    <p class="control has-icons-left">
        <span class="select is-small is-fullwidth">
            <select id="website-search-category" name="category">
            {% assign labels = site.data.categories %}
            {% for category in site.categories %}
                {% assign label = labels | where: "id", category[0] | first %}
                <option value="{{ category[0] }}">{{ label.name[site.active_lang] }}</option>
            {% endfor %}    
                <option value="any" selected>{{ search_category_any.name[site.active_lang] }}</option>
            </select>
        </span>
        <span class="icon is-small is-left">
            <i class="fas fa-folder-open"></i>
        </span>
    </p>
</div>
