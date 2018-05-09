A test repo for screwing with git commit IDs

## baddify-commit.sh ##
![Sample Commit History](_pics/bad-github-history.png)

### Usage ###
```console
$ git add baddify-commit.sh

$ git commit -m "bad update for a little more readability"
[master 636e681] bad update for a little more readability
 1 file changed, 8 insertions(+), 4 deletions(-)

 $ time ./baddify-commit.sh
 636e681e054636de71b505fc7d0522d29f885a63 *- should match commit 636e681e054636de71b505fc7d0522d29f885a63
 ea6575247acf28bc04059aa07d9f2b3b0c180783 *-
 f0828001e0dd215e7463ed7872cef538dc2c1229 *-

 ...snip lots more candidate hashes...

 b176d90259b0e8d9bb11a24c670fb47328aadbba *-
 bad82daf8384b3a7cb0b653deb6c62034fa28d1b *-
 bad82daf8384b3a7cb0b653deb6c62034fa28d1b *-
 tree 055d899758f34735627029b73e9f6c7749c572e8
 parent bade388bfb10cfc6b7209cc1bc4556218ce5ca7d
 author Gabe Funky <gabriel@gsource.org> 1525907162 -0700
 committer Gabe Funky <gabriel@gsource.org> 1525907734 -0700

 bad update for a little more readability
 [master bad82da] bad update for a little more readability
  Date: Wed May 9 16:06:02 2018 -0700
   1 file changed, 8 insertions(+), 4 deletions(-)

   real    0m40.599s
   user    0m13.002s
   sys     0m32.738s


   $ git push
   Counting objects: 3, done.
   Delta compression using up to 8 threads.
   Compressing objects: 100% (3/3), done.
   Writing objects: 100% (3/3), 578 bytes | 578.00 KiB/s, done.
   Total 3 (delta 1), reused 0 (delta 0)
   remote: Resolving deltas: 100% (1/1), completed with 1 local object.
   To https://github.com/gmanfunky/commit-vanity.git
      bad1388..bad82da  master -> master

```

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
  - for invalid offsets 60+ minutes, it seems git commandline will default to commit time
  - Github seems to auto-fixup author date, and ignore committer date when displaying commit details. \
  so have fun with the commit time?
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
