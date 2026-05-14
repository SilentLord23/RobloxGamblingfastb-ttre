# Setting up collaboration in roblox studio with git

To make collaboration work we will be using github and and vscode plugin called Rojo. The workflow might be a bit confusing since we aren't communicating between Github and Roblox Studios. I'll try to explain.

## TLDR
- We create a github repository, either locally or on github and then clone. Open that repository in vscode. 
- Install Rojo into that repository. 
- Start the Rojo server in vscode. 
- Connect to the Rojo server in Roblox Studios

## Workflow

Github and vscode are connected with git and are talking to eachother. Vscode is then connected to Roblox Studios. Roblox Studios and Github are only connected by proxy.

1. Pull main.
2. Create a branch
3. Work on a feature in vscode/roblox
- NOTE! Only scripts are on github. The main world in roblox is on Roblox servers and will not be uploaded to github. In order to do local testing, go into Roblox Studios > File > Download a copy. *IF* building models or changing the world do so using Roblox Studio Collaborators.
4. Push branch to github when satisfied
5. Review eachothers branches with pull requests
6. Merge

