
I recommend to start with the `nohup` command and redirect the inputs/outputs:

```shell
nohup ./wrapper_delete_old_files.sh >delete_output.txt 2>delete_output.txt </dev/null &
```
