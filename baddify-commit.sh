#!/bin/bash

# Making a commit SHA
# git log | head -1
# (printf "commit %s\0" $(git cat-file commit HEAD | wc -c); git cat-file commit HEAD) | sha1sum.exe 

# rewrite just timestamp stuff
# author_time=$(git show -s --format="%ai")
# commit_time=$(git show -s --format="%ci")

# can use epoch time. Integer mathable.
# author_time=$(git show -s --format="%ai")  # Use ISO 8601-like format (%ai) to be sure to keep timezone
# commit_time=$(git show -s --format="%ct")  # Loses timezone. Assuming -0701 to identify us and draft commit

# GIT_COMMITTER_DATE="$commit_time -0701" git commit --amend --no-edit --date="$author_time"

# git log | head -1
# (printf "commit %s\0" $(git cat-file commit HEAD | wc -c); git cat-file commit HEAD) |sha1sum.exe
# (printf "commit %s\0" $(git cat-file commit HEAD | wc -c); IFS=; printf "%s\n" $(git cat-file commit HEAD))|sha1sum.exe

prefix=$(printf "commit %s\0" $(git cat-file commit HEAD | wc -c))
cat_file_head=$(git cat-file commit HEAD)
# (printf "%s\0%s\n" "$(echo "$prefix")" "$(echo "$cat_file_head")" ) |sha1sum.exe

my_array=()
while IFS= read -r line; do
    my_array+=( "$line" )
done < <( git cat-file commit HEAD )

tree=${my_array[0]}
parent=${my_array[1]}
author=${my_array[2]}
committer=${my_array[3]}
empty=${my_array[4]}
msg=$(IFS=; printf "%s\n" "${my_array[@]:5}")  # Crazy thing to grab rest of lines

# Following was verified to have expected sha1sum
# printf '%s\0%s\n%s\n%s\n%s\n%s\n%s\n%s' "$prefix" "${tree}" "${parent}" "${author}" "${committer}" "${empty}" "${msg}"

# TODO: here we can assert that our calculation matches the last git commit

# get all but last two fields and trim trailing spaces
committer_prefix=$(echo ${committer} | awk '{$NF=""; $(NF-1)=""; print $0'} | awk '{$1=$1;print}') 
author_timestamp=$(echo ${author} | awk '{print $(NF-1)}')
committer_timestamp=$(echo ${author} | awk '{print $(NF-1)}')
committer_timedelta=$(echo ${author} | awk '{print $(NF)}')

# Intentionally take author_prefix here, with new committer timestamp
new_committer="$author_prefix $committer_timestamp $committer_timedelta"

potential_body="$(printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' "${tree}" "${parent}" "${author}" "${committer}" "${empty}" "${msg}")"
hash=$((printf "%s\0%s\n" "$(echo "$prefix")" "$(echo "$potential_body")" ) |sha1sum.exe)
echo "$hash should match $(git log | head -1)"

until echo $hash | grep "^bad"
do
  let committer_timestamp=committer_timestamp+1
  new_committer="$committer_prefix $committer_timestamp $committer_timedelta"

  potential_body="$(printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n' "${tree}" "${parent}" "${author}" "${new_committer}" "${empty}" "${msg}")"
  hash=$((printf "%s\0%s\n" "$(echo "$prefix")" "$(echo "$potential_body")" ) |sha1sum.exe)
  echo $hash
done
echo "$potential_body"

GIT_COMMITTER_DATE="$committer_timestamp $committer_timedelta" git commit --amend --no-edit --date="$author_timestamp"

# branch=$(git rev-parse --abbrev-ref HEAD)

# n=0
# until git commit --amend --no-edit --verbose | grep "$branch bad"
# do
#   let n=n+1
#   sleep 0.9 # hash changes every second? Sucks. will take 1-68 minutes. :-(
#   echo $n
# done
