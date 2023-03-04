# Reminders of useful AWK patterns

Those are notes kept into [this older Gist, this comment about `awk`][source]

[Source]:
  https://gist.github.com/renoirb/361e4e2817341db4be03b8f667338d47?permalink_comment_id=2281959#gistcomment-2281959

Increment version number using awk. Thanks
[StackOverflow](https://stackoverflow.com/questions/8653126/how-to-increment-version-number-in-a-shell-script)

```sh
#!/usr/bin/env awk
# Incomplete
function inc(s,    a, len1, len2, len3, head, tail)
{
split(s, a, ".")

len1 = length(a)
if(len1==0)
    return -1
else if(len1==1)
    return s+1

len2 = length(a[len1])
len3 = length(a[len1]+1)

head = join(a, 1, len1-1)
tail = sprintf("%0*d", len2, (a[len1]+1)%(10^len2))

if(len2==len3)
    return head "." tail
else
    return inc(head) "." tail
}
function join(a, x, y,    s)
{
for(i=x; i<y; i++)
    s = s a[i] "."
return s a[y]
}
```

Expected outcome

```
1.2.3.99 => 1.2.4.00
```
