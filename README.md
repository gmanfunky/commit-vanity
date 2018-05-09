A test repo for screwing with git commit IDs

## Questions ##
- Can i add or remove files of various whitespace to calculate different pretty git commit SHA1?
- Can i add history before first null commit 000000000000
- Maybe use tons of file move commands to generate new commits? 
- Maybe mess with the author info. Multiple author entries? Or timestamp changes. Or timestamp+timezone changes? (add to timestamp, change offset)
- Super dumb hack: just keep ammending last commit until getting what we want
- `git commit --allow-empty` allows same tree. Might be used to make a short story with SHA1?
- How to cleanup stale objects? `git -c gc.reflogExpireUnreachable=0 -c gc.pruneExpire=now gc`
- Are there usable git libraries call quickly? 
- Generate and edit file directly? Read last commit, loop making new ones until ready to replace log
- Maybe munge author (not committer) details. Author timestamp seems most malleable.
- What happens on github is timezone is not recognized (e.g., +0111 or +0199 _gnarly!_)
- Stretch - "fixup" after a rebase changes all the commits. (e.g., `baddify-commits.sh HEAD^4`)

## Quick Math ##
```bash
# 3 base 16 digit permutations. Want something like "bad"
$ echo $((16 * 16 * 16))
4096
```

## Fun Short Hex Words ##
```
bad
fed
decaf
abe
dead
ca7 # caT?
d06 # Nice and trolly for them cat people?
abcd
ace
beef
face
babe
eff
effed
1337
00f
f00
fab # Code must be fabulous. ¯\_(ツ)_/¯
```

Additional Reference: http://www.nsftools.com/tips/HexWords.htm

## How is a git commit sha1 formed ##
See https://gist.github.com/masak/2415865
```
$ (printf "commit %s\0" $(git cat-file commit HEAD | wc -c); git cat-file commit HEAD) | sha1sum.exe ; git log | head -1
dc9decb23a96ebc4090aee1df73d50f2c31f2e9c *-
commit b23e9b68becf18bad0c7649d04ddfc8e7af27b05
```

## Hacky PoC Commands ##
```
GIT_COMMITTER_DATE='2000-01-01T00:00:00+0000' git commit --date='2000-01-01T00:00:00+0000'
```
