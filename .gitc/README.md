# gitc - Git Containers - v0.1

Git Containers intend to help you journal the process by which you
generate a change in your Git repository, supplementing your
line-by-line diffs with concise, reproducible edit commands.

To achieve this, gitc will require you to commit the binaries used to
generate the changes, and help you log the arguments you passed to
those binaries to generate the changes.

## Current Implementation

The current implementation uses a [busybox](https://busybox.net/), and
provides a command-recording shell. By committing the busybox (and
surrounding shell scripts) to your repository, you can log your
changes merely by committing the command log.

If you would like to manually reproduce the changes, you can use your
variants of the software, and just run the commands in the log, or you
can start up `gitc-shell.sh` and reproduce the results using the
provided busybox.

I recommend running `gitc-shell.sh` as follows:

```
$ PATH="$(pwd)/.gitc/bin:$PATH" gitc-shell.sh
```

## Usage

Make sure that the repository is _clean_: No non-staged or untracked
files.

Run

```
$ PATH="$(pwd)/.gitc/bin:$PATH" gitc-record.sh
```

to get a busybox shell which will also record your commands, and
commit them to get when done. You will get to modify the commit
message before commit.

**NB!** The shell you get is a little rough, and things go bad if your
commands fail. Press Ctrl+D when done.
