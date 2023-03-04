# Advanced Git CLI commands patterns

## Adjust git's HTTP headers

Internally `git`
[uses `cURL`, we can tell it via `http.extraheader` option](https://git-scm.com/docs/git-config#Documentation/git-config.txt-httpextraHeader)

```bash
git -c http.extraheader='PERSONAL-TOKEN:111' clone https://gitlab.example.org:50043/Foo/bar.git
git -c http.extraheader='PERSONAL-TOKEN:111' clone https://username@gitlab.example.org:50043/Foo/bar.git
export GIT_TRACE=1
git -c credential.useHttpPath=1 -c http.extraheader='PERSONAL-TOKEN:111' clone https://username@gitlab.example.org:50043/Foo/bar.git
git help -a | grep credential
git help credential-store
```
