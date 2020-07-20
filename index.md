---
title: Get Creative With Kha (github)
layout: article
---

{% assign sections = site.pages
 | group_by: 'section'
 | where_exp: "section", 'section.name != ""'
 | sort: 'name'
%}
{% for section in sections %}
## {{section.name}}
<article class="demo-index">
{% assign sorted = section.items | sort:'order' %}
{% for page in sorted %}
  <div class="demo-index__card">
    <a href="{{site.url}}{{site.baseurl}}{{page.url}}index.html"
       style="background-image: url('{{site.url}}{{site.baseurl}}{{page.url}}Screenshot.png')" >
      <footer>
        <h4>{{page.title}}</h4>
      </footer>
    </a>
  </div>
{% endfor %}
</article>
{% endfor %}
