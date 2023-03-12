# Reminders of useful patterns for bash scripts

Those are notes kept into [this older Gist "_Bash useful and neat
snippets_"][source]

[source]:
  https://gist.github.com/renoirb/361e4e2817341db4be03b8f667338d47#file-bash_snippets-md

## Ensure a process exist

```
# incomplete
ps -o pid -C ssh-agent|sed -n '2p'
```

## Append to a file

```
echo 'zend_extension=xdebug.so' | tee -a /etc/php7/conf.d/xdebug.ini
```

or take commented content from a file, and paste it uncommented

```
cat /etc/php7/conf.d/xdebug.ini | sed 's/^;zend_extension/zend_extension/g' >> /etc/php7/conf.d/Z99_dev.ini
```

## Ensure a command exist

```
command -v foobar >/dev/null 2>&1 || { echo >&2 "Required binary foobar not found. This script will not work. Aborting."; exit 1; }
```

## Extract value from JSON API output

```
ETCD_VERSION=$(curl -s -L http://127.0.0.1:2379/version | python -c "import sys, json; print(json.load(sys.stdin)['etcdserver'])")
```

## Ensure a script runs only as root

```
if test "$(id -g)" -ne "0"; then
  (>&2 echo "You must run this as root."; exit 1)
fi
```

### Send to Standard Error Output

```
function stderr { printf "$@\n" >&2; }
```

## Validate if number

```
function is_number(){
  is_number='^[0-9]+$'
  if [[ ! $1 =~ $is_number ]]; then
    return 1
  else
    return 0
  fi
}
```

## Do the same complex command with incremental numbers

Imagine you want to get the IPv4 address of a number of machines. You know the
names will be in sequence (e.g. `0..n`) and you want to create a zone format.

```
seq 0 4 | awk '{printf "+short @192.168.0.3 node%d.local\n", $1}' | xargs -L1 dig
```

## Loop commands from array

```
declare -a IMAGES=(\
                  ubuntu:14.04 \
                  ubuntu:16.04 \
                   )

for image in "${IMAGES[@]}"; do
    docker pull $image
done
```

## Create a file

### With contents that contains variables

```
(cat <<- _EOF_
iface eth0:1 inet static
  address ${IPV4_INTERNAL}
_EOF_
) >> /etc/network/interfaces.d/eth0
```

### As an iteration

**use-case**; you want to format an hosts file (or DNS zone file) based on a
list of nodes where we assign a name and internal IP incrementally.

Desired output would be like this.

```
##########
192.168.0.10	node0	# cluster_member
127.0.1.1	node1	# cluster_member  self
192.168.0.12	node2	# cluster_member
192.168.0.13	node3	# cluster_member
192.168.0.14	node4	# cluster_member
192.168.0.15	node5	# cluster_member
192.168.0.16	node6	# cluster_member
192.168.0.17	node7	# cluster_member
192.168.0.18	node8	# cluster_member
192.168.0.19	node9	# cluster_member
192.168.0.20	node10	# cluster_member
##########
```

Here it is

```
# e.g. this hosts file would be for node1
NODE_NUMBER=1
# e.g. our cluster would have node names starting by this
NODE_NAME_PREFIX=node
# e.g. our cluster would have a maximum of 10 nodes... node0 to node9
NODE_COUNT_MAX=10
# e.g. this hosts file would list IP addresses in sequences starting by this
IPV4_INTERNAL_PREFIX="192.168.0."

LIST=""
for i in `seq 0 $NODE_COUNT_MAX`; do
  if [[ ! "${NODE_NUMBER}" = "${i}" ]]; then
    NODE_POS=$(printf %d $((${i} + 10)))
    IP="${IPV4_INTERNAL_PREFIX}${NODE_POS}"
    APPEND_CLUSTER_MEMBER=""
  else
    IP="127.0.1.1"
    APPEND_CLUSTER_MEMBER=" self"
  fi
  LIST+="${IP}\t${NODE_NAME_PREFIX}${i}\t# cluster_member ${APPEND_CLUSTER_MEMBER}\n"
done

# Append conditionnally to /etc/hosts only if last node is not found in the file
grep -q -e "${NODE_NAME_PREFIX}${i}" /etc/hosts || printf $"\n##########\n${LIST}##########\n" >> /etc/hosts
```

## Rename many files

### Add increment number, replace part of name

Input is a list of files with pattern similar to this

```
02.09.09_Something photo.jpg
02.09.10_Something else - a note.jpg
02.09.11_Another one.jpg

... (a few hundreds like this)
```

And we want out

```
001 Something photo.jpg
002 Something else - a note.jpg
003 Another one.jpg
...
```

Could be done like this

```
ls | cat -n | while read n f; do i=`printf '%03d' "$n"`; fn=`echo $f|sed -E 's/^[0-9\.]+_//g'`; mv "$f" "$i $fn"; done
```

# Awk

## Filter file with path names, truncate last parts

1. Have file with similar contents

**File: example.txt**

```
/foo/bar/bazz/buzz/bizz.jpg
/foo/bar1/bazz1/buzz1/bizz1.jpg
/foo/bar2/bazz2/buzz2/bizz2.jpg
/foo/bar3/bazz3/buzz3/bizz3.jpg
```

2. What we want out

```
/foo/bar/bazz
/foo/bar1/bazz1
/foo/bar2/bazz2
/foo/bar3/bazz3
```

3. Create `path.awk` with following contents

**NOTICE** the `truncate=2`, so we want to take the two last path parts off.

**File: path.awk**

```
BEGIN { truncate=2; print "Path Muncher\n" }
function join(array, start, end, result, i) {
  result = array[start]
  for (i = start + 1; i <= end; i++)
      result = result"/"array[i]
  return result
}
{
    split($0, arr, "/");
    end = length(arr) - truncate;
    print join(arr, 0, end, "/")
}
END { print "\n" }
```

4. Use

```
cat example.txt | awk -f path.awk
Path Muncher

/foo/bar/bazz
/foo/bar1/bazz1
/foo/bar2/bazz2
/foo/bar3/bazz3
```

## Nice self-installable and well written

### BitWarden

Have a look at the script used in the following two commands downloaded over HTTP.

The bash script is quite neat and filled with good patterns.

```bash
http -F https://func.bitwarden.com/api/dl/\?app\=self-host\&platform\=linux
http -F https://func.bitwarden.com/api/dl/\?app\=self-host\&platform\=linux\&variant\=run
```

## More

- [Getting data about files](https://gist.github.com/renoirb/89b9fce3ab41dc08002a806e926d9282)
