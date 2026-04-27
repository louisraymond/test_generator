# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# CodeMirror 6 — pinned via JSPM as a single bundle. Importmap can't tree-shake;
# bundling at the CDN keeps the round-trip count low. KaTeX is loaded via <link>+<script>
# in the layouts already (no pin needed).
pin "@codemirror/state",            to: "https://ga.jspm.io/npm:@codemirror/state@6.4.1/dist/index.js"
pin "@codemirror/view",             to: "https://ga.jspm.io/npm:@codemirror/view@6.26.3/dist/index.js"
pin "@codemirror/commands",         to: "https://ga.jspm.io/npm:@codemirror/commands@6.5.0/dist/index.js"
pin "@codemirror/language",         to: "https://ga.jspm.io/npm:@codemirror/language@6.10.1/dist/index.js"
pin "@codemirror/lang-markdown",    to: "https://ga.jspm.io/npm:@codemirror/lang-markdown@6.2.5/dist/index.js"
pin "@lezer/markdown",              to: "https://ga.jspm.io/npm:@lezer/markdown@1.3.0/dist/index.js"
pin "@lezer/highlight",             to: "https://ga.jspm.io/npm:@lezer/highlight@1.2.0/dist/index.js"
pin "@lezer/common",                to: "https://ga.jspm.io/npm:@lezer/common@1.2.1/dist/index.js"
pin "style-mod",                    to: "https://ga.jspm.io/npm:style-mod@4.1.2/src/style-mod.js"
pin "w3c-keyname",                  to: "https://ga.jspm.io/npm:w3c-keyname@2.2.8/index.js"
pin "crelt",                        to: "https://ga.jspm.io/npm:crelt@1.0.6/index.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/lib",         under: "lib"
