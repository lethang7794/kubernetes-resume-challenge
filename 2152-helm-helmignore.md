# Helm - `.helmignore` file

Just like a `.gitignore` of a git repository, `.helmignore` do the same thing for a Helm chart.

While packaging a chart directory (into a chart archive), `helm package` command will ignore all the files that match the pattern specified in the `.helmignore` file (if it exists).

The format of `.helmignore` files closely follows, but does not exactly match, the [format for `.gitignore` files](https://git-scm.com/docs/gitignore).

The rules of `helmignore` is available in its [Go docs for Helm's `ignore` package](https://pkg.go.dev/helm.sh/helm/v3/pkg/ignore).

> [!WARNING]
> There are some differences between `.helmignlore` & `.gitignore` files.
>
> For more information, which is also available in `ignore` package docs.

e.g.

- An `.helmingore` file
  
  ```shell
  .helmignore # Match any file or directory named .helmignore
  .git        # Match any file or directory named .git
  *.txt       # Match any text file
  mydir/      # Match only directories named mydir
  /*.txt      # Match only text files in the top-level directory
  /foo.txt    # Match only the file foo.txt in the top-level directory
  a[b-d].txt  # Match any file named ab.txt, ac.txt, or ad.txt
  */temp*     # Match any file under subdir matching temp*
  ```