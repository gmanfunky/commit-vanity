#!/usr/bin/ruby
# frozen_string_literal: true

# Can target a 5 digit hash in under 2 seconds. 8 digits in under 2 hours?
require 'digest'
require 'time'

# Example commit data for hashing
#
# data = """commit 229\0tree fc4ed2ce3d4f35ee0c019e953aea91c775bb50a6
# parent baddcd5a88ad9882ee2ed6a9e4e0379db9c44e16
# author Gabe Funky <gabriel@gsource.org> 1525909754 -0700
# committer Gabe Funky <gabriel@gsource.org> 1525917089 -0700

# bad empty commit
# """
# > sha1 = Digest::SHA1.new << data
# => #<Digest::SHA1: bad83c74495d6f0398b3ed66bcca309cec3e1878>

desired_prefix = ARGV[0] ? ARGV[0] : '31337' # <2 seconds
initial_hash = `git rev-parse HEAD`
exit(0) if initial_hash.start_with?(desired_prefix)

commit_data = `git cat-file commit HEAD`
print "\n"
print "Initial Commit Data:\n#{commit_data}\n\n"

commit_prefix = "commit #{commit_data.length}\0"
tree, parent, author, committer = commit_data.lines
message = commit_data.lines[4..-1].join

# prepare for timestamp increase & re-hash loop
author_prefix = author.split(' ')[0..-3].join(' ')
author_seconds = Integer(author.split(' ')[-2])
author_timedelta = author.split(' ')[-1]

_committer_prefix = committer.split(' ')[0..-3].join(' ')
committer_seconds = Integer(committer.split(' ')[-2])
committer_timedelta = committer.split(' ')[-1]

candidate_string, candidate_hash = [nil] * 2
sha1 = Digest::SHA1.new

begin_time = Time.now

loop do
  author_seconds += 1
  candidate_string = "\
#{commit_prefix}#{tree}\
#{parent}\
#{author_prefix} #{author_seconds} #{author_timedelta}\n\
#{committer}\
#{message}"
  candidate_hash = sha1.hexdigest(candidate_string)
  # print "Candidate Hash: #{candidate_hash}\n"
  break if candidate_hash.start_with?(desired_prefix)
end

print "Processed #{author_seconds - committer_seconds} hashes in #{Time.now - begin_time} seconds.\n"
print "\n"
print "Target Hash is #{candidate_hash}\n"
print "For Commit String: #{candidate_string}\n"

# print "press any key to commit to git\n"
# gets

ENV['GIT_COMMITTER_DATE'] = "#{committer_seconds} #{committer_timedelta}"
`git commit --no-verify --allow-empty-message --amend --no-edit --date="#{author_seconds}"`
