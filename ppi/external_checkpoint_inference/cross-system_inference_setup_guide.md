
# 1 
Obtain a checkpoint

# 2
Provide the checkpoint to setup.sh and run the script with 
```
sbatch setup.sh
```
This will take some time. The script isn't very efficient due to installing and reinstalling a bunch of packages. Might make it better later. 

# 3
Add the checkpoint to infer.yaml. 
May change graph and datasets.
Specify the date and forecast duration. 

# 4 
Run 
```
sbatch ppi_infer.sh
```



