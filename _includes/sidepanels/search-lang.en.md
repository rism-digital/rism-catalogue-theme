
{% assign search_title = site.data.locales | where: "id", "search-title" | first %}
{% assign search_input = site.data.locales | where: "id", "search-input" | first %}
{% assign search_tip = site.data.locales | where: "id", "search-tip" | first %}
{% assign search_lang_label = site.data.locales | where: "id", "search-lang-label" | first %}
{% assign search_lang_any = site.data.locales | where: "id", "search-lang-any" | first %}

<h1>{{ search_title.name[site.active_lang] }}</h1>

<div id="website-search-form" style="display: none;">
    {% assign action = "/search.html" %}
    {% if site.active_lang != "en" %}{% assign action = "/" | append: site.active_lang | append: action"  %}{% endif %}
    <form action="{{ action }}">
        <div class="field">
            <div class="control">
                <input id="website-search" class="input is-small" type="text" name="q" placeholder="{{ search_input.name[site.active_lang] }} ... ">
            </div>
        </div>
        {% if search_tip %}
        <p><i>{{ search_tip.name[site.active_lang] }}</i></p>
        {% endif %}
        <div class="field">
            <label class="label">{{ search_lang_label.name[site.active_lang] }}</label>
            <p class="control has-icons-left">
                <span class="select is-small is-fullwidth">
                    <select id="website-search-lang" name="lang">
                            <option {% if site.active_lang == "en" %}selected{% endif %} value="xxen">English</option>
                            {% if site.languages contains 'de' %}<option {% if site.active_lang == "de" %}selected{% endif %} value="xxde">Deutsch</option>{% endif %}
                            {% if site.languages contains 'fr' %}<option {% if site.active_lang == "fr" %}selected{% endif %} value="xxfr">Français</option>{% endif %}
                            {% if site.languages contains 'it' %}<option {% if site.active_lang == "it" %}selected{% endif %} value="xxit">Italiano</option>{% endif %}
                            <option value="any">{{ search_lang_any.name[site.active_lang] }}</option>
                    </select>
                </span>
                <span class="icon is-small is-left">
                    <i class="fas fa-globe"></i>
                </span>
            </p>
        </div>
        {% if site.enable_search_posts %}
            {% include sidepanels/search-post.en.md %}
        {% endif %}
        <button type="submit" class="button is-small is-dark">
            <span class="icon is-small">
                <i class="fas fa-search"></i>
            </span>
        </button>
    </form>
</div>

