# DO NOT USE
Currently breaks cluster and density test fails. 

# update_azurecni.ps usage:

Parameters:
* String - win_user - user for Windows nodes
* String - win_pass - Password for Windows nodes
* String - azurecni_version - Example: "v1.0.14."

```sh
# ssh into master:
ssh "$USER@$MASTERIP"

docker run --rm -v ~/.kube/config:/root/.kube/config vyta/windows-update-azurecni -win_user $win_user -win_pass $win_pass -azurecni_version $azurecni_version

```