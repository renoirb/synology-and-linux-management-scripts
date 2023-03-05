# Lazy Aliases

I've been hoarding shell aliases to do things that I'm too lazy to memorize.

The commands starts by `lazy_`, cherry pick anything you need from this.

```bash
lazy_memusage () {
  ps -ylC "$@" --sort:rss | awk '!/RSS/ { s+=$8 } END { printf "%s\n", "Total memory used:"; printf "%dM\n", s/1024 }'
}

# ref: http://www.commandlinefu.com/commands/view/3543/show-apps-that-use-internet-connection-at-the-moment.
lazy_lsof_network_services() {
  lsof -P -i -n | cut -f 1 -d " "| uniq | tail -n +2
}

lazy_openssl_read() {
  openssl x509 -text -in $1 | more
}

lazy_lsof_socks(){
  lsof -P -i -n | less
}

lazy_lsof() {
  /usr/bin/lsof -w -l | less
}

lazy_trailing_whitespace() {
  if [ -f "$1" ]; then
    sed -i 's/[ \t]*$//' "$1"
  fi
}

#List all commiters
#git shortlog -sn

# ref: http://stackoverflow.com/questions/26370185/how-do-criss-cross-merges-arise-in-git
lazy_git_log() {
  git log --graph --oneline --decorate --all
}

lazy_git_search_file() {
  git log --all --name-only --pretty=format: | sort -u | grep "$1"
}

# ref: http://hardenubuntu.com/disable-services
alias lazy_processes="initctl list | grep running"

alias lazy_connections="netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n"

lazy_html_compact () {
  if [ -f "$1" ]; then
    cat $1 | tr '\t' ' ' | tr '\n' ' ' | sed 's/  //g' | sed 's/> </></g' > $1
  fi
}

lazy_serve_http () {
  python -m SimpleHTTPServer 8080
}

lazy_convert_yml_json () {
  if [ -f "$1" ]; then
    python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=2)' < $1 > $1.json
  fi
}
```
