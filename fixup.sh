git submodule foreach 'git add . && git commit -m "Restructure: final fixes" || true'
git add ada_lib applications aunit gnoga_lib vendor/github.com/gnoga
git commit -m "Final restructure – update all submodules to fixed versions"
